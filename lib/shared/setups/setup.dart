import 'package:get/get.dart';
import 'package:judeh_accounting/customer/models/debt.dart';
import 'package:sqflite/sqflite.dart';

import '../../backup/models/backup.dart';
import '../../company/models/company.dart';
import '../../customer/models/customer.dart';
import '../../expense/models/expense.dart';
import '../../order/models/order.dart';
import '../../order/models/order_item.dart';
import '../category/models/category.dart';
import '../../material/models/material.dart';
import '../database/migration.dart';
// import 'package:csv/csv.dart';
// import '/service/data_service.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import '/helpers/database/query.dart';
// import '/helpers/database/schema.dart';
// import '/models/models.dart';
// import 'package:once/once.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import '/functions/logger.dart';
// import '/helpers/helpers.dart';

// part 'local_storage_helper_setup.dart';
// part 'server_setup.dart';
part 'database_setup.dart';
// part 'backup_setup.dart';

Future<void> setup() async {
  // final localStorageHelper = await _setupLocalStorageHelper();
  await _setupDatabase();
  // _setupServerHelper(localStorageHelper);
  // _setupBackup();
  // Bloc.observer = CustomBlocObserver();
}
