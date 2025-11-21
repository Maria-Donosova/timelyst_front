import 'package:flutter/material.dart';

class DateTimeUtils {
  // Parse any date format (ISO string or timestamp)
  // Preserves local timezone to prevent unwanted conversions
  static DateTime parseAnyFormat(dynamic dateValue) {
    print('🔍 [DateTimeUtils.parseAnyFormat] Parsing: $dateValue (type: ${dateValue.runtimeType})');

    if (dateValue == null) {
      print('  ⚠️ Value is null, returning DateTime.now()');
      return DateTime.now();
    }

    try {
      // Check if it's a numeric timestamp (milliseconds since epoch)
      if (dateValue is num) {
        final result = DateTime.fromMillisecondsSinceEpoch(dateValue.toInt()).toLocal();
        print('  ✅ Parsed as timestamp: $result');
        return result;
      }
      if (dateValue is String && dateValue.contains(RegExp(r'^\d+$'))) {
        final result = DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue)).toLocal();
        print('  ✅ Parsed as string timestamp: $result');
        return result;
      }

      // Parse as ISO string
      final dateString = dateValue.toString();
      print('  - Original string: $dateString');

      // Backend returns times with timezone offset (e.g., "2024-11-21T14:30:00-05:00")
      // These represent the correct "wall clock time" in the event's timezone
      // We need to preserve those time components WITHOUT timezone conversion

      if (dateString.contains('+') || (dateString.contains('-') && dateString.lastIndexOf('-') > 10)) {
        // Has timezone offset info (e.g., "+05:00" or "-05:00")
        // Extract the datetime components directly from the string BEFORE parsing
        // to preserve the "wall clock time" that the backend sent
        final RegExp isoRegex = RegExp(
          r'(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?',
        );
        final match = isoRegex.firstMatch(dateString);

        if (match != null) {
          final year = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final day = int.parse(match.group(3)!);
          final hour = int.parse(match.group(4)!);
          final minute = int.parse(match.group(5)!);
          final second = int.parse(match.group(6)!);
          final millisecond = match.group(7) != null
            ? int.parse(match.group(7)!.padRight(3, '0').substring(0, 3))
            : 0;

          final result = DateTime(year, month, day, hour, minute, second, millisecond);
          print('  ✅ Preserved wall clock time from backend: $result');
          print('    - Extracted: $year-$month-$day $hour:$minute:$second');
          return result;
        }
        // Fallback if regex doesn't match
        final parsedDate = DateTime.parse(dateString);
        print('  ⚠️ Regex failed, using fallback parse: $parsedDate');
        return parsedDate;
      } else if (dateString.endsWith('Z')) {
        // UTC indicator - convert to local timezone
        final parsedDate = DateTime.parse(dateString);
        final result = parsedDate.toLocal();
        print('  ✅ UTC time, converted to local: $result');
        return result;
      } else {
        // No timezone info, treat as local time (don't convert)
        final parsedDate = DateTime.parse(dateString);
        print('  ✅ No timezone info, treating as local: $parsedDate');
        return parsedDate;
      }
    } catch (e) {
      print('❌ [DateTimeUtils] Error parsing date: $e');
      return DateTime.now(); // Fallback
    }
  }

  // Format date to ISO string for sending to API
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }

  // Parse time string to TimeOfDay
  static TimeOfDay parseTimeString(String timeString) {
    try {
      final normalizedTime = timeString.replaceAll(' ', ' ').trim();
      final regExp =
          RegExp(r'^(\d{1,2}):?(\d{2})?\s*([AP]M)?$', caseSensitive: false);
      final match = regExp.firstMatch(normalizedTime);

      if (match == null) {
        throw FormatException('Invalid time format: $timeString');
      }

      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3)?.toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $e');
      return TimeOfDay.now();
    }
  }
}
