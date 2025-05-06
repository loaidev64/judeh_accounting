import '../../shared/logger/app_logger.dart';
import '../controllers/pocketbase_controller.dart';

abstract class PocketbaseHelper {
  static Future<Future<void> Function()> polling<T>({
    String topic = '*',
    required String collectionName,
    required Function() onPoll,
  }) async {
    AppLogger.warning('listening to $collectionName for $topic');
    return await pocketbase().collection(collectionName).subscribe(topic,
        (event) {
      AppLogger.warning('$collectionName event triggered: $event');
      onPoll();
    });
  }
}
