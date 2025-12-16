import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../models/dayEvent.dart';

class EventMapper {
  static CustomAppointment mapTimeEventToCustomAppointment(TimeEvent timeEvent) {
    // For all-day events, preserve the date without timezone conversion
    // For timed events, convert to local timezone
    DateTime startTime;
    DateTime endTime;
    
    if (timeEvent.isAllDay) {
      // Extract date components from UTC and create local midnight
      // This prevents the date shift that occurs when converting UTC midnight to local time
      // Example: 2024-11-28T00:00:00Z (Thanksgiving) should stay Nov 28, not shift to Nov 27
      final startUtc = timeEvent.start.toUtc();
      final endUtc = timeEvent.end.toUtc();
      
      startTime = DateTime(startUtc.year, startUtc.month, startUtc.day);
      endTime = DateTime(endUtc.year, endUtc.month, endUtc.day);
    } else {
      // Regular timed events: convert to local timezone
      startTime = timeEvent.start.toLocal();
      endTime = timeEvent.end.toLocal();
    }
    
    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle.isEmpty ? 'Untitled Event' : timeEvent.eventTitle,
      description: timeEvent.description,
      startTime: startTime,
      startTimeZone: timeEvent.startTimeZone,
      endTime: endTime,
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
      timeEventInstance: timeEvent,
      // Map providerEventId to specific provider IDs if needed, or just use a generic one
      // googleEventId: timeEvent.providerEventId, // REMOVED: This was causing all events to be treated as Google events
      // We should rely on calendar source lookup instead
    );
  }

  static CustomAppointment mapDayEventToCustomAppointment(DayEvent dayEvent) {
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
