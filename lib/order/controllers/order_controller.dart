import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/order/screens/order_management_screen.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../models/order.dart';

final class OrderController extends GetxController {
  final currentType = OrderType.sell.obs;
  final orders = <Order>[].obs;
  final loading = false.obs;

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
      OrderItem.tableName,
      where: 'order_id IN (${List.filled(orderIds.length, '?').join(',')})',
      whereArgs: orderIds,
    );

    // Group order items by their order_id
    final Map<int, List<OrderItem>> orderItemsMap = {};
    for (var i = 0; i < orderData.length; i++) {
      orderData[i]['order_items'] = orderItemsData
          .where((element) => element['order_id'] == orderData[i]['id'])
          .toList();
    }
    for (final itemData in orderItemsData) {
      final orderItem = OrderItem.fromDatabase(itemData);
      final orderId = orderItem.orderId;

      if (orderItemsMap.containsKey(orderId)) {
        orderItemsMap[orderId]!.add(orderItem);
      } else {
        orderItemsMap[orderId] = [orderItem];
      }
    }

    orders.addAll(orderData.map(Order.fromDatabase));

    loading.value = false; // Stop loading
  }

  Future<void> createOrder() async {
    await Get.toNamed(OrderManagementScreen.routeName,
        arguments: (currentType.value, null));

    getOrders();
  }

  Future<void> editOrder() async {}
}
