import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/models/category.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';
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
                : controller.createCategory,
            onEdit: controller.currentPage.value == Screen.material
                ? controller.editMaterial
                : controller.editCategory,
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
                              TypeAheadField<Category>(
                                suggestionsCallback:
                                    controller.returnCategories,
                                controller: categoryController,
                                builder: (context, controller, focusNode) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'التصنيف',
                                        style:
                                            AppTextStyles.appTextFormFieldLabel,
                                      ),
                                      TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        // autofocus: true,
                                        decoration: InputDecoration(
                                          border: AppTextFormField.border(),
                                          enabledBorder:
                                              AppTextFormField.border(),
                                          focusedBorder:
                                              AppTextFormField.border(),
                                          disabledBorder:
                                              AppTextFormField.border(),
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
                                  categoryController.text = category.name;
                                  controller.getMaterials(category);
                                },
                              ),
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
                                  controller.materials[index].id.toString(),
                                  controller.materials[index].name,
                                  controller.materials[index].quantity
                                      .toString(),
                                  controller.materials[index].cost.toString(),
                                  controller.materials[index].price.toString(),
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
                            itemsCount: controller.categories.length,
                            getData: (index) => [
                              controller.categories[index].id.toString(),
                              controller.categories[index].name,
                              controller.categories[index].description ?? '',
                            ],
                            onSelect: (index) =>
                                controller.selectedCategoryIndex = index,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
