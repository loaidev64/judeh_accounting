import 'package:flutter/material.dart' hide Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/material/widgets/material_search.dart';
import 'package:judeh_accounting/order/controllers/order_management_controller.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/widgets/order_card.dart';
import 'package:judeh_accounting/shared/extensions/order_item_list.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../../shared/theme/app_colors.dart';

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
          child: Column(
            children: [
              ObxValue(
                  (wantBarcode) => Column(
                        children: [
                          IconButton(
                            onPressed: () =>
                                wantBarcode.value = !wantBarcode.value,
                            icon: Icon(wantBarcode.value
                                ? Icons.camera_alt_outlined
                                : Icons.no_photography_outlined),
                          ),
                          wantBarcode.value
                              ? AppBarcodeQrcodeScanner(
                                  onScan: controller.onScanBarcode)
                              : MaterialSearch(
                                  controller: controller.materialController,
                                  onSearch: controller.returnMaterials,
                                  onSelected: ([material]) {
                                    if (material == null) {
                                      return;
                                    }
                                    controller.addItem(material);
                                  },
                                ),
                        ],
                      ),
                  true.obs),
              SizedBox(height: 5.h),
              Obx(
                () => OrderCard(
                  onSelectRow: controller.editItem,
                  onDelete: controller.removeItem,
                  borderColor: controller.addedNewItem.value
                      ? Colors.green
                      : AppColors.primary,
                  order: Order(
                    type: controller.type,
                    total: controller.items.total,
                    items: controller.items,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  if (controller.order != null)
                    Expanded(
                      child: AppButton(
                        onTap: controller.delete,
                        text: 'حذف',
                        color: Colors.red,
                        icon: 'assets/svgs/delete.svg',
                      ),
                    ),
                  if (controller.order != null) SizedBox(width: 5.w),
                  Expanded(
                    child: AppButton(
                      onTap: controller.save,
                      text: '${controller.order == null ? 'إضافة' : 'تعديل'} فاتورة',
                      icon: 'assets/svgs/plus.svg',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
