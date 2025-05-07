import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../models/dayEvent.dart';
import '../../utils/date_utils.dart';

class EventMapper {
  static CustomAppointment mapDayEventToCustomAppointment(DayEvent dayEvent) {
    return CustomAppointment(
      id: dayEvent.id,
      title: dayEvent.eventTitle,
      description: dayEvent.eventBody,
      startTime:
          DateTime.parse(dayEvent.start), // Directly parse the ISO string
      endTime: DateTime.parse(dayEvent.end),
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
    // Parse start time with improved error handling
    DateTime startTime = DateTimeUtils.parseAnyFormat(timeEvent.start);
    DateTime endTime = DateTimeUtils.parseAnyFormat(timeEvent.end);

    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle,
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
