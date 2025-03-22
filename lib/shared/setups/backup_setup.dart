part of 'setup.dart';

Future<void> _setupBackup() async {
  Get.put(BackupController(), permanent: true);
  await Workmanager().initialize(
    BackupController.callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
}
