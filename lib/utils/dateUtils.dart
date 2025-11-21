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
      final parsedDate = DateTime.parse(dateString);
      print('  - Parsed ISO string: $parsedDate');
      print('  - parsedDate.isUtc: ${parsedDate.isUtc}');

      // Only convert to local if the string explicitly contains UTC indicator (Z or +00:00)
      // Otherwise, treat it as already being in local time to prevent timezone shifts
      if (dateString.endsWith('Z') || dateString.contains('+') || dateString.contains('-')) {
        // Has timezone info, convert to local
        final result = parsedDate.toLocal();
        print('  ✅ Has timezone info, converted to local: $result');
        print('    - result.timeZoneName: ${result.timeZoneName}');
        print('    - result.timeZoneOffset: ${result.timeZoneOffset}');
        return result;
      } else {
        // No timezone info, treat as local time (don't convert)
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
