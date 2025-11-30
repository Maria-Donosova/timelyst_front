import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';

class EventMapper {
  static CustomAppointment mapTimeEventToCustomAppointment(TimeEvent timeEvent) {
    // Debug logging for source information
    print('🔍 [EventMapper] Mapping TimeEvent: "${timeEvent.eventTitle}"');
    print('  - calendarId: "${timeEvent.calendarId}"');
    print('  - providerEventId: "${timeEvent.providerEventId}"');

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
      catTitle: timeEvent.category,
      catColor: _getColorFromCategory(timeEvent.category),
      calendarId: timeEvent.calendarId,
      // Map providerEventId to specific provider IDs if needed, or just use a generic one
      googleEventId: timeEvent.providerEventId, // Assuming providerEventId holds the external ID
      // You might need logic to determine which provider it is if CustomAppointment distinguishes them
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
