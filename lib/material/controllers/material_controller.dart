import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/pocketbase/constants/pocketbase_collections.dart';
import 'package:judeh_accounting/pocketbase/controllers/pocketbase_controller.dart';
import 'package:judeh_accounting/shared/category/widgets/category_search.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/logger/app_logger.dart';

import '../../pocketbase/helpers/pocketbase_helper.dart';
import '../../shared/category/controllers/category_controller.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/category/models/category.dart';
import '../models/material.dart' as m;

enum Screen { material, category }

class MaterialController extends GetxController {
  final currentPage = Screen.material.obs;
  final materials = <m.Material>[].obs;
  final categoryController =
      Get.put(CategoryController(type: CategoryType.material));
  final loading = false.obs;

  int selectedMaterialIndex = -1; // Track selected material for editing

  final _pocketbase = pocketbase().collection(PocketbaseCollections.materials);

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _quantityTextController = TextEditingController();
  final _costTextController = TextEditingController();
  final _priceTextController = TextEditingController();
  final _categoryIdTextController = TextEditingController();

  static const _bottomSheetPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10,
  );

  late final Future<void> Function() unsubscribeToPolling;

  @override
  void onInit() async {
    getMaterials();
    unsubscribeToPolling = await PocketbaseHelper.polling(
        collectionName: PocketbaseCollections.materials, onPoll: getMaterials);
    super.onInit();
  }

  @override
  void onClose() {
    _idTextController.dispose();
    _nameTextController.dispose();
    _quantityTextController.dispose();
    _costTextController.dispose();
    _priceTextController.dispose();
    _categoryIdTextController.dispose();
    unsubscribeToPolling();
    super.onClose();
  }

  /// Resets all fields to their original values.
  void _resetFields() {
    selectedMaterialIndex = -1;

    _idTextController.clear();
    _nameTextController.clear();
    _quantityTextController.clear();
    _costTextController.clear();
    _priceTextController.clear();
    _categoryIdTextController.clear();
    categoryController.resetFields();
  }

  /// Changes the current page and fetches data accordingly.
  void changePage(Screen page) {
    currentPage.value = page;
    loading.value = true;
    switch (page) {
      case Screen.material:
        getMaterials();
        break;
      default:
        getCategories();
    }
    _resetFields();
    loading.value = false;
  }

  /// Fetches materials from the database.
  void getMaterials([Category? category]) async {
    loading.value = true;
    final response = await _pocketbase.getList(
      perPage: 25,
      filter: category == null ? null : 'category_id="${category.id}"',
    );
    final materials = response.items.map((e) => e.data);
    this.materials.value = materials.map(m.Material.fromDatabase).toList();
    loading.value = false;
    _resetFields();
  }

  // Update the getCategories method:
  void getCategories() async {
    categoryController.categories.value =
        await categoryController.returnCategories();
    _resetFields();
  }

  /// Opens a bottom sheet to create or edit a material.
  Future<void> _showMaterialForm(m.Material material,
      {bool isEditing = false}) async {
    bool wantBarcode = true;
    await Get.to(
      SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: Container(
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: BackButton(
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: _bottomSheetBorderRadius,
            //   boxShadow: [_bottomSheetBoxShadow],
            // ),
            // width: double.infinity,
            padding: _bottomSheetPadding,
            child: Material(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    children: [
                      StatefulBuilder(builder: (context, setState) {
                        return Column(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  setState(() => wantBarcode = !wantBarcode),
                              icon: Icon(wantBarcode
                                  ? Icons.camera_alt_outlined
                                  : Icons.no_photography_outlined),
                            ),
                            wantBarcode
                                ? Stack(
                                    children: [
                                      if (material.barcode == null)
                                        AppBarcodeQrcodeScanner(
                                          onScan: (barcode) async {
                                            material.barcode = barcode;
                                            setState(() {});
                                          },
                                        ),
                                      if (material.barcode != null)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          width: double.infinity,
                                          height: 75.h,
                                          child: Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  'الباركود : ${material.barcode}'),
                                              SizedBox(height: 5.h),
                                              TextButton(
                                                onPressed: () => setState(() =>
                                                    material.barcode = null),
                                                child: Text('تعديل الباركود'),
                                              ),
                                            ],
                                          )),
                                        ),
                                    ],
                                  )
                                : AppTextFormField(
                                    label: 'الباركود',
                                    onSaved: (value) =>
                                        material.barcode = value,
                                  ),
                          ],
                        );
                      }),
                      _buildCategoryField(material, isEditing: isEditing),
                      SizedBox(height: 5.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الوحدة :',
                            style: AppTextStyles.appTextFormFieldLabel,
                          ),
                          DropdownButtonFormField(
                            style: AppTextStyles.appTextFormFieldText,
                            decoration: InputDecoration(
                              border: AppTextFormField.border(),
                              enabledBorder: AppTextFormField.border(),
                              focusedBorder: AppTextFormField.border(),
                            ),
                            value: material.unit,
                            items: m.Unit.values
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                material.unit = value ?? m.Unit.amount,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildNameField(material, isEditing: isEditing),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                              child: _buildPriceField(material,
                                  isEditing: isEditing)),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      _buildQuantityAndCostFields(material,
                          isEditing: isEditing),
                      SizedBox(height: 10.h),
                      _buildActionButtons(material, isEditing: isEditing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // isScrollControlled: true,
    );
  }

  /// Builds the name field.
  Widget _buildNameField(m.Material material, {bool isEditing = false}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'الاسم',
            onSaved: (value) => material.name = value ?? '',
            isRequired: true,
            controller: isEditing ? _nameTextController : null,
          ),
        ),
      ],
    );
  }

  /// Builds the quantity and cost fields.
  Widget _buildQuantityAndCostFields(m.Material material,
      {bool isEditing = false}) {
    return Row(
      children: [
        if (!isEditing) ...[
          Expanded(
            child: AppTextFormField(
              label: 'الكمية',
              onSaved: (value) =>
                  material.quantity = double.parse(value ?? '0'),
              isRequired: true,
              keyboardType: TextInputType.number,
              controller: isEditing ? _quantityTextController : null,
            ),
          ),
          SizedBox(width: 5.w),
        ],
        Expanded(
          child: AppTextFormField(
            label: 'التكلفة',
            onSaved: (value) => material.cost = double.parse(value ?? '0.0'),
            isRequired: true,
            keyboardType: TextInputType.number,
            controller: isEditing ? _costTextController : null,
            isPrice: true,
          ),
        ),
      ],
    );
  }

  /// Builds the price field.
  Widget _buildPriceField(m.Material material, {bool isEditing = false}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'السعر',
            onSaved: (value) {
              AppLogger.info('price is $value');
              material.price = double.parse(value ?? '0.0');
            },
            isRequired: true,
            keyboardType: TextInputType.number,
            controller: isEditing ? _priceTextController : null,
            isPrice: true,
          ),
        ),
      ],
    );
  }

  /// Builds the category field using TypeAhead.
  Widget _buildCategoryField(m.Material material, {bool isEditing = false}) {
    return CategorySearch(
      controller: _categoryIdTextController,
      onSearch: categoryController.returnCategories,
      onSelected: ([category]) => material.categoryId = category!.id,
    );
  }

  /// Builds the action buttons (Add/Edit, Delete).
  Widget _buildActionButtons(m.Material material, {bool isEditing = false}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Builder(
              builder: (context) {
                return AppButton(
                  onTap: () async {
                    try {
                      await _pocketbase.delete(material.id);
                      Get.back();
                    } catch (e, trace) {
                      AppLogger.exception(e, trace);
                      await Get.dialog(
                        AlertDialog.adaptive(
                          title: Text(
                            'تحذير',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 24.sp,
                              fontFamily: appFontFamily,
                            ),
                          ),
                          content: Text(
                            'لا يمكن حذف هذه المادة لأنها مرتبطة بفواتير.',
                            style: TextStyle(fontFamily: appFontFamily),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('موافق'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  text: 'حذف',
                  color: Colors.red,
                  icon: 'assets/svgs/delete.svg',
                );
              },
            ),
          ),
        if (isEditing) SizedBox(width: 5.w),
        Expanded(
          child: Builder(
            builder: (context) {
              return AppButton(
                onTap: () async {
                  if (Form.of(context).validate()) {
                    Form.of(context).save();
                    if (await _checkIfBarcodeOrNameAlreadyExsists(material)) {
                      return;
                    }

                    if (material.categoryId.isEmpty) {
                      if (_categoryIdTextController.text.isNotEmpty) {
                        final bool result = await Get.dialog(
                          AlertDialog.adaptive(
                            title: Text(
                              'تحذير',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 24.sp,
                                fontFamily: appFontFamily,
                              ),
                            ),
                            content: Text(
                              'لا يوجد لديك هذه التصنيف "${_categoryIdTextController.text}"، هل تريد إضافتها إلى التصنيفات؟',
                              style: TextStyle(fontFamily: appFontFamily),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: Text('موافق'),
                              ),
                            ],
                          ),
                        );

                        if (result) {
                          final newCategory = Category(
                            name: _categoryIdTextController.text,
                            type:
                                CategoryType.material, // Changed to expense type
                            createdAt: DateTime.now(),
                          );

                          final response = await pocketbase()
                              .collection(PocketbaseCollections.categories)
                              .create(body: newCategory.toDatabase);
                          material.categoryId = response.data['id'];
                        } else {
                          return; // Cancel the operation
                        }
                      }
                    }

                    if (isEditing) {
                      await _pocketbase.update(material.id,
                          body: material.toDatabase);
                    } else {
                      await _pocketbase.create(body: material.toDatabase);
                    }
                    Get.back();
                  }
                },
                text: isEditing ? 'تعديل' : 'إضافة',
                icon:
                    isEditing ? 'assets/svgs/edit.svg' : 'assets/svgs/plus.svg',
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _checkIfBarcodeOrNameAlreadyExsists(m.Material material) async {
    AppLogger.info('material barcode is ${material.barcode}');
    if (material.barcode?.isEmpty ?? true) {
      return false;
    }

    try {
      final reponse = await _pocketbase.getList(
        filter: '(barcode = "%${material.barcode}%" && id != "${material.id}")',
      );
      if (reponse.items.isEmpty) {
        return false;
      }

      final materialsHaveTheSameBarcode = reponse.items
          .map((e) => e.data)
          .map((e) => m.Material.fromDatabase(e));

      if (materialsHaveTheSameBarcode
          .where((element) => element.name == material.name)
          .isNotEmpty) {
        await Get.dialog(AlertDialog.adaptive(
          title: Text(
            'خطأ',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
              fontFamily: appFontFamily,
            ),
          ),
          content: Text(
            'لا يمكنك إضافة هذا المنتج لانك قمت بالفعل بإنشاء منتج له نفس الباركود ونفس الاسم',
            style: TextStyle(fontFamily: appFontFamily),
          ),
        ));
        return true;
      }

      return false;
    } catch (e, trace) {
      AppLogger.exception(e, trace);
      return false;
    }
  }

  /// Opens a bottom sheet to create a new material.
  Future<void> createMaterial() async {
    final material = m.Material.empty();
    await _showMaterialForm(material);
  }

  /// Opens a bottom sheet to edit an existing material.
  Future<void> editMaterial() async {
    if (selectedMaterialIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك أولاً اختيار مادة',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    final material = materials[selectedMaterialIndex];
    _idTextController.text = material.id.toString();
    _nameTextController.text = material.name;
    _quantityTextController.text = material.quantity.asIntIfItIsAnInt;
    _costTextController.text = material.cost.toPriceTextFormField;
    _priceTextController.text = material.price.toPriceTextFormField;

    final record = await pocketbase()
        .collection(PocketbaseCollections.categories)
        .getOne(material.categoryId, fields: 'name');
    _categoryIdTextController.text = record.data['name'];

    await _showMaterialForm(material, isEditing: true);
  }
}
