import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/shared/category/widgets/category_search.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../shared/category/controllers/category_controller.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/category/models/category.dart';
import '../models/material.dart' as m;

enum Screen { material, category }

final class MaterialController extends GetxController {
  final currentPage = Screen.material.obs;
  final materials = <m.Material>[].obs;
  final categoryController =
      Get.put(CategoryController(type: CategoryType.material));
  final loading = false.obs;

  int selectedMaterialIndex = -1; // Track selected material for editing

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

  @override
  void onInit() {
    getMaterials();
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
    final List<Map<String, Object?>> materials;
    if (category == null) {
      materials = await DatabaseHelper.getDatabase()
          .query(m.Material.tableName, limit: 25);
    } else {
      materials = await DatabaseHelper.getDatabase().query(m.Material.tableName,
          where: 'category_id = ?', whereArgs: [category.id], limit: 25);
    }
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

  /// Returns a list of categories, optionally filtered by search.
  Future<List<Category>> returnCategories([String? search]) async {
    final List<Map<String, Object?>> categories;
    if (search == null) {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: 'type = ?',
          whereArgs: [CategoryType.material.index],
          limit: 25);
    } else {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: "name LIKE ? AND type = ?",
          whereArgs: ['%$search%', CategoryType.material.index],
          limit: 25);
    }
    return categories.map(Category.fromDatabase).toList();
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

    getMaterials(); // Refresh the materials list
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
            onSaved: (value) => material.price = double.parse(value ?? '0.0'),
            isRequired: true,
            keyboardType: TextInputType.number,
            controller: isEditing ? _priceTextController : null,
          ),
        ),
      ],
    );
  }

  /// Builds the category field using TypeAhead.
  Widget _buildCategoryField(m.Material material, {bool isEditing = false}) {
    return CategorySearch(
      controller: _categoryIdTextController,
      onSearch: returnCategories,
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
                    final database = DatabaseHelper.getDatabase();
                    final materialHaveChildren = await database.query(
                      Order.tableName,
                      columns: ['COUNT(*)'],
                      where: 'material_id = ?',
                      whereArgs: [material.id],
                    );
                    if (materialHaveChildren.isEmpty ||
                        materialHaveChildren.first['COUNT(*)'] == 0) {
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
                      return;
                    }
                    await DatabaseHelper.delete(
                      model: material,
                      tableName: m.Material.tableName,
                    );
                    Get.back();
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

                    if (material.categoryId == -1) {
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
                            type: CategoryType.material,
                            createdAt: DateTime.now(),
                          );

                          // Create the category and get its ID
                          final category = await DatabaseHelper.create(
                            model: newCategory,
                            tableName: Category.tableName,
                          );

                          // Update material with new category ID
                          material.categoryId = category.id;
                        } else {
                          return; // Cancel the operation
                        }
                      }
                    }

                    if (isEditing) {
                      await DatabaseHelper.update(
                        model: material,
                        tableName: m.Material.tableName,
                      );
                    } else {
                      await DatabaseHelper.create(
                        model: material,
                        tableName: m.Material.tableName,
                      );
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
    if (material.barcode == null) {
      return false;
    }
    final database = DatabaseHelper.getDatabase();
    final dataMaterialsHaveTheSameBarcode = await database.query(
        m.Material.tableName,
        where: 'barcode = ? AND id != ?',
        whereArgs: [material.barcode, material.id]);
    if (dataMaterialsHaveTheSameBarcode.isEmpty) {
      return false;
    }

    final materialsHaveTheSameBarcode = dataMaterialsHaveTheSameBarcode
        .map((e) => m.Material.fromDatabase(e))
        .toList();

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
    _costTextController.text = material.cost.toInt().toString();
    _priceTextController.text = material.price.toInt().toString();
    _categoryIdTextController.text = (await DatabaseHelper.getDatabase().query(
            Category.tableName,
            columns: ['name'],
            where: 'id = ?',
            whereArgs: [material.categoryId]))
        .first['name'] as String;

    await _showMaterialForm(material, isEditing: true);
  }
}
