import 'package:get/get.dart';

import '../models/order.dart';

final class OrderController extends GetxController {
  final currentPage = OrderType.sell.obs;
  final orders = <Order>[].obs;
  final loading = false.obs;
}
