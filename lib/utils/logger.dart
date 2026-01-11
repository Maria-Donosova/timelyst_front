import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as logger;
import 'package:logger/logger.dart';

enum LogLevel { error, warn, info, debug, verbose }

class LogService {
  static LogLevel currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static final logger.Logger _prettyLogger = logger.Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final logger.Logger _simpleLogger = logger.Logger(
    printer: SimplePrinter(
      colors: true,
      printTime: true,
    ),
  );

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (currentLevel.index >= LogLevel.error.index) {
      _prettyLogger.e('[$tag] $message', error: error, stackTrace: stackTrace);
      developer.log('❤️ ERROR [$tag]: $message', name: tag, level: 4, error: error, stackTrace: stackTrace);
    }
  }

  static void warn(String tag, String message) {
    if (currentLevel.index >= LogLevel.warn.index) {
      _prettyLogger.w('[$tag] $message');
      developer.log('💛 WARN [$tag]: $message', name: tag, level: 3);
    }
  }

  static void info(String tag, String message) {
    if (currentLevel.index >= LogLevel.info.index) {
      _simpleLogger.i('💚 [$tag] $message');
      developer.log('💚 INFO [$tag]: $message', name: tag, level: 2);
    }
  }

  static void debug(String tag, String message) {
    if (currentLevel.index >= LogLevel.debug.index) {
      _simpleLogger.d('💙 [$tag] $message');
      developer.log('💙 DEBUG [$tag]: $message', name: tag, level: 1);
    }
  }

  static void verbose(String tag, String message) {
    if (currentLevel.index >= LogLevel.verbose.index) {
      _simpleLogger.t('📝 [$tag] $message');
      developer.log('📝 VERBOSE [$tag]: $message', name: tag, level: 0);
    }
  }
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.verbose('APP', message.toString());
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.debug('APP', message.toString());
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.info('APP', message.toString());
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.warn('APP', message.toString());
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.error('APP', message.toString(), error, stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    LogService.error('WTF', message.toString(), error, stackTrace);
  }

  /// Performance-specific logging that can be easily disabled
  static void performance(dynamic message, [String? tag]) {
    LogService.debug(tag ?? 'PERF', message.toString());
  }

  /// Debug logging that can be easily disabled (for hot code paths)
  static void debug(dynamic message, [String? tag]) {
    LogService.debug(tag ?? 'DEBUG', message.toString());
  }

  /// Verbose logging that can be easily disabled (most chatty logs)
  static void verbose(dynamic message, [String? tag]) {
    LogService.verbose(tag ?? 'VERBOSE', message.toString());
  }
}

// Shortcut functions for easier logging
void logV(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.verbose('APP', message.toString());
void logD(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.debug('APP', message.toString());
void logI(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.info('APP', message.toString());
void logW(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.warn('APP', message.toString());
void logE(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.error('APP', message.toString(), error, stackTrace);
void logWtf(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    LogService.error('WTF', message.toString(), error, stackTrace);
