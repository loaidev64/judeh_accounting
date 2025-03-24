import 'package:get/get.dart';
import 'package:judeh_accounting/order/screens/order_management_screen.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../models/order.dart';

final class OrderController extends GetxController {
  final currentType = OrderType.sell.obs;
  final orders = <Order>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    getOrders();
    super.onInit();
  }

  void changeType(OrderType type) {
    currentType.value = type;

    getOrders();
  }

  void getOrders() async {
    orders.clear();
    loading.value = true; // Start loading

    final database = DatabaseHelper.getDatabase();

    // Fetch orders based on the current type
    final orderData = await database.query(
      Order.tableName,
      where: 'type = ?',
      whereArgs: [currentType.value.index],
      limit: 25,
    );

    // If no orders are found, clear the list and return
    if (orderData.isEmpty) {
      return;
    }

    // Fetch order items for the retrieved orders
    final orderIds = orderData.map((e) => e['id'] as int).toList();
    final orderItemsData = await database.query(
      'order_items JOIN materials ON order_items.material_id = materials.id',
      columns: [
        'order_items.id',
        'material_id',
        'order_items.price',
        'order_items.quantity',
        'order_id',
        'order_items.createdAt',
        'order_items.updatedAt',
        'materials.name AS material_name'
      ],
      where: 'order_id IN (${List.filled(orderIds.length, '?').join(',')})',
      whereArgs: orderIds,
    );

    // Group order items by their order_id
    final List<Map<String, Object?>> orderItemsMap = [];
    for (var i = 0; i < orderData.length; i++) {
      orderItemsMap.add({
        ...orderData[i],
        'order_items': orderItemsData
            .where((element) => element['order_id'] == orderData[i]['id'])
            .toList(),
      });
    }

    orders.addAll(orderItemsMap.map(Order.fromDatabase));

    loading.value = false; // Stop loading
  }

  Future<void> createOrder() async {
    await Get.toNamed(OrderManagementScreen.routeName,
        arguments: (currentType.value, null));

    getOrders();
  }

  Future<void> editOrder(Order order) async {
    await Get.toNamed(OrderManagementScreen.routeName,
        arguments: (currentType.value, order));

    getOrders();
  }
}
