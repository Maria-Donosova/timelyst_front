// lib/utils/logger.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as logger;
import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late logger.Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = logger.Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      filter: ProductionFilter(),
    );
  }

  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.v(message, error: error, stackTrace: stackTrace);
    }
    developer.log('🐛 VERBOSE: $message',
        name: 'APP', level: 0, error: error, stackTrace: stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.d(message, error: error, stackTrace: stackTrace);
    }
    developer.log('💙 DEBUG: $message',
        name: 'APP', level: 1, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.i(message, error: error, stackTrace: stackTrace);
    developer.log('💚 INFO: $message',
        name: 'APP', level: 2, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.w(message, error: error, stackTrace: stackTrace);
    developer.log('💛 WARNING: $message',
        name: 'APP', level: 3, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
    developer.log('❤️ ERROR: $message',
        name: 'APP', level: 4, error: error, stackTrace: stackTrace);

    // Here you can add your crash reporting integration
    // Crashlytics.recordError(error, stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.wtf(message, error: error, stackTrace: stackTrace);
    developer.log('🖤 WTF: $message',
        name: 'APP', level: 5, error: error, stackTrace: stackTrace);
  }
}

// Shortcut functions for easier logging
void logV(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.v(message, error, stackTrace);
void logD(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.d(message, error, stackTrace);
void logI(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.i(message, error, stackTrace);
void logW(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.w(message, error, stackTrace);
void logE(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.e(message, error, stackTrace);
void logWtf(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    AppLogger.wtf(message, error, stackTrace);
