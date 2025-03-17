import 'package:flutter/material.dart' hide Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/material/widgets/material_search.dart';
import 'package:judeh_accounting/order/controllers/order_management_controller.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/widgets/order_card.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
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
                  height: 300.h,
                  onSelect: controller.editItem,
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
              AppButton(
                onTap: controller.create,
                text: '${controller.order == null ? 'إضافة' : 'تعديل'} فاتورة',
                icon: 'assets/svgs/plus.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
