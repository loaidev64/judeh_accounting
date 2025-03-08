import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../models/category.dart';
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

  void _resetFields() {
    // Reset selected indices
    selectedMaterialIndex = -1;
    selectedCategoryIndex = -1;

    // Clear all text controllers
    _idTextController.clear();
    _nameTextController.clear();
    _quantityTextController.clear();
    _costTextController.clear();
    _priceTextController.clear();
    _categoryIdTextController.clear();
    _descriptionTextController.clear();
  }

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

  void getMaterials([Category? category]) async {
    loading.value = true;
    final List<Map<String, Object?>> materials;
    if (category == null) {
      materials = await DatabaseHelper.getDatabase()
          .query(m.Material.tableName, limit: 100);
    } else {
      materials = await DatabaseHelper.getDatabase().query(m.Material.tableName,
          where: 'category_id = ?', whereArgs: [category.id], limit: 100);
    }
    this.materials.value = materials.map(m.Material.fromDatabase).toList();
    loading.value = false;
    _resetFields();
  }

  void getCategories() async {
    categories.value = await returnCategories();
    _resetFields();
  }

  Future<List<Category>> returnCategories([String? search]) async {
    final List<Map<String, Object?>> categories;
    if (search == null) {
      categories = await DatabaseHelper.getDatabase()
          .query(Category.tableName, limit: 100);
    } else {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: "name LIKE ?", whereArgs: ['%$search%'], limit: 100);
    }
    return categories.map(Category.fromDatabase).toList();
  }

  Future<void> createMaterial() async {
    final material = m.Material.empty(); // Create an empty material
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.r),
            topRight: Radius.circular(15.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              offset: Offset(0, -10),
            ),
          ],
        ),
        height: 500.h, // Increased height to accommodate more fields
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Material(
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الاسم',
                        onSaved: (value) => material.name = value ?? '',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الكمية',
                        onSaved: (value) =>
                            material.quantity = int.parse(value ?? '0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: AppTextFormField(
                        label: 'التكلفة',
                        onSaved: (value) =>
                            material.cost = double.parse(value ?? '0.0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'السعر',
                        onSaved: (value) =>
                            material.price = double.parse(value ?? '0.0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                TypeAheadField<Category>(
                  suggestionsCallback: returnCategories,
                  controller: _categoryIdTextController,
                  builder: (context, controller, focusNode) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التصنيف',
                          style: AppTextStyles.appTextFormFieldLabel,
                        ),
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            border: AppTextFormField.border(),
                            enabledBorder: AppTextFormField.border(),
                            focusedBorder: AppTextFormField.border(),
                            disabledBorder: AppTextFormField.border(),
                          ),
                        ),
                      ],
                    );
                  },
                  emptyBuilder: (context) => Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text('لا يوجد أي نتائج'),
                  ),
                  itemBuilder: (context, category) {
                    return ListTile(
                      title: Text(category.name),
                      subtitle: Text(category.description ?? ''),
                    );
                  },
                  onSelected: (category) {
                    material.categoryId = category.id;
                    _categoryIdTextController.text = category.name;
                  },
                ),
                SizedBox(height: 10.h),
                Builder(builder: (context) {
                  return AppButton(
                    onTap: () async {
                      if (Form.of(context).validate()) {
                        Form.of(context).save();
                        await DatabaseHelper.create(
                          model: material,
                          tableName: m.Material.tableName,
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    text: 'إضافة',
                    icon: 'assets/svgs/plus.svg',
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getMaterials(); // Refresh the materials list
  }

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
    _quantityTextController.text = material.quantity.toString();
    _costTextController.text = material.cost.toString();
    _priceTextController.text = material.price.toString();
    _categoryIdTextController.text = (await DatabaseHelper.getDatabase().query(
            Category.tableName,
            columns: ['name'],
            where: 'id = ?',
            whereArgs: [material.categoryId]))
        .first['name'] as String;

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.r),
            topRight: Radius.circular(15.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              offset: Offset(0, -10),
            ),
          ],
        ),
        height: 500.h, // Increased height to accommodate more fields
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Material(
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الاسم',
                        onSaved: (value) => material.name = value ?? '',
                        isRequired: true,
                        controller: _nameTextController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الكمية',
                        onSaved: (value) =>
                            material.quantity = int.parse(value ?? '0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        controller: _quantityTextController,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: AppTextFormField(
                        label: 'التكلفة',
                        onSaved: (value) =>
                            material.cost = double.parse(value ?? '0.0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        controller: _costTextController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'السعر',
                        onSaved: (value) =>
                            material.price = double.parse(value ?? '0.0'),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        controller: _priceTextController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                TypeAheadField<Category>(
                  suggestionsCallback: returnCategories,
                  controller: _categoryIdTextController,
                  builder: (context, controller, focusNode) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التصنيف',
                          style: AppTextStyles.appTextFormFieldLabel,
                        ),
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            border: AppTextFormField.border(),
                            enabledBorder: AppTextFormField.border(),
                            focusedBorder: AppTextFormField.border(),
                            disabledBorder: AppTextFormField.border(),
                          ),
                        ),
                      ],
                    );
                  },
                  emptyBuilder: (context) => Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text('لا يوجد أي نتائج'),
                  ),
                  itemBuilder: (context, category) {
                    return ListTile(
                      title: Text(category.name),
                      subtitle: Text(category.description ?? ''),
                    );
                  },
                  onSelected: (category) {
                    material.categoryId = category.id;
                    _categoryIdTextController.text = category.name;
                  },
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        return AppButton(
                          onTap: () async {
                            await DatabaseHelper.delete(
                              model: material,
                              tableName: m.Material.tableName,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          text: 'حذف',
                          color: Colors.red,
                          icon: 'assets/svgs/delete.svg',
                        );
                      }),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Builder(builder: (context) {
                        return AppButton(
                          onTap: () async {
                            if (Form.of(context).validate()) {
                              Form.of(context).save();
                              await DatabaseHelper.update(
                                model: material,
                                tableName: m.Material.tableName,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                          text: 'تعديل',
                          icon: 'assets/svgs/edit.svg',
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getMaterials(); // Refresh the materials list
  }

  Future<void> createCategory() async {
    final category = Category.empty(); // Create an empty category
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.r),
            topRight: Radius.circular(15.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              offset: Offset(0, -10),
            ),
          ],
        ),
        height: 356.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Material(
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الاسم',
                        onSaved: (value) => category.name = value ?? '',
                        isRequired: true,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 5.h),
                AppTextFormField(
                  label: 'ملاحظات',
                  onSaved: (value) => category.description = value,
                ),
                SizedBox(height: 10.h),
                Builder(builder: (context) {
                  return AppButton(
                    onTap: () async {
                      if (Form.of(context).validate()) {
                        Form.of(context).save();
                        await DatabaseHelper.create(
                          model: category,
                          tableName: Category.tableName,
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    text: 'إضافة',
                    icon: 'assets/svgs/plus.svg',
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getCategories(); // Refresh the categories list
  }

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

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.r),
            topRight: Radius.circular(15.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              offset: Offset(0, -10),
            ),
          ],
        ),
        height: 356.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Material(
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        label: 'الاسم',
                        onSaved: (value) => category.name = value ?? '',
                        isRequired: true,
                        controller: _nameTextController,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 5.h),
                AppTextFormField(
                  label: 'ملاحظات',
                  onSaved: (value) => category.description = value,
                  controller: _descriptionTextController,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        return AppButton(
                          onTap: () async {
                            await DatabaseHelper.delete(
                              model: category,
                              tableName: Category.tableName,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          text: 'حذف',
                          color: Colors.red,
                          icon: 'assets/svgs/delete.svg',
                        );
                      }),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Builder(builder: (context) {
                        return AppButton(
                          onTap: () async {
                            if (Form.of(context).validate()) {
                              Form.of(context).save();
                              await DatabaseHelper.update(
                                model: category,
                                tableName: Category.tableName,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                          text: 'تعديل',
                          icon: 'assets/svgs/edit.svg',
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getCategories(); // Refresh the categories list
  }
}
