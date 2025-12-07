
/// Utility class for parsing and working with RRULE (Recurrence Rule) strings
/// Follows RFC 5545 iCalendar specification
class RRuleParser {
  /// Parses an RRULE string and returns a RecurrenceInfo object
  /// Handles both "RRULE:FREQ=DAILY" and "FREQ=DAILY" formats
  static RecurrenceInfo? parseRRule(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;

    try {
      // Remove "RRULE:" prefix if present
      String ruleString = rrule.trim();
      if (ruleString.startsWith('RRULE:')) {
        ruleString = ruleString.substring(6);
      }

      // Parse components
      final parts = ruleString.split(';');
      String? frequency;
      int? count;
      DateTime? until;
      int interval = 1;
      List<String>? byDay;
      int? byMonthDay;
      int? byMonth;

      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length != 2) continue;

        final key = keyValue[0].trim();
        final value = keyValue[1].trim();

        switch (key) {
          case 'FREQ':
            frequency = value;
            break;
          case 'COUNT':
            count = int.tryParse(value);
            break;
          case 'UNTIL':
            until = _parseUntilDate(value);
            break;
          case 'INTERVAL':
            interval = int.tryParse(value) ?? 1;
            break;
          case 'BYDAY':
            byDay = value.split(',');
            break;
          case 'BYMONTHDAY':
            byMonthDay = int.tryParse(value);
            break;
          case 'BYMONTH':
            byMonth = int.tryParse(value);
            break;
        }
      }

      if (frequency == null) return null;

      return RecurrenceInfo(
        frequency: frequency,
        count: count,
        until: until,
        interval: interval,
        byDay: byDay,
        byMonthDay: byMonthDay,
        byMonth: byMonth,
      );
    } catch (e) {
      print('Error parsing RRULE: $e');
      return null;
    }
  }

  /// Parses UNTIL date from RRULE format (e.g., "20251231T235959Z")
  static DateTime? _parseUntilDate(String untilString) {
    try {
      // Format: YYYYMMDDTHHMMSSZ or YYYYMMDD
      if (untilString.contains('T')) {
        // Full datetime format
        final dateTimePart = untilString.replaceAll('Z', '');
        final year = int.parse(dateTimePart.substring(0, 4));
        final month = int.parse(dateTimePart.substring(4, 6));
        final day = int.parse(dateTimePart.substring(6, 8));
        final hour = int.parse(dateTimePart.substring(9, 11));
        final minute = int.parse(dateTimePart.substring(11, 13));
        final second = int.parse(dateTimePart.substring(13, 15));
        return DateTime.utc(year, month, day, hour, minute, second);
      } else {
        // Date only format
        final year = int.parse(untilString.substring(0, 4));
        final month = int.parse(untilString.substring(4, 6));
        final day = int.parse(untilString.substring(6, 8));
        return DateTime.utc(year, month, day);
      }
    } catch (e) {
      print('Error parsing UNTIL date: $e');
      return null;
    }
  }

  /// Calculates which occurrence number this event is
  /// Returns null if it cannot be determined
  static int? calculateOccurrenceNumber({
    required DateTime eventStart,
    DateTime? originalStart,
    required String rrule,
    DateTime? seriesStart,
  }) {
    final recurrenceInfo = parseRRule(rrule);
    if (recurrenceInfo == null) return null;

    // Use originalStart if available, otherwise use eventStart
    final targetDate = originalStart ?? eventStart;
    final startDate = seriesStart ?? eventStart;

    try {
      switch (recurrenceInfo.frequency) {
        case 'DAILY':
          return _calculateDailyOccurrence(startDate, targetDate, recurrenceInfo.interval);
        case 'WEEKLY':
          return _calculateWeeklyOccurrence(startDate, targetDate, recurrenceInfo.interval, recurrenceInfo.byDay);
        case 'MONTHLY':
          return _calculateMonthlyOccurrence(startDate, targetDate, recurrenceInfo.interval);
        case 'YEARLY':
          return _calculateYearlyOccurrence(startDate, targetDate, recurrenceInfo.interval);
        default:
          return null;
      }
    } catch (e) {
      print('Error calculating occurrence number: $e');
      return null;
    }
  }

  static int? _calculateDailyOccurrence(DateTime start, DateTime target, int interval) {
    final daysDiff = target.difference(start).inDays;
    if (daysDiff < 0) return null;
    return (daysDiff ~/ interval) + 1;
  }

  static int? _calculateWeeklyOccurrence(DateTime start, DateTime target, int interval, List<String>? byDay) {
    if (byDay == null || byDay.isEmpty) {
      // Simple weekly recurrence
      final weeksDiff = target.difference(start).inDays ~/ 7;
      if (weeksDiff < 0) return null;
      return (weeksDiff ~/ interval) + 1;
    }

    // Complex weekly with specific days
    // Count occurrences from start to target
    int occurrenceCount = 0;
    DateTime current = start;
    final targetDateOnly = DateTime(target.year, target.month, target.day);

    while (current.isBefore(targetDateOnly) || current.isAtSameMomentAs(targetDateOnly)) {
      if (_isOnByDay(current, byDay)) {
        occurrenceCount++;
        if (DateTime(current.year, current.month, current.day).isAtSameMomentAs(targetDateOnly)) {
          return occurrenceCount;
        }
      }
      current = current.add(Duration(days: 1));
      
      // Safety limit to prevent infinite loops
      if (occurrenceCount > 1000) break;
    }

    return null;
  }

  static int? _calculateMonthlyOccurrence(DateTime start, DateTime target, int interval) {
    final monthsDiff = (target.year - start.year) * 12 + (target.month - start.month);
    if (monthsDiff < 0) return null;
    return (monthsDiff ~/ interval) + 1;
  }

  static int? _calculateYearlyOccurrence(DateTime start, DateTime target, int interval) {
    final yearsDiff = target.year - start.year;
    if (yearsDiff < 0) return null;
    return (yearsDiff ~/ interval) + 1;
  }

  static bool _isOnByDay(DateTime date, List<String> byDay) {
    final dayMap = {
      'MO': DateTime.monday,
      'TU': DateTime.tuesday,
      'WE': DateTime.wednesday,
      'TH': DateTime.thursday,
      'FR': DateTime.friday,
      'SA': DateTime.saturday,
      'SU': DateTime.sunday,
    };

    for (final day in byDay) {
      if (dayMap[day.toUpperCase()] == date.weekday) {
        return true;
      }
    }
    return false;
  }

  /// Gets the total number of occurrences from the RRULE
  /// Returns null for infinite recurrence (no COUNT or UNTIL)
  static int? getTotalOccurrences(String rrule, DateTime startDate) {
    final recurrenceInfo = parseRRule(rrule);
    if (recurrenceInfo == null) return null;

    // If COUNT is specified, return it directly
    if (recurrenceInfo.count != null) {
      return recurrenceInfo.count;
    }

    // If UNTIL is specified, calculate based on frequency
    if (recurrenceInfo.until != null) {
      return _calculateOccurrencesUntil(startDate, recurrenceInfo.until!, recurrenceInfo);
    }

    // No COUNT or UNTIL means infinite recurrence
    return null;
  }

  static int? _calculateOccurrencesUntil(DateTime start, DateTime until, RecurrenceInfo info) {
    try {
      switch (info.frequency) {
        case 'DAILY':
          final days = until.difference(start).inDays;
          return (days ~/ info.interval) + 1;
        case 'WEEKLY':
          if (info.byDay != null && info.byDay!.isNotEmpty) {
            // Count specific days
            int count = 0;
            DateTime current = start;
            while (current.isBefore(until) || current.isAtSameMomentAs(until)) {
              if (_isOnByDay(current, info.byDay!)) {
                count++;
              }
              current = current.add(Duration(days: 1));
              if (count > 10000) break; // Safety limit
            }
            return count;
          } else {
            final weeks = until.difference(start).inDays ~/ 7;
            return (weeks ~/ info.interval) + 1;
          }
        case 'MONTHLY':
          final months = (until.year - start.year) * 12 + (until.month - start.month);
          return (months ~/ info.interval) + 1;
        case 'YEARLY':
          final years = until.year - start.year;
          return (years ~/ info.interval) + 1;
        default:
          return null;
      }
    } catch (e) {
      print('Error calculating occurrences until: $e');
      return null;
    }
  }
}

