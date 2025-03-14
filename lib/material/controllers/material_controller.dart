import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/category/widgets/category_search.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/category/models/category.dart';
import '../models/material.dart' as m;

enum Screen { material, category }

final class MaterialController extends GetxController {
  final currentPage = Screen.material.obs;
  final materials = <m.Material>[].obs;
  final categories = <Category>[].obs;
  final loading = false.obs;

  int selectedMaterialIndex = -1; // Track selected material for editing
  int selectedCategoryIndex = -1; // Track selected category for editing

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _quantityTextController = TextEditingController();
  final _costTextController = TextEditingController();
  final _priceTextController = TextEditingController();
  final _categoryIdTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  // Constants for repeated values
  static const _bottomSheetBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );
  static const _bottomSheetBoxShadow = BoxShadow(
    color: AppColors.primary,
    offset: Offset(0, -10),
  );
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
    _descriptionTextController.dispose();
    super.onClose();
  }

  /// Resets all fields to their original values.
  void _resetFields() {
    selectedMaterialIndex = -1;
    selectedCategoryIndex = -1;

    _idTextController.clear();
    _nameTextController.clear();
    _quantityTextController.clear();
    _costTextController.clear();
    _priceTextController.clear();
    _categoryIdTextController.clear();
    _descriptionTextController.clear();
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

  /// Fetches categories from the database.
  void getCategories() async {
    categories.value = await returnCategories();
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
                                            await Vibration.vibrate(
                                                duration: 1000,
                                                preset: VibrationPreset
                                                    .quickSuccessAlert);
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
                      _buildNameField(material, isEditing: isEditing),
                      SizedBox(height: 5.h),
                      _buildPriceField(material, isEditing: isEditing),
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
            'لا يمكنك إضافة هذا المنتج لانك قمت بالفعل بإنشاء منتج له نفس الباركود ونفس الاسم'),
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

  /// Opens a bottom sheet to create a new category.
  Future<void> createCategory() async {
    final category = Category.empty(CategoryType.material);
    await _showCategoryForm(category);
  }

  /// Opens a bottom sheet to edit an existing category.
  Future<void> editCategory() async {
    if (selectedCategoryIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك أولاً اختيار فئة',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    final category = categories[selectedCategoryIndex];
    _idTextController.text = category.id.toString();
    _nameTextController.text = category.name;
    _descriptionTextController.text = category.description ?? '';

    await _showCategoryForm(category, isEditing: true);
  }

  /// Opens a bottom sheet to create or edit a category.
  Future<void> _showCategoryForm(Category category,
      {bool isEditing = false}) async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _bottomSheetBorderRadius,
          boxShadow: [_bottomSheetBoxShadow],
        ),
        height: 356.h,
        width: double.infinity,
        padding: _bottomSheetPadding,
        child: Material(
          child: Form(
            child: Column(
              children: [
                _buildCategoryNameField(category, isEditing: isEditing),
                SizedBox(height: 5.h),
                _buildCategoryDescriptionField(category, isEditing: isEditing),
                SizedBox(height: 10.h),
                _buildCategoryActionButtons(category, isEditing: isEditing),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getCategories(); // Refresh the categories list
  }

  /// Builds the category name field.
  Widget _buildCategoryNameField(Category category, {bool isEditing = false}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'الاسم',
            onSaved: (value) => category.name = value ?? '',
            isRequired: true,
            controller: isEditing ? _nameTextController : null,
          ),
        ),
        Spacer(),
      ],
    );
  }

  /// Builds the category description field.
  Widget _buildCategoryDescriptionField(Category category,
      {bool isEditing = false}) {
    return AppTextFormField(
      label: 'ملاحظات',
      onSaved: (value) => category.description = value,
      controller: isEditing ? _descriptionTextController : null,
    );
  }

  /// Builds the category action buttons (Add/Edit, Delete).
  Widget _buildCategoryActionButtons(Category category,
      {bool isEditing = false}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Builder(
              builder: (context) {
                return AppButton(
                  onTap: () async {
                    await DatabaseHelper.delete(
                      model: category,
                      tableName: Category.tableName,
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
                    if (isEditing) {
                      await DatabaseHelper.update(
                        model: category,
                        tableName: Category.tableName,
                      );
                    } else {
                      await DatabaseHelper.create(
                        model: category,
                        tableName: Category.tableName,
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
}
