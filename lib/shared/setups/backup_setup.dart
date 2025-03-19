part of 'setup.dart';

Future<void> _setupBackup() async => await Workmanager().initialize(
      BackupController.callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
