import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';
import '../models/category.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  int selectedCategoryIndex = -1;

  final CategoryType type;
  CategoryController({required this.type});

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  /// Resets all fields to their original values.
  void resetFields() {
    selectedCategoryIndex = -1;

    _idTextController.clear();
    _nameTextController.clear();
    _descriptionTextController.clear();
  }

  @override
  void onClose() {
    _idTextController.dispose();
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    super.onClose();
  }

  Future<List<Category>> returnCategories([String? search]) async {
    final List<Map<String, Object?>> categories;
    if (search == null) {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: 'type = ?', whereArgs: [type.index], limit: 25);
    } else {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: "name LIKE ? AND type = ?",
          whereArgs: ['%$search%', type.index],
          limit: 25);
    }
    return categories.map(Category.fromDatabase).toList();
  }

  Future<void> createCategory(CategoryType type) async {
    final category = Category.empty(type);
    await _showCategoryForm(category);
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
    await _showCategoryForm(category, isEditing: true);
  }

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
                Builder(builder: (context) {
                  return _buildCategoryActionButtons(category,
                      isEditing: isEditing, context: context);
                }),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
    categories.value = await returnCategories();
  }

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

  Widget _buildCategoryDescriptionField(Category category,
      {bool isEditing = false}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'الوصف',
            onSaved: (value) => category.description = value,
            controller: isEditing ? _descriptionTextController : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryActionButtons(Category category,
      {bool isEditing = false, required BuildContext context}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: AppButton(
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
            ),
          ),
        if (isEditing) SizedBox(width: 5.w),
        Expanded(
          child: AppButton(
            onTap: () async {
              if (!Form.of(context).validate()) return;
              Form.of(context).save();
              try {
                if (isEditing) {
                  await DatabaseHelper.update(
                    model: category,
                    tableName: Category.tableName,
                  );
                } else {
                  Get.printInfo(info: category.toDatabase.toString());
                  await DatabaseHelper.create(
                    model: category,
                    tableName: Category.tableName,
                  );
                }
                Get.back();
              } catch (e) {
                if (e.toString().contains('UNIQUE constraint failed')) {
                  Get.snackbar(
                    'خطأ',
                    'هذا التصنيف موجود مسبقاً، يرجى اختيار اسم آخر',
                    colorText: Colors.white,
                    backgroundColor: Colors.red,
                    snackPosition: SnackPosition.BOTTOM,
                    snackStyle: SnackStyle.GROUNDED,
                  );
                }
              }
            },
            text: isEditing ? 'تعديل' : 'إضافة',
            icon: isEditing ? 'assets/svgs/edit.svg' : 'assets/svgs/plus.svg',
          ),
        ),
      ],
    );
  }

  // Add these constants to the controller
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
}
