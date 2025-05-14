import 'package:get/get.dart';
import '../../shared/logger/app_logger.dart';
import '../../shared/snackbar/snackbar_helper.dart';
import '../constants/pocketbase_collections.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_server_flutter/pocketbase_server_flutter.dart';

class PocketbaseController extends GetxController {
  String? _localIpAddress;

  String? get ipAddress => _localIpAddress;

  static const adminEmail = 'test@test.com';

  static const adminPassword = 'password';

  static const port = '8089';

  @override
  void onInit() {
    // stopServer();
    startServer();
    super.onInit();
  }

  void startServer() async {
    _localIpAddress = await PocketbaseServerFlutter.localIpAddress;
    if((await PocketbaseServerFlutter.isRunning)!) {
      if (_localIpAddress != null) {
        pocketbase.baseURL = 'http://$_localIpAddress:$port';
        // await _storage.setString(
        //     LocalStorageHelper.keys.ipServer, pocketbase.baseURL);

        loginAsAdmin();
      }
      return;
    }

    await PocketbaseServerFlutter.start(
      superUserEmail: adminEmail,
      superUserPassword: adminPassword,
      port: port,
      hostName: _localIpAddress,
    );

    if (_localIpAddress != null) {
      pocketbase.baseURL = 'http://$_localIpAddress:$port';
      // await _storage.setString(
      //     LocalStorageHelper.keys.ipServer, pocketbase.baseURL);

      loginAsAdmin();
    }

    _loadIpServer();

    update();
  }

  void stopServer() async {
    if(!(await PocketbaseServerFlutter.isRunning)!) return;
    await PocketbaseServerFlutter.stop();
  }

  final pocketbase = PocketBase('');

  // final _storage = LocalStorageHelper.storage;
  void _loadIpServer() async {
    // pocketbase.baseURL =
    //      _storage.getString(LocalStorageHelper.keys.ipServer) ?? '';
    pocketbase.baseURL = 'http://$_localIpAddress:$port';

    try {
      await GetConnect().get('${pocketbase.baseURL}/_/');
    } catch (_) {
      // await _storage.remove(LocalStorageHelper.keys.ipServer);
      SnackbarHelper.error(
          description:
              'لقد تم فقدان الاتصال بالجهاز. تأكد من انك على نفس شبكة الجهاز وان الجهاز يعمل.');
    }
  }

  void loginAsAdmin() async {
    await pocketbase
      .collection(PocketbaseCollections.superusers)
      .authWithPassword(adminEmail, adminPassword);

    AppLogger.info('Logged in successfully');
  }
}

PocketBase pocketbase() => Get.find<PocketbaseController>().pocketbase;
