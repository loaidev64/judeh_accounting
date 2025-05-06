import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SnackbarHelper {
  static void error({String title = 'خطأ', required String description}) =>
      Get.snackbar(
        title,
        description,
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );

  static void success({String title = 'نجاح', required String description}) =>
      Get.snackbar(
        title,
        description,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
}
