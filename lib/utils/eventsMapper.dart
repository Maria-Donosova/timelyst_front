import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../models/dayEvent.dart';
import '../../utils/dateUtils.dart';

class EventMapper {
  static CustomAppointment mapDayEventToCustomAppointment(DayEvent dayEvent) {
    DateTime startTime;
    DateTime endTime;

    try {
      // Parse dates preserving local timezone (no conversion to prevent time shifts)
      startTime = DateTimeUtils.parseAnyFormat(dayEvent.start);
      endTime = DateTimeUtils.parseAnyFormat(dayEvent.end);

      // Validate that dates are not too old (older than 2 years ago)
      final twoYearsAgo = DateTime.now().subtract(Duration(days: 730));
      if (startTime.isBefore(twoYearsAgo)) {
        print(
            '⚠️ WARNING: Day event "${dayEvent.eventTitle}" has old date: ${dayEvent.start}');
      }
    } catch (e) {
      print(
          '❌ ERROR: Failed to parse day event dates for "${dayEvent.eventTitle}": $e');
      print('❌ Start: ${dayEvent.start}, End: ${dayEvent.end}');
      // Use current time as fallback
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(hours: 1));
    }

    // Debug logging for source information
    print('🔍 [EventMapper] Mapping DayEvent: "${dayEvent.eventTitle}"');
    print('  - source: ${dayEvent.source}');
    print('  - googleEventId: "${dayEvent.googleEventId}"');
    print('  - microsoftEventId: "${dayEvent.microsoftEventId}"');
    print('  - appleEventId: "${dayEvent.appleEventId}"');
    print('  - calendarId: "${dayEvent.calendarId}"');
    print('  - createdBy: "${dayEvent.createdBy}"');

