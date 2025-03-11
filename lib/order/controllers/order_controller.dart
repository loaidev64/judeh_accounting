import 'package:get/get.dart';

enum Screen { sell, sellRefund, buy, buyRefund }

final class OrderController extends GetxController {
  final currentPage = Screen.sell.obs;
  final orders = <Order>[].obs;
  final loading = false.obs;
}
