import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:judeh_accounting/customer/models/debt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import '../../backup/controllers/backup_controller.dart';
import '../../backup/models/backup.dart';
import '../../company/models/company.dart';
import '../../customer/models/customer.dart';
import '../../expense/models/expense.dart';
import '../../order/models/order.dart';
import '../../order/models/order_item.dart';
import '../category/models/category.dart';
import '../../material/models/material.dart';
import '../database/migration.dart';

part 'database_setup.dart';
part 'backup_setup.dart';

Future<void> setup() async {
  // final localStorageHelper = await _setupLocalStorageHelper();
  await _setupDatabase();
  await _setupBackup();
  // _setupServerHelper(localStorageHelper);
  // _setupBackup();
  // Bloc.observer = CustomBlocObserver();
}
