// event_mapper.dart
import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../models/dayEvent.dart';

class EventMapper {
  static CustomAppointment mapDayEventToCustomAppointment(DayEvent dayEvent) {
    return CustomAppointment(
      id: dayEvent.id,
      title: dayEvent.eventTitle,
      description: dayEvent.eventBody,
      startTime:
          DateTime.parse(dayEvent.start['dateTime'] ?? dayEvent.start['date']),
      endTime: DateTime.parse(dayEvent.end['dateTime'] ?? dayEvent.end['date']),
      isAllDay: dayEvent.is_AllDay,
      location: dayEvent.eventLocation,
      organizer:
          dayEvent.organizer['displayName'] ?? dayEvent.organizer['email'],
      recurrenceRule: dayEvent.recurrence.join(';'),
      catTitle: dayEvent.category,
      participants: dayEvent.participants,
      exceptionDates: dayEvent.exceptionDates.isNotEmpty
          ? dayEvent.exceptionDates.join(';')
          : null,
      catColor:
          _getColorFromCategory(dayEvent.category), // Map category to color
    );
  }

  static CustomAppointment mapTimeEventToCustomAppointment(
      TimeEvent timeEvent) {
    return CustomAppointment(
      id: timeEvent.id,
      title: timeEvent.eventTitle,
      description: timeEvent.eventBody,
      startTime: DateTime.parse(
          timeEvent.start['dateTime'] ?? timeEvent.start['date']),
      endTime:
          DateTime.parse(timeEvent.end['dateTime'] ?? timeEvent.end['date']),
      isAllDay: timeEvent.is_AllDay,
      location: timeEvent.eventLocation,
      organizer:
          timeEvent.organizer['displayName'] ?? timeEvent.organizer['email'],
      recurrenceRule: timeEvent.recurrence.join(';'),
      exceptionDates: timeEvent.exceptionDates.isNotEmpty
          ? timeEvent.exceptionDates.join(';')
          : null,
      catTitle: timeEvent.category,
      participants: timeEvent.participants,
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
