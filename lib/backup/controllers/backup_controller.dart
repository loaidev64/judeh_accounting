import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:once/once.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/helpers/database_helper.dart';
import '../models/backup.dart';
import '../../shared/helpers/crypto_helper.dart';

class BackupController extends GetxController {
  static const _backupTask = "hourlyBackup";
  final _database = DatabaseHelper.getDatabase();

  @override
  void onInit() {
    _callbackDispatcher();
    super.onInit();
  }

  void _callbackDispatcher() async => await Once.runHourly(
        _backupTask,
        callback: _createEncryptedBackup,
        debugCallback: kDebugMode,
      );

  Future<void> _createEncryptedBackup() async {
    try {
      final backups = await _database.query(Backup.tableName);
      final jsonData = jsonEncode(backups);
      final encryptedData = CryptoHelper.encrypt(jsonData);

      final directory = await getDownloadsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath =
          '${directory?.path}/judeh_accounting/backup_$timestamp.enc';
      final file = File(filePath)..createSync(recursive: true);

      Get.printInfo(info: filePath);

      await file.writeAsString(encryptedData);

      Get.snackbar('نجاح', 'تم بنجاح حفظ نسخة احتياطية جديدة',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('خطأ', 'لم يتم حفظ نسخة احتياطية بنجاح',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      Get.printError(info: 'backup error: $e');
    }
  }
}
