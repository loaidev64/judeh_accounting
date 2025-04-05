import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/category/models/category.dart';
import '../../shared/category/controllers/category_controller.dart'; // Import CategoryController
import '../models/expense.dart';

enum Screen { expense, category }

final class ExpenseController extends GetxController {
  final currentPage = Screen.expense.obs;
  final expenses = <Expense>[].obs;
  final categoryController = Get.put(
      CategoryController(type: CategoryType.expense)); // Use CategoryController
  final loading = false.obs;

  int selectedExpenseIndex = -1; // Track selected expense for editing

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

    _costTextController.clear();
    _descriptionTextController.clear();
    _categoryIdTextController.clear();
    _nameTextController.clear();
    categoryController.resetFields(); // Reset category fields
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
    categoryController.categories.value =
        await categoryController.returnCategories();
    _resetFields();
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
      suggestionsCallback:
          categoryController.returnCategories, // Use CategoryController
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

                    if (expense.categoryId == -1) {
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
                              'لا يوجد لديك هذا التصنيف "${_categoryIdTextController.text}"، هل تريد إضافته إلى التصنيفات؟',
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
                                CategoryType.expense, // Changed to expense type
                            createdAt: DateTime.now(),
                          );

                          final category = await DatabaseHelper.create(
                            model: newCategory,
                            tableName: Category.tableName,
                          );

                          expense.categoryId = category.id;
                        } else {
                          return;
                        }
                      }
                    }

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
}
