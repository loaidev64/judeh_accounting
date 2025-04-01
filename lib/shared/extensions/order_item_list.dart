import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../material/models/material.dart';

extension OrderItemList on List<OrderItem> {
  double get total {
    try {
      return map((e) => e.subTotal).reduce((value, element) => value + element);
    } catch (e) {
      Get.printError(info: e.toString());
      return 0;
    }
  }

  Future<void> delete(OrderType type) async {
    final database = DatabaseHelper.getDatabase();
    for (final element in this) {
      if (type == OrderType.sell) {
        await database.rawUpdate('''
          UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
          ''', [element.quantity, element.materialId]);
      } else if (type == OrderType.sellRefund) {
        // it will be sell Refund
        await database.rawUpdate('''
          UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
          ''', [element.quantity, element.materialId]);
      } else if (type == OrderType.buy) {
        await database.rawUpdate('''
        UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
        ''', [element.quantity, element.materialId]);
      } else {
        // it will be buy Refund
        await database.rawUpdate('''
        UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
        ''', [element.quantity, element.materialId]);
      }

      await DatabaseHelper.delete(
          model: element, tableName: OrderItem.tableName);
    }
  }
}
