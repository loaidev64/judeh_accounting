import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/category/widgets/category_search.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../controllers/material_controller.dart';

class MaterialScreen extends StatefulWidget {
  static const routeName = '/material';

  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final controller = Get.put(MaterialController());

  final categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        title: controller.currentPage.value == Screen.material
            ? 'المنتجات'
            : 'التصنيفات',
        bottomNavBar: AddEditBottomNavBar(
            onAdd: controller.currentPage.value == Screen.material
                ? controller.createMaterial
                : controller.categoryController.createCategory,
            onEdit: controller.currentPage.value == Screen.material
                ? controller.editMaterial
                : controller.categoryController.editCategory,
            resourceName: controller.currentPage.value == Screen.material
                ? 'منتج'
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
                      selected: controller.currentPage.value == Screen.material,
                      text: 'المنتجات',
                      onTap: () => controller.changePage(Screen.material),
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
                    : controller.currentPage.value == Screen.material
                        ? Column(
                            children: [
                              CategorySearch(
                                  onSearch: controller.returnCategories,
                                  onSelected: controller.getMaterials),
                              SizedBox(height: 5.h),
                              AppTable(
                                headers: [
                                  Header(label: 'المعرف', width: 59.w),
                                  Header(label: 'الاسم', width: 83.w),
                                  Header(label: 'الكمية', width: 53.w),
                                  Header(label: 'التكلفة', width: 65.w),
                                  Header(label: 'سعر المستهلك', width: 69.w),
                                ],
                                itemsCount: controller.materials.length,
                                getData: (index) => [
                                  (index + 1).toString(),
                                  controller.materials[index].name,
                                  controller.materials[index].quantity
                                      .asIntIfItIsAnInt,
                                  controller
                                      .materials[index].cost.toPriceString,
                                  controller
                                      .materials[index].price.toPriceString,
                                ],
                                onSelect: (index) =>
                                    controller.selectedMaterialIndex = index,
                              ),
                            ],
                          )
                        : AppTable(
                            headers: [
                              Header(label: 'المعرف', width: 59.w),
                              Header(label: 'الاسم', width: 100.w),
                              Header(label: 'الملاحظات', width: 175.w),
                            ],
                            itemsCount:
                                controller.categoryController.categories.length,
                            getData: (index) => [
                              controller.categoryController.categories[index].id
                                  .toString(),
                              controller
                                  .categoryController.categories[index].name,
                              controller.categoryController.categories[index]
                                      .description ??
                                  '',
                            ],
                            onSelect: (index) => controller.categoryController
                                .selectedCategoryIndex = index,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
