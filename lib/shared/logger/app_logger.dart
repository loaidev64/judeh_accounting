import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

abstract class AppLogger {
  static final _logger = Logger();

  static info(message) => _logger.i(message);

  static exception(message, [StackTrace? trace]) =>
      _logger.e(message, stackTrace: trace);

  static warning(message) => _logger.w(message);

  static initializeLoggerForFlutterError() => FlutterError.onError = (error) {
        exception(error.exception, error.stack);
      };
}
