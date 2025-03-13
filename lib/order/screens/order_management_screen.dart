import 'package:flutter/material.dart' hide Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/controllers/order_management_controller.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/widgets/order_card.dart';
import 'package:judeh_accounting/shared/extensions/price_double.dart';
import 'package:judeh_accounting/shared/extensions/sum_list.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import '../../material/models/material.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

class OrderManagementScreen extends StatefulWidget {
  static const routeName = '/orderManagement';

  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final controller = Get.put(OrderManagementController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '${controller.order == null ? 'إضافة' : 'تعديل'} فاتورة',
      child: SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        sliver: SliverToBoxAdapter(
          child: Form(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250.h,
                  child: QrCamera(
                    notStartedBuilder: (context) => AppLoading(),
                    qrCodeCallback: (code) {
                      Get.printInfo(info: 'the barcode is $code');
                    },
                  ),
                ),
                Builder(builder: (context) {
                  return TypeAheadField<Material>(
                    controller: controller.materialController,
                    emptyBuilder: (context) => Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Text('لا يوجد أي نتائج'),
                    ),
                    itemBuilder: (context, material) {
                      return ListTile(
                        title: Text(material.name),
                        subtitle: Text(material.price.toPriceString),
                      );
                    },
                    onSelected: (material) {
                      controller.materialController.text = material.name;
                      controller.material.value = material;
                      controller.priceController.text =
                          material.price.toInt().toString();
                      controller.quantityController.text = 1.toString();
                      FocusScope.of(context).nextFocus();
                    },
                    suggestionsCallback: controller.returnMaterials,
                    builder: (context, controller, focusNode) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المنتج',
                          style: AppTextStyles.appTextFormFieldLabel,
                        ),
                        TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            suffix: GestureDetector(
                              onTap: () {
                                controller.clear();
                              },
                              child: Icon(
                                Icons.close,
                                color: AppColors.primary,
                              ),
                            ),
                            border: AppTextFormField.border(),
                            enabledBorder: AppTextFormField.border(),
                            focusedBorder: AppTextFormField.border(),
                            disabledBorder: AppTextFormField.border(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => AppTextFormField(
                          label: 'الكمية',
                          isRequired: true,
                          controller: controller.quantityController,
                          keyboardType: TextInputType.number,
                          suffix: Text(
                            controller.material.value.unit.name,
                            style: AppTextStyles.appTextFormFieldText
                                .copyWith(color: AppColors.orange),
                          ),
                          counter: Text(
                            'العدد المتبقي ${controller.material.value.quantity.toInt()}',
                            style: AppTextStyles.appTextFormFieldText
                                .copyWith(color: AppColors.orange),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: AppTextFormField(
                        label: 'سعر المستهلك',
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        counter: Text(
                          'العدد المتبقي ${controller.material.value.quantity.toInt()}',
                          style: AppTextStyles.appTextFormFieldText
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Builder(builder: (context) {
                  return AppButton(
                    onTap: () async {
                      if (Form.of(context).validate()) {
                        Form.of(context).save();
                        controller.addItem();
                      }
                    },
                    text: 'إضافة',
                    icon: 'assets/svgs/plus.svg',
                  );
                }),
                SizedBox(height: 5.h),
                OrderCard(
                  order: Order(
                    type: controller.type,
                    total: controller.items.total,
                    items: controller.items,
                  ),
                ),
                SizedBox(height: 5.h),
                AppButton(
                  onTap: controller.create,
                  text: 'إضافة فاتورة',
                  icon: 'assets/svgs/plus.svg',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
