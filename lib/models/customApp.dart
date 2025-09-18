import 'package:flutter/material.dart';

class CustomAppointment {
  final String id;
  final String organizer;
  final String title;
  final String description;
  final DateTime startTime;
  final String startTimeZone;
  final DateTime endTime;
  final String endTimeZone;
  final String catTitle;
  final Color catColor;
  final String participants;
  final bool isAllDay;
  final String location;
  final String? recurrenceRule;
  final List<DateTime>? recurrenceExceptionDates;
  final String? exceptionDates; // Keep for backwards compatibility
  final List<String> userCalendars;
  final String? timeEventInstance;
  final String? createdAt;
  final String? updatedAt;

  CustomAppointment({
    required this.id,
    this.organizer = '',
    required this.title,
    this.description = '', // Make description optional with default value
    required this.startTime,
    this.startTimeZone = '',
    required this.endTime,
    this.endTimeZone = '',
    this.catTitle = '', // Make catTitle optional with default value
    this.catColor = Colors.white,
    this.participants = '', // Make participants optional with default value
    required this.isAllDay,
    this.location = '', // Make location optional with default value
    this.recurrenceRule,
    this.recurrenceExceptionDates,
    this.exceptionDates,
    this.userCalendars = const [],
    this.timeEventInstance,
    String? createdAt,
    String? updatedAt,
  })  : createdAt = _parseDate(createdAt),
        updatedAt = _parseDate(updatedAt);

  static String? _parseDate(String? dateString) {
    if (dateString == null) return null;

    try {
      // Try parsing as Unix timestamp first
      if (dateString.length == 13 && int.tryParse(dateString) != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(dateString))
            .toIso8601String();
      }
      // Try parsing as ISO string
      return DateTime.parse(dateString).toIso8601String();
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Convert CustomAppointment to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'location': location,
      'organizer': organizer,
      'recurrenceRule': recurrenceRule,
      'recurrenceExceptionDates': recurrenceExceptionDates?.map((d) => d.toIso8601String()).toList(),
      'exceptionDates': exceptionDates,
      'userCalendars': userCalendars,
      'timeEventInstance': timeEventInstance,
    };
  }
}
