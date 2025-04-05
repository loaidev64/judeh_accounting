import 'package:get/get.dart';
import 'package:judeh_accounting/order/screens/order_management_screen.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';

import '../../company/models/company.dart';
import '../../customer/models/customer.dart';
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

    Get.printInfo(info: (await database.query('customers')).toString());

    // Fetch orders based on the current type
    final orderData = await database.query(
      'orders LEFT JOIN debts ON orders.id = debts.order_id',
      where: 'type = ?',
      columns: [
        'orders.id',
        'orders.customer_id',
        'orders.company_id',
        'orders.type',
        'orders.total',
        'orders.createdAt',
        'orders.updatedAt',
        'debts.amount AS debt_amount',
      ],
      whereArgs: [currentType.value.index],
      limit: 25,
    );

    // If no orders are found, clear the list and return
    if (orderData.isEmpty) {
      return;
    }

    final data = <Map<String, Object?>>[];
    if (currentType.value.canHaveCustomer) {
      final customerIds = orderData
          .where((element) => element['customer_id'] != null)
          .map((e) => e['customer_id'])
          .toList();
      final customers = await database.query(
        Customer.tableName,
        distinct: true,
        columns: ['id', 'name'],
        where:
            'id in (${List.generate(customerIds.length, (_) => '?').join(',')})',
        whereArgs: customerIds,
      );
      data.addAll(customers);
    } else {
      final companyIds = orderData
          .where((element) => element['company_id'] != null)
          .map((e) => e['company_id'])
          .toList();
      final companies = await database.query(
        Company.tableName,
        distinct: true,
        columns: ['id', 'name'],
        where:
            'id in (${List.generate(companyIds.length, (_) => '?').join(',')})',
        whereArgs: companyIds,
      );
      data.addAll(companies);
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
        if (!currentType.value.canHaveCustomer)
          'company_name': data.firstWhere(
              (element) => element['id'] == orderData[i]['company_id'])['name'],
        if (currentType.value.canHaveCustomer)
          'customer_name': data.firstWhere((element) =>
              element['id'] == orderData[i]['customer_id'])['name'],
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
