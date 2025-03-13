import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/controllers/order_controller.dart';
import 'package:judeh_accounting/order/widgets/order_card.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../models/order.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order';

  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final controller = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الفواتير',
      bottomNavBar: AddEditBottomNavBar(
          onAdd: controller.createOrder, resourceName: 'فاتورة'),
      child: SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        sliver: SliverToBoxAdapter(
          child: Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    AppTab(
                      selected: controller.currentType.value == OrderType.sell,
                      text: 'مبيعات',
                      onTap: () => controller.changeType(OrderType.sell),
                      icon: controller.currentType.value == OrderType.sell
                          ? 'assets/svgs/active_sell.svg'
                          : 'assets/svgs/inactive_sell.svg',
                    ),
                    SizedBox(width: 5.w),
                    AppTab(
                      selected:
                          controller.currentType.value == OrderType.sellRefund,
                      text: 'مرتجع مبيع',
                      onTap: () => controller.changeType(OrderType.sellRefund),
                      icon: controller.currentType.value == OrderType.sellRefund
                          ? 'assets/svgs/active_sell_refund.svg'
                          : 'assets/svgs/inactive_sell_refund.svg',
                    ),
                    SizedBox(width: 5.w),
                    AppTab(
                      selected: controller.currentType.value == OrderType.buy,
                      text: 'مشتريات',
                      onTap: () => controller.changeType(OrderType.buy),
                      icon: controller.currentType.value == OrderType.buy
                          ? 'assets/svgs/active_buy.svg'
                          : 'assets/svgs/inactive_buy.svg',
                    ),
                    SizedBox(width: 5.w),
                    AppTab(
                      selected:
                          controller.currentType.value == OrderType.buyRefund,
                      text: 'مرتجع شراء',
                      onTap: () => controller.changeType(OrderType.buyRefund),
                      icon: controller.currentType.value == OrderType.buyRefund
                          ? 'assets/svgs/active_buy_refund.svg'
                          : 'assets/svgs/inactive_buy_refund.svg',
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                controller.loading.value
                    ? AppLoading()
                    : Column(
                        children: List.generate(
                            controller.orders.length,
                            (index) =>
                                OrderCard(order: controller.orders[index])),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