/// Represents parsed recurrence information from an RRULE
class RecurrenceInfo {
  final String frequency; // DAILY, WEEKLY, MONTHLY, YEARLY
  final int? count; // Number of occurrences
  final DateTime? until; // End date
  final int interval; // Interval between occurrences
  final List<String>? byDay; // Days of week (MO, TU, WE, etc.)
  final int? byMonthDay; // Day of month
  final int? byMonth; // Month of year

  RecurrenceInfo({
    required this.frequency,
    this.count,
    this.until,
    this.interval = 1,
    this.byDay,
    this.byMonthDay,
    this.byMonth,
  });

  /// Returns a human-readable description of the recurrence
  String getHumanReadableDescription() {
    final buffer = StringBuffer();

    // Frequency
    switch (frequency) {
      case 'DAILY':
        if (interval == 1) {
          buffer.write('Daily');
        } else {
          buffer.write('Every $interval days');
        }
        break;
      case 'WEEKLY':
        if (interval == 1) {
          buffer.write('Weekly');
        } else {
          buffer.write('Every $interval weeks');
        }
        if (byDay != null && byDay!.isNotEmpty) {
          buffer.write(' on ');
          buffer.write(_formatDaysList(byDay!));
        }
        break;
      case 'MONTHLY':
        if (interval == 1) {
          buffer.write('Monthly');
        } else {
          buffer.write('Every $interval months');
        }
        if (byMonthDay != null) {
          buffer.write(' on day $byMonthDay');
        }
        break;
      case 'YEARLY':
        if (interval == 1) {
          buffer.write('Yearly');
        } else {
          buffer.write('Every $interval years');
        }
        break;
      default:
        buffer.write(frequency);
    }

    return buffer.toString();
  }

  String _formatDaysList(List<String> days) {
    final dayNames = days.map((day) {
      switch (day.toUpperCase()) {
        case 'MO':
          return 'Mon';
        case 'TU':
          return 'Tue';
        case 'WE':
          return 'Wed';
        case 'TH':
          return 'Thu';
        case 'FR':
          return 'Fri';
        case 'SA':
          return 'Sat';
        case 'SU':
          return 'Sun';
        default:
          return day;
      }
    }).toList();

    if (dayNames.length == 1) {
      return dayNames.first;
    } else if (dayNames.length == 2) {
      return '${dayNames[0]} and ${dayNames[1]}';
    } else {
      final lastDay = dayNames.removeLast();
      return '${dayNames.join(', ')}, and $lastDay';
    }
  }
}
