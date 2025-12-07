import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../models/dayEvent.dart';

class EventMapper {
  static CustomAppointment mapTimeEventToCustomAppointment(TimeEvent timeEvent) {
    // Debug logging for source information
    print('🔍 [EventMapper] Mapping TimeEvent: "${timeEvent.eventTitle}"');
    print('  - calendarIds: "${timeEvent.calendarIds}"');
    print('  - providerEventId: "${timeEvent.providerEventId}"');
    print('  - recurrenceRule: "${timeEvent.recurrenceRule}"');
    print('  - recurrenceId: "${timeEvent.recurrenceId}"');

    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle.isEmpty ? 'Untitled Event' : timeEvent.eventTitle,
      description: timeEvent.description,
      startTime: timeEvent.start.toLocal(),
      startTimeZone: timeEvent.startTimeZone,
      endTime: timeEvent.end.toLocal(),
      endTimeZone: timeEvent.endTimeZone,
      isAllDay: timeEvent.isAllDay,
      location: timeEvent.location,
      recurrenceRule: timeEvent.recurrenceRule,
      recurrenceId: timeEvent.recurrenceId,
      originalStart: timeEvent.originalStart?.toLocal(),
      exDates: timeEvent.exDates,
      catTitle: timeEvent.category,
      catColor: _getColorFromCategory(timeEvent.category),
      calendarId: timeEvent.calendarIds.isNotEmpty ? timeEvent.calendarIds.first : null,
      userCalendars: timeEvent.calendarIds,
      // Map providerEventId to specific provider IDs if needed, or just use a generic one
      // googleEventId: timeEvent.providerEventId, // REMOVED: This was causing all events to be treated as Google events
      // We should rely on calendar source lookup instead
    );
  }

  static CustomAppointment mapDayEventToCustomAppointment(DayEvent dayEvent) {
    print('🔍 [EventMapper] Mapping DayEvent: "${dayEvent.eventTitle}"');
    
    return CustomAppointment(
      id: dayEvent.id,
      title: dayEvent.eventTitle.isEmpty ? 'Untitled Event' : dayEvent.eventTitle,
      description: dayEvent.eventBody,
      startTime: dayEvent.getStartDateTime().toLocal(),
      startTimeZone: dayEvent.startTimeZone.isNotEmpty ? dayEvent.startTimeZone : 'UTC',
      endTime: dayEvent.getEndDateTime().toLocal(),
      endTimeZone: dayEvent.endTimeZone.isNotEmpty ? dayEvent.endTimeZone : 'UTC',
      isAllDay: true,
      location: dayEvent.eventLocation,
      recurrenceRule: dayEvent.recurrence.isNotEmpty ? dayEvent.recurrence.first : '',
      catTitle: dayEvent.category,
      catColor: _getColorFromCategory(dayEvent.category),
      calendarId: dayEvent.userCalendars.isNotEmpty ? dayEvent.userCalendars.first : null,
      userCalendars: dayEvent.userCalendars,
      googleEventId: dayEvent.googleEventId,
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
