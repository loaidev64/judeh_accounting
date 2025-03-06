import 'package:get/get.dart';
import 'package:judeh_accounting/shared/models/database_model.dart';
import 'package:sqflite/sqflite.dart';
import '/shared/extensions/datetime.dart';

abstract class DatabaseHelper {
  static Database getDatabase() => Get.find();

  static Future<T> create<T extends DatabaseModel>({
    required T model,
    required String tableName,
  }) async {
    //FIXME:: change it later
    // if (this is! Backup) {
    //   final backup = Backup(
    //       data: {...toDatabase, 'created_at': createdAt.toFullString},
    //       action: 'create',
    //       modelId: 0,
    //       table: tableName);
    //   backup.save();
    // }

    final database = getDatabase();

    final createdId = await database.insert(tableName,
        {...model.toDatabase, 'created_at': DateTime.now().toIso8601String()});

    if (createdId > 0) {
      model.id = createdId;
      return model;
    }

    Get.printError(info: 'The model was not created');
    throw Exception('The model was not created');
  }

  static Future<T> update<T extends DatabaseModel>({
    required T model,
    required String tableName,
  }) async {
    // if (this is! BackupModel) {
    //   final backup = BackupModel(data: {
    //     ...toDatabase,
    //     'created_at': createdAt.toFullString,
    //     'updated_at': updatedAt?.toFullString ?? DateTime.now().toFullString
    //   }, action: 'update', modelId: id, table: tableName);
    //   backup.save();
    // }
    final database = getDatabase();
    final count = await database.update(tableName,
        {...model.toDatabase, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [model.id]);
    if (count == 0) {
      Get.printError(info: 'The model did not get updated');
    }

    return model;
  }
}
