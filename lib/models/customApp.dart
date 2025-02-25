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
  final List<DateTime> exceptionDates;

  CustomAppointment({
    required this.id,
    this.organizer = '',
    required this.title,
    required this.description,
    required this.startTime,
    this.startTimeZone = '',
    required this.endTime,
    this.endTimeZone = '',
    required this.catTitle,
    this.catColor = Colors.white,
    required this.participants,
    required this.isAllDay,
    required this.location,
    required this.recurrenceRule,
    this.exceptionDates = const [],
  });

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
      'exceptionDates': exceptionDates.map((e) => e.toIso8601String()).toList(),
    };
  }
}
