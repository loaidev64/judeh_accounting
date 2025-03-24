part of 'setup.dart';

Future<void> _setupBackup() async {
  await dotenv.load();
  CryptoHelper.initialize();
  Get.put(BackupController(), permanent: true);
}
