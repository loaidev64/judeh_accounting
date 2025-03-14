import 'package:flutter/material.dart' hide Material;
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../material/models/material.dart';

final class OrderManagementController extends GetxController {
  final loading = false.obs;

  Order? order;

  late OrderType type;

  final items = <OrderItem>[].obs;

  final material = Material.empty().obs;

  final materialController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onClose() {
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    final (OrderType orderType, Order? order) = Get.arguments;
    type = orderType;
    this.order = order;

    super.onInit();
  }

  void _reset() {
    material.value = Material.empty();
    materialController.clear();
    quantityController.clear();
    priceController.clear();

    Get.printInfo(info: 'reseting...');
  }

  Future<List<Material>> returnMaterials([String? search]) async {
    final database = DatabaseHelper.getDatabase();
    final List<Map<String, Object?>> data;
    if (search == null) {
      data = await database.query(Material.tableName, limit: 25);
    } else {
      data = await database.query(
        Material.tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$search%'],
        limit: 25,
      );
    }

    return data.map(Material.fromDatabase).toList();
  }

  Future<void> addItem() async {
    if (material.value.isEmpty) {
      Get.snackbar(
        'تحذير',
        'يجب عليك اختيار منتج اولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    items.add(OrderItem(
      materialId: material.value.id,
      materialName: material.value.name,
      price: double.parse(priceController.text),
      quantity: double.parse(quantityController.text),
      orderId: 0, // just for now and later will change it
    ));
    _reset();
  }

  Future<void> create() async {}
}
