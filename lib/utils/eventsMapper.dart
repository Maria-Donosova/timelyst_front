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
      startTime = DateTime.parse(dayEvent.start);
      endTime = DateTime.parse(dayEvent.end);
      
      // Validate that dates are not too old (older than 2 years ago)
      final twoYearsAgo = DateTime.now().subtract(Duration(days: 730));
      if (startTime.isBefore(twoYearsAgo)) {
        print('⚠️ WARNING: Day event "${dayEvent.eventTitle}" has old date: ${dayEvent.start}');
      }
    } catch (e) {
      print('❌ ERROR: Failed to parse day event dates for "${dayEvent.eventTitle}": $e');
      print('❌ Start: ${dayEvent.start}, End: ${dayEvent.end}');
      // Use current time as fallback
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(hours: 1));
    }
    
    return CustomAppointment(
      id: dayEvent.id,
      title: dayEvent.eventTitle.isEmpty ? 'Untitled Event' : dayEvent.eventTitle,
      description: dayEvent.eventBody,
      startTime: startTime,
      endTime: endTime,
      // startTime:
      //     DateTime.parse(dayEvent.start['dateTime'] ?? dayEvent.start['date']),
      // endTime: DateTime.parse(dayEvent.end['dateTime'] ?? dayEvent.end['date']),
      isAllDay: dayEvent.is_AllDay,
      location: dayEvent.eventLocation,
      organizer:
          dayEvent.organizer['displayName'] ?? dayEvent.organizer['email'],
      recurrenceRule:
          dayEvent.recurrence.isEmpty ? null : dayEvent.recurrence.join(';'),
      catTitle: dayEvent.category,
      participants: dayEvent.participants,
      exceptionDates: dayEvent.exceptionDates.isEmpty
          ? null
          : dayEvent.exceptionDates.join(';'),
      userCalendars:
          dayEvent.userCalendars.isEmpty ? [] : dayEvent.userCalendars,
      timeEventInstance:
          dayEvent.dayEventInstance.isEmpty ? null : dayEvent.dayEventInstance,
      catColor:
          _getColorFromCategory(dayEvent.category), // Map category to color
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
      
      if (startTime.isBefore(tenYearsAgo) || startTime.isAfter(tenYearsFromNow)) {
        print('⚠️ WARNING: Time event "${timeEvent.eventTitle}" has unusual date: ${timeEvent.start}');
      }
      
      print('✅ Successfully parsed time event: "${timeEvent.eventTitle}" at $startTime');
      
    } catch (e) {
      print('❌ ERROR: Failed to parse time event dates for "${timeEvent.eventTitle}": $e');
      print('❌ Start: ${timeEvent.start}, End: ${timeEvent.end}');
      // Use current time as fallback
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(hours: 1));
    }

    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle.isEmpty ? 'Untitled Event' : timeEvent.eventTitle,
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
      recurrenceRule:
          timeEvent.recurrence.isEmpty ? null : timeEvent.recurrence.join(';'),
      exceptionDates: timeEvent.exceptionDates.isEmpty
          ? null
          : timeEvent.exceptionDates.join(';'),
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
    );
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
