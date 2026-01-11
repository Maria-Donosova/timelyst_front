import 'package:flutter/foundation.dart';

class LoggingConfig {
  /// Whether to log full API responses in VERBOSE level.
  /// Never logged in production.
  static bool get shouldLogApiResponses => kDebugMode && const bool.fromEnvironment('VERBOSE_LOGS', defaultValue: false);
  
  /// Whether to log cache hit/miss metrics in DEBUG level.
  static bool get shouldLogCacheMetrics => kDebugMode;
  
  /// Debounce duration for calendar rebuild logs to avoid spamming the console.
  static Duration rebuildLogDebounce = const Duration(milliseconds: 100);
}
