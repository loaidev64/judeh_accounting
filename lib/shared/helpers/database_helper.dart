import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../backup/models/backup.dart';
import 'package:judeh_accounting/shared/models/database_model.dart';

abstract class DatabaseHelper {
  static Database getDatabase() => Get.find();

  /// Creates a new record in the specified table and generates a backup entry
  static Future<T> create<T extends DatabaseModel>({
    required T model,
    required String tableName,
  }) async {
    // Prepare data with null ID to allow auto-increment
    final data = {
      ...model.toDatabase,
      'createdAt': DateTime.now().toIso8601String(),
      'id': null,
    };

    final database = getDatabase();

    // Insert the main record
    final createdId = await database.insert(tableName, data);

    if (createdId <= 0) {
      throw Exception('Failed to create ${T.toString()} record');
    }

    // Update model with generated ID
    model.id = createdId;

    // Create backup entry unless creating a Backup record itself
    if (T != Backup) {
      await _createBackup(
        action: BackupAction.create,
        model: model,
        tableName: tableName,
        data: data,
      );
    }

    return model;
  }

  /// Updates an existing record and generates a backup entry
  static Future<T> update<T extends DatabaseModel>({
    required T model,
    required String tableName,
  }) async {
    // Prepare data with update timestamp
    final data = {
      ...model.toDatabase,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Create backup entry before update
    if (T != Backup) {
      await _createBackup(
        action: BackupAction.update,
        model: model,
        tableName: tableName,
        data: data,
      );
    }

    final database = getDatabase();
    final count = await database.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [model.id],
    );

    if (count == 0) {
      throw Exception('No records updated for ${T.toString()} ID ${model.id}');
    }

    return model;
  }

  /// Deletes a record and generates a backup entry
  static Future<void> delete<T extends DatabaseModel>({
    required T model,
    required String tableName,
  }) async {
    // Create backup entry before deletion
    if (T != Backup) {
      await _createBackup(
        action: BackupAction.delete,
        model: model,
        tableName: tableName,
        data: model.toDatabase,
      );
    }

    final database = getDatabase();
    try {
      final count = await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [model.id],
      );
      if (count == 0) {
        Get.printError(info: 'Failed to delete ${T.toString()} ID ${model.id}');
        throw Exception('Failed to delete ${T.toString()} ID ${model.id}');
      }
    } catch (e) {
      Get.printError(info: e.toString());
      Get.snackbar(
        'تحذير',
        'لا يمكنك الحذف',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Helper method to create consistent backup entries
  static Future<void> _createBackup<T extends DatabaseModel>({
    required BackupAction action,
    required T model,
    required String tableName,
    required Map<String, Object?> data,
  }) async {
    final backup = Backup(
      data: data,
      action: action,
      modelId: model.id,
      table: tableName,
      createdAt: DateTime.now(),
    );

    await getDatabase().insert(
      Backup.tableName,
      backup.toDatabase,
    );
  }
}
