import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order_item.dart';

extension SumList on List<OrderItem> {
  double get total {
    try {
      return map((e) => e.subTotal).reduce((value, element) => value + element);
    } catch (e) {
      Get.printError(info: e.toString());
      return 0;
    }
  }
}
