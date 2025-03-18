import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/category/models/category.dart';
import '../models/expense.dart';

enum Screen { expense, category }

final class ExpenseController extends GetxController {
  final currentPage = Screen.expense.obs;
  final expenses = <Expense>[].obs;
  final categories = <Category>[].obs;
  final loading = false.obs;

  int selectedExpenseIndex = -1; // Track selected expense for editing
  int selectedCategoryIndex = -1; // Track selected category for editing

  final _nameTextController = TextEditingController();
  final _costTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _categoryIdTextController = TextEditingController();

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
    getExpenses();
    super.onInit();
  }

  @override
  void onClose() {
    _costTextController.dispose();
    _descriptionTextController.dispose();
    _categoryIdTextController.dispose();
    super.onClose();
  }

  /// Resets all fields to their original values.
  void _resetFields() {
    selectedExpenseIndex = -1;
    selectedCategoryIndex = -1;

    _costTextController.clear();
    _descriptionTextController.clear();
    _categoryIdTextController.clear();
    _nameTextController.clear();
  }

  /// Changes the current page and fetches data accordingly.
  void changePage(Screen page) {
    currentPage.value = page;
    loading.value = true;
    switch (page) {
      case Screen.expense:
        getExpenses();
        break;
      default:
        getCategories();
    }
    _resetFields();
    loading.value = false;
  }

  /// Fetches expenses from the database.
  void getExpenses([Category? category]) async {
    loading.value = true;
    final List<Map<String, Object?>> expenses;
    if (category == null) {
      expenses = await DatabaseHelper.getDatabase()
          .query(Expense.tableName, limit: 25);
    } else {
      expenses = await DatabaseHelper.getDatabase().query(Expense.tableName,
          where: 'category_id = ?', whereArgs: [category.id], limit: 25);
    }
    this.expenses.value = expenses.map(Expense.fromDatabase).toList();
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
          whereArgs: [CategoryType.expense.index],
          limit: 25);
    } else {
      categories = await DatabaseHelper.getDatabase().query(Category.tableName,
          where: "name LIKE ? AND type = ?",
          whereArgs: ['%$search%', CategoryType.expense.index],
          limit: 25);
    }
    return categories.map(Category.fromDatabase).toList();
  }

  /// Opens a bottom sheet to create or edit an expense.
  Future<void> _showExpenseForm(Expense expense,
      {bool isEditing = false}) async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _bottomSheetBorderRadius,
          boxShadow: [_bottomSheetBoxShadow],
        ),
        height: 400.h, // Adjusted height for expense fields
        width: double.infinity,
        padding: _bottomSheetPadding,
        child: Material(
          child: Form(
            child: Column(
              children: [
                _buildCategoryField(expense, isEditing: isEditing),
                SizedBox(height: 5.h),
                _buildCostField(expense, isEditing: isEditing),
                SizedBox(height: 5.h),
                _buildDescriptionField(expense, isEditing: isEditing),
                SizedBox(height: 10.h),
                _buildActionButtons(expense, isEditing: isEditing),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    getExpenses(); // Refresh the expenses list
  }

  /// Builds the cost field.
  Widget _buildCostField(Expense expense, {bool isEditing = false}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'التكلفة',
            onSaved: (value) => expense.cost = double.parse(value ?? '0.0'),
            isRequired: true,
            keyboardType: TextInputType.number,
            controller: isEditing ? _costTextController : null,
          ),
        ),
      ],
    );
  }

  /// Builds the description field.
  Widget _buildDescriptionField(Expense expense, {bool isEditing = false}) {
    return AppTextFormField(
      label: 'ملاحظات',
      onSaved: (value) => expense.description = value,
      controller: isEditing ? _descriptionTextController : null,
    );
  }

  /// Builds the category field using TypeAhead.
  Widget _buildCategoryField(Expense expense, {bool isEditing = false}) {
    return TypeAheadField<Category>(
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
        expense.categoryId = category.id;
        _categoryIdTextController.text = category.name;
      },
    );
  }

  /// Builds the action buttons (Add/Edit, Delete).
  Widget _buildActionButtons(Expense expense, {bool isEditing = false}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Builder(
              builder: (context) {
                return AppButton(
                  onTap: () async {
                    await DatabaseHelper.delete(
                      model: expense,
                      tableName: Expense.tableName,
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
                        model: expense,
                        tableName: Expense.tableName,
                      );
                    } else {
                      await DatabaseHelper.create(
                        model: expense,
                        tableName: Expense.tableName,
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

  /// Opens a bottom sheet to create a new expense.
  Future<void> createExpense() async {
    final expense = Expense.empty();
    await _showExpenseForm(expense);
  }

  /// Opens a bottom sheet to edit an existing expense.
  Future<void> editExpense() async {
    if (selectedExpenseIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك أولاً اختيار مصروف',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    final expense = expenses[selectedExpenseIndex];
    _costTextController.text = expense.cost.toString();
    _descriptionTextController.text = expense.description ?? '';
    _categoryIdTextController.text = (await DatabaseHelper.getDatabase().query(
            Category.tableName,
            columns: ['name'],
            where: 'id = ?',
            whereArgs: [expense.categoryId]))
        .first['name'] as String;

    await _showExpenseForm(expense, isEditing: true);
  }

  /// Opens a bottom sheet to create a new category.
  Future<void> createCategory() async {
    final category = Category.empty(CategoryType.expense);
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
    _nameTextController.text = category.name.toString();
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
