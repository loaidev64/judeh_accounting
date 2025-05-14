import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/order/screens/order_management_screen.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/logger/app_logger.dart';

import '../../company/models/company.dart';
import '../../customer/models/customer.dart';
import '../../pocketbase/constants/pocketbase_collections.dart';
import '../../pocketbase/controllers/pocketbase_controller.dart';
import '../../pocketbase/helpers/pocketbase_helper.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final currentType = OrderType.sell.obs;
  final orders = <Order>[].obs;
  final loading = false.obs;

  final _orderViewPocketbase = pocketbase().collection(PocketbaseCollections.ordersView);
  final _orderItemsViewPocketbase = pocketbase().collection(PocketbaseCollections.orderItemsView);
  final _companyPocketbase = pocketbase().collection(PocketbaseCollections.companies);
  final _customersPocketbase = pocketbase().collection(PocketbaseCollections.customers);

  late final Future<void> Function() unsubscribeToPolling;

  @override
  void onInit() async{
    getOrders();
    unsubscribeToPolling = await PocketbaseHelper.polling(
        collectionName: PocketbaseCollections.orderItems, onPoll: getOrders);
    super.onInit();
  }

  @override
  void onClose() {
    unsubscribeToPolling();
    super.onClose();
  }

  void changeType(OrderType type) {
    currentType.value = type;

    getOrders();
  }

  void getOrders() async {
    orders.clear();
    loading.value = true; // Start loading

    var response = await _orderViewPocketbase.getList(
      perPage: 25,
      filter: 'type = ${currentType.value.index}',
    );

    // Group order items by their order_id
    final orderItemsMap = response.items.map((e) => e.data);
    var _orders = orderItemsMap.map(Order.fromDatabase);
    if(currentType.value.canHaveCustomer){
      response = await _customersPocketbase.getList(
        perPage: 25,
        filter: _orders.where((element) => element.customerId != null).map((element) => 'id="${element.customerId}"').join('||'),
        fields: 'id,name',
      );
      _orders = _orders.map((e) => e.copyWith(
        customerName: response.items.map((e) => e.data).where((element) => element['id'] == e.customerId).firstOrNull?['name'],
      ));
    }else{
    response = await _companyPocketbase.getList(
      perPage: 25,
      filter: _orders.where((element) => element.companyId != null).map((element) => 'id="${element.companyId}"').join('||'),
      fields: 'id,name',
    );
    _orders = _orders.map((e) => e.copyWith(
      companyName: response.items.map((e) => e.data).where((element) => element['id'] == e.companyId).firstOrNull?['name'],
    ));
    }
    if(_orders.isNotEmpty){
      final res = await _orderItemsViewPocketbase.getFullList(
        batch: 1000,
        filter: _orders.map((element) => 'order_id="${element.id}"').join('||'),
      );

      for(final order in _orders){
        orders.add(order.copyWith(
          items: res.where((element) => element.data['order_id'] == order.id).map((e) => OrderItem.fromDatabase(e.data)).toList(),
        ));
      }
    }

    loading.value = false; // Stop loading
  }

  Future<void> createOrder() async => await Get.toNamed(OrderManagementScreen.routeName,
        arguments: (currentType.value, null));

  Future<void> editOrder(Order order) async => await Get.toNamed(OrderManagementScreen.routeName,
        arguments: (currentType.value, order));
}
