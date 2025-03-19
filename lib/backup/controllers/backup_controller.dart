import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/helpers/database_helper.dart';
import '../models/backup.dart';
import '../../shared/helpers/crypto_helper.dart';

class BackupController extends GetxController {
  static const _backupTask = "hourlyBackup";
  final _database = DatabaseHelper.getDatabase();

  @override
  void onReady() {
    Workmanager().registerPeriodicTask(
      "1",
      _backupTask,
      frequency: const Duration(hours: 1),
    );
    super.onReady();
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == _backupTask) {
        final controller = Get.put(BackupController());
        await controller._createEncryptedBackup();
        return true;
      }
      return false;
    });
  }

  Future<void> _createEncryptedBackup() async {
    try {
      final backups = await _database.query(Backup.tableName);
      final jsonData = jsonEncode(backups);
      final encryptedData = CryptoHelper.encrypt(jsonData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/backup_$timestamp.enc');

      await file.writeAsString(encryptedData);

      Get.snackbar('Success', 'Backup created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create backup: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }
}
