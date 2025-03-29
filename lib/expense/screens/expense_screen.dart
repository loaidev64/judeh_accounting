import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/category/widgets/category_search.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../controllers/expense_controller.dart';

class ExpenseScreen extends StatefulWidget {
  static const routeName = '/expense';

  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final controller = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        title: controller.currentPage.value == Screen.expense
            ? 'المصاريف'
            : 'التصنيفات',
        bottomNavBar: AddEditBottomNavBar(
            onAdd: controller.currentPage.value == Screen.expense
                ? controller.createExpense
                : controller.categoryController.createCategory,
            onEdit: controller.currentPage.value == Screen.expense
                ? controller.editExpense
                : controller.categoryController.editCategory,
            resourceName: controller.currentPage.value == Screen.expense
                ? 'مصروف'
                : 'تصنيف'),
        child: SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppTab(
                      selected: controller.currentPage.value == Screen.expense,
                      text: 'المصاريف',
                      onTap: () => controller.changePage(Screen.expense),
                    ),
                    SizedBox(width: 5.w),
                    AppTab(
                      selected: controller.currentPage.value == Screen.category,
                      text: 'التصنيفات',
                      onTap: () => controller.changePage(Screen.category),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                controller.loading.value
                    ? AppLoading()
                    : controller.currentPage.value == Screen.expense
                        ? Column(
                            children: [
                              CategorySearch(
                                onSearch: controller.categoryController.returnCategories,
                                onSelected: controller.getExpenses,
                              ),
                              SizedBox(height: 5.h),
                              AppTable(
                                headers: [
                                  Header(label: 'المعرف', width: 59.w),
                                  Header(label: 'التكلفة', width: 83.w),
                                  Header(label: 'الملاحظات', width: 175.w),
                                ],
                                itemsCount: controller.expenses.length,
                                getData: (index) => [
                                  controller.expenses[index].id.toString(),
                                  controller.expenses[index].cost.toString(),
                                  controller.expenses[index].description ?? '',
                                ],
                                onSelect: (index) =>
                                    controller.selectedExpenseIndex = index,
                              ),
                            ],
                          )
                        : AppTable(
                            headers: [
                              Header(label: 'المعرف', width: 59.w),
                              Header(label: 'الاسم', width: 100.w),
                              Header(label: 'الملاحظات', width: 175.w),
                            ],
                            itemsCount: controller.categoryController.categories.length,
                            getData: (index) => [
                              controller.categoryController.categories[index].id.toString(),
                              controller.categoryController.categories[index].name,
                              controller.categoryController.categories[index].description ?? '',
                            ],
                            onSelect: (index) =>
                                controller.categoryController.selectedCategoryIndex = index,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
