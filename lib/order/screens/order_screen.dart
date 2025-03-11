import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/controllers/order_controller.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

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
          onAdd: controller.currentPage.value == Screen.material
              ? controller.createMaterial
              : controller.createCategory,
          onEdit: controller.currentPage.value == Screen.material
              ? controller.editMaterial
              : controller.editCategory,
          resourceName: 'فاتورة'),
      child: SliverToBoxAdapter(
        child: Text('order'),
      ),
    );
  }
}