    return CustomAppointment(
      id: dayEvent.id,
      title:
          dayEvent.eventTitle.isEmpty ? 'Untitled Event' : dayEvent.eventTitle,
      description: dayEvent.eventBody,
      startTime: startTime,
      endTime: endTime,
      // startTime:
      //     DateTime.parse(dayEvent.start['dateTime'] ?? dayEvent.start['date']),
      // endTime: DateTime.parse(dayEvent.end['dateTime'] ?? dayEvent.end['date']),
      isAllDay: dayEvent.is_AllDay,
      location: dayEvent.eventLocation,
      organizer: dayEvent.organizer['displayName'] ??
          dayEvent.organizer['email'] ??
          '',
      recurrenceRule: dayEvent.recurrence.isEmpty
          ? null
          : _formatRecurrenceRule(dayEvent.recurrence.join(';')),
      catTitle: dayEvent.category,
      participants: dayEvent.participants,
      recurrenceExceptionDates:
          _parseExceptionDates(dayEvent.recurrenceExceptionDates),
      userCalendars:
          dayEvent.userCalendars.isEmpty ? [] : dayEvent.userCalendars,
      timeEventInstance:
          dayEvent.dayEventInstance.isEmpty ? null : dayEvent.dayEventInstance,
      catColor:
          _getColorFromCategory(dayEvent.category), // Map category to color
      // Enhanced calendar source information
      createdBy: dayEvent.createdBy.isEmpty ? null : dayEvent.createdBy,
      sourceCalendar: dayEvent.calendarId.isEmpty ? null : dayEvent.calendarId,
      calendarId: dayEvent.calendarId.isEmpty ? null : dayEvent.calendarId,
      source: dayEvent.source,
      googleEventId:
          dayEvent.googleEventId.isEmpty ? null : dayEvent.googleEventId,
      microsoftEventId: dayEvent.microsoftEventId,
      appleEventId: dayEvent.appleEventId,
    );
  }

  static CustomAppointment mapTimeEventToCustomAppointment(
      TimeEvent timeEvent) {
    DateTime startTime;
    DateTime endTime;

    try {
      // Parse start time with improved error handling
      startTime = DateTimeUtils.parseAnyFormat(timeEvent.start);
      endTime = DateTimeUtils.parseAnyFormat(timeEvent.end);

      // Validate reasonable date range (not in far future or past)
      final now = DateTime.now();
      final tenYearsAgo = now.subtract(Duration(days: 3650));
      final tenYearsFromNow = now.add(Duration(days: 3650));

      if (startTime.isBefore(tenYearsAgo) ||
          startTime.isAfter(tenYearsFromNow)) {
        print(
            '⚠️ WARNING: Time event "${timeEvent.eventTitle}" has unusual date: ${timeEvent.start}');
      }
    } catch (e) {
      print(
          '❌ ERROR: Failed to parse time event dates for "${timeEvent.eventTitle}": $e');
      print('❌ Start: ${timeEvent.start}, End: ${timeEvent.end}');
      // Use current time as fallback
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(hours: 1));
    }

    // Debug logging for source information
    print('🔍 [EventMapper] Mapping TimeEvent: "${timeEvent.eventTitle}"');
    print('  - source: ${timeEvent.source}');
    print('  - googleEventId: "${timeEvent.googleEventId}"');
    print('  - microsoftEventId: "${timeEvent.microsoftEventId}"');
    print('  - appleEventId: "${timeEvent.appleEventId}"');
    print('  - calendarId: "${timeEvent.calendarId}"');
    print('  - createdBy: "${timeEvent.createdBy}"');

    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle.isEmpty
          ? 'Untitled Event'
          : timeEvent.eventTitle,
      description: timeEvent.eventBody,
      startTime: startTime,
      endTime: endTime,
      isAllDay: timeEvent.is_AllDay,
      location: timeEvent.eventLocation,
      // ignore: unnecessary_null_comparison
      organizer: timeEvent.organizer != null
          ? (timeEvent.organizer['displayName'] ??
              timeEvent.organizer['email'] ??
              '')
          : '',
      recurrenceRule: timeEvent.recurrence.isEmpty
          ? null
          : _formatRecurrenceRule(timeEvent.recurrence.join(';')),
      recurrenceExceptionDates:
          _parseExceptionDates(timeEvent.recurrenceExceptionDates),
      catTitle: timeEvent.category,
      participants: timeEvent.participants,
      userCalendars:
          timeEvent.userCalendars.isEmpty ? [] : timeEvent.userCalendars,
      timeEventInstance: timeEvent.timeEventInstances.isEmpty ||
              timeEvent.timeEventInstances[0].isEmpty
          ? null
          : timeEvent.timeEventInstances[0],
      catColor:
          _getColorFromCategory(timeEvent.category), // Map category to color
      // Enhanced calendar source information
      createdBy: timeEvent.createdBy.isEmpty ? null : timeEvent.createdBy,
      sourceCalendar:
          timeEvent.calendarId.isEmpty ? null : timeEvent.calendarId,
      calendarId: timeEvent.calendarId.isEmpty ? null : timeEvent.calendarId,
      source: timeEvent.source,
      googleEventId:
          timeEvent.googleEventId.isEmpty ? null : timeEvent.googleEventId,
      microsoftEventId: timeEvent.microsoftEventId,
      appleEventId: timeEvent.appleEventId,
    );
  }

  // Helper function to parse exception dates from string list to DateTime list
  static List<DateTime>? _parseExceptionDates(List<String> exceptionDates) {
    if (exceptionDates.isEmpty) return null;

    try {
      return exceptionDates.map((dateStr) {
        return DateTimeUtils.parseAnyFormat(dateStr);
      }).toList();
    } catch (e) {
      print('⚠️ Error parsing exception dates: $e');
      return null;
    }
  }

  // Helper function to format recurrence rule for Syncfusion
  static String _formatRecurrenceRule(String rule) {
    if (rule.isEmpty) return '';

    // Clean up the rule - remove any extra RRULE: prefixes
    rule = rule.replaceAll(RegExp(r'RRULE:'), '').trim();

    // Add single RRULE: prefix
    rule = 'RRULE:$rule';

    // Ensure the rule is properly formatted for Syncfusion
    // Common formats: RRULE:FREQ=DAILY;COUNT=5 or RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR
    if (!rule.contains('FREQ=')) {
      return '';
    }

    // For recurring events without an end date, add a reasonable end date
    // Google Calendar events without UNTIL or COUNT should repeat indefinitely
    // But Syncfusion might need an explicit end date for proper rendering
    if (!rule.contains('UNTIL=') && !rule.contains('COUNT=')) {
      // Add a far future date (2 years from now) to ensure events show up
      final futureDate = DateTime.now().add(Duration(days: 730));
      final untilDate =
          futureDate.toIso8601String().substring(0, 8).replaceAll('-', '') +
              'T000000Z';
      rule = '$rule;UNTIL=$untilDate';
    }

    return rule;
  }

  // Helper function to map category to a color
  static Color _getColorFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'meeting':
        return Colors.blue;
      case 'holiday':
        return Colors.red;
      case 'personal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
