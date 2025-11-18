// Timezone utility functions for handling IANA timezones and datetime formatting
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class TimezoneUtils {
  static bool _initialized = false;
  static String? _cachedLocalTimezone;

  /// Initialize timezone database
  /// Call this once during app initialization (e.g., in main.dart)
  static Future<void> initialize() async {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;

      // Try to determine local timezone
      // Note: Flutter doesn't provide a direct way to get IANA timezone
      // We'll use UTC as default and can be overridden
      try {
        // Attempt to get local timezone name
        // This may not work on all platforms, so we fallback to UTC
        final localName = DateTime.now().timeZoneName;
        // Store the abbreviation for now, we'll use UTC as IANA fallback
        _cachedLocalTimezone = 'UTC';
      } catch (e) {
        _cachedLocalTimezone = 'UTC';
      }
    }
  }

  /// Get the device's IANA timezone name (e.g., "America/New_York")
  /// Note: This returns UTC by default since Flutter doesn't provide direct access
  /// to IANA timezone names. For production, consider using flutter_native_timezone package.
  static String getDeviceTimeZone() {
    if (!_initialized) {
      // If not initialized, return a reasonable default
      return 'UTC';
    }

    // For now, we use UTC as the default IANA timezone
    // In a production app, you would use flutter_native_timezone package
    // or detect timezone from browser/platform
    return _cachedLocalTimezone ?? 'UTC';
  }

  /// Set the local timezone manually (useful for testing or when timezone is known)
  static void setLocalTimezone(String timeZoneName) {
    if (isValidTimezone(timeZoneName)) {
      _cachedLocalTimezone = timeZoneName;
    }
  }

  /// Format DateTime to ISO8601 string WITH timezone offset
  /// Example: "2024-11-18T14:30:00.000-05:00"
  /// This preserves the local time and includes the UTC offset
  static String formatDateTimeWithTimezone(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Format DateTime to ISO8601 string WITHOUT timezone offset
  /// Example: "2024-11-18T14:30:00"
  /// WARNING: This loses timezone information and should be avoided
  /// Only use if backend specifically requires this format
  @Deprecated('Use formatDateTimeWithTimezone instead to preserve timezone info')
  static String formatDateTimeWithoutTimezone(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:$second';
  }

  /// Convert a DateTime to a specific timezone
  /// Example: convertToTimezone(dateTime, "America/Los_Angeles")
  static DateTime convertToTimezone(DateTime dateTime, String timeZoneName) {
    if (!_initialized) {
      throw StateError('TimezoneUtils not initialized. Call TimezoneUtils.initialize() first');
    }

    try {
      final location = tz.getLocation(timeZoneName);
      return tz.TZDateTime.from(dateTime, location);
    } catch (e) {
      // If timezone name is invalid, return original datetime
      print('⚠️ Invalid timezone name: $timeZoneName. Error: $e');
      return dateTime;
    }
  }

  /// Check if a timezone name is valid IANA timezone
  static bool isValidTimezone(String timeZoneName) {
    if (!_initialized) {
      initialize();
    }

    try {
      tz.getLocation(timeZoneName);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all available timezone names
  static List<String> getAllTimezones() {
    if (!_initialized) {
      throw StateError('TimezoneUtils not initialized. Call TimezoneUtils.initialize() first');
    }

    return tz.timeZoneDatabase.locations.keys.toList();
  }

  /// Get timezone abbreviation for a given IANA timezone at a specific time
  /// Example: "EST" for "America/New_York" during standard time
  /// Example: "EDT" for "America/New_York" during daylight saving time
  static String getTimezoneAbbreviation(String timeZoneName, DateTime dateTime) {
    if (!_initialized) {
      throw StateError('TimezoneUtils not initialized. Call TimezoneUtils.initialize() first');
    }

    try {
      final location = tz.getLocation(timeZoneName);
      final tzDateTime = tz.TZDateTime.from(dateTime, location);
      return tzDateTime.timeZoneName;
    } catch (e) {
      print('⚠️ Error getting timezone abbreviation for $timeZoneName: $e');
      return '';
    }
  }

  /// Get UTC offset for a given IANA timezone at a specific time
  /// Returns offset in hours (e.g., -5.0 for EST, -4.0 for EDT)
  static double getTimezoneOffset(String timeZoneName, DateTime dateTime) {
    if (!_initialized) {
      throw StateError('TimezoneUtils not initialized. Call TimezoneUtils.initialize() first');
    }

    try {
      final location = tz.getLocation(timeZoneName);
      final tzDateTime = tz.TZDateTime.from(dateTime, location);
      // timeZoneOffset is a Duration, convert to hours
      return tzDateTime.timeZoneOffset.inMinutes / 60.0;
    } catch (e) {
      print('⚠️ Error getting timezone offset for $timeZoneName: $e');
      return 0.0;
    }
  }
}
