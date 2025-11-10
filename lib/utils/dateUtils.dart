import 'package:flutter/material.dart';

class DateTimeUtils {
  // Parse any date format (ISO string or timestamp)
  // Always converts to local timezone to ensure proper display
  static DateTime parseAnyFormat(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    try {
      // Check if it's a numeric timestamp (milliseconds since epoch)
      if (dateValue is num) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue.toInt()).toLocal();
      }
      if (dateValue is String && dateValue.contains(RegExp(r'^\d+$'))) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue)).toLocal();
      }
      // Otherwise try parsing as ISO string and convert to local timezone
      return DateTime.parse(dateValue.toString()).toLocal();
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
