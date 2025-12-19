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
      // Extract date components from UTC and create local dates
      // This prevents the date shift that occurs when converting UTC midnight to local time
      // Example: 2024-11-28T00:00:00Z (Thanksgiving) should stay Nov 28, not shift to Nov 27
      final startUtc = timeEvent.start.toUtc();
      final endUtc = timeEvent.end.toUtc();
      
      startTime = DateTime(startUtc.year, startUtc.month, startUtc.day);
      
      // Google/iCal uses EXCLUSIVE end dates for all-day events
      // e.g., a 1-day event on Dec 26 has end = Dec 27T00:00:00Z (midnight of next day)
      // SyncFusion treats midnight as the START of the next day, causing duplication
      // Fix: Convert to the LAST ACTIVE DAY at 23:59:59 to prevent the event from
      // appearing on the following day
      final exclusiveEndDate = DateTime(endUtc.year, endUtc.month, endUtc.day);
      final lastActiveDay = exclusiveEndDate.subtract(const Duration(days: 1));
      
      // Ensure endTime is not before startTime (for single-day events where
      // exclusiveEndDate - 1 day would be before startTime)
      if (lastActiveDay.isBefore(startTime)) {
        // Single day event: end is same day at 23:59:59
        endTime = DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);
      } else {
        // Multi-day event: end is last active day at 23:59:59
        endTime = DateTime(lastActiveDay.year, lastActiveDay.month, lastActiveDay.day, 23, 59, 59);
      }
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
