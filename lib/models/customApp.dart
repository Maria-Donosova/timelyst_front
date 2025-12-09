import 'package:flutter/material.dart';
import 'timeEvent.dart';

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
  final String? recurrenceId;
  final DateTime? originalStart;
  final List<String>? exDates;
  final List<DateTime>? recurrenceExceptionDates;
  final List<String> userCalendars;
  final TimeEvent? timeEventInstance;
  final String? createdAt;
  final String? updatedAt;
  
  // Enhanced calendar source information
  final String? createdBy;
  final String? sourceCalendar;
  final String? calendarId;
  final Map<String, dynamic>? source;
  final String? microsoftEventId;
  final String? googleEventId;
  final String? appleEventId;

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
    this.recurrenceId,
    this.originalStart,
    this.exDates,
    this.recurrenceExceptionDates,
    this.userCalendars = const [],
    this.timeEventInstance,
    String? createdAt,
    String? updatedAt,
    // Enhanced calendar source information
    this.createdBy,
    this.sourceCalendar,
    this.calendarId,
    this.source,
    this.microsoftEventId,
    this.googleEventId,
    this.appleEventId,
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

  // Helper methods for recurrence detection
  bool get isMasterEvent => 
      recurrenceRule != null && 
      recurrenceRule!.isNotEmpty && 
      (recurrenceId == null || recurrenceId!.isEmpty);
  
  bool get isException => recurrenceId != null && recurrenceId!.isNotEmpty;
  
  bool get isRecurring => isMasterEvent || isException;

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
      'recurrenceId': recurrenceId,
      'originalStart': originalStart?.toIso8601String(),
      'exDates': exDates,
      'recurrenceExceptionDates': recurrenceExceptionDates?.map((d) => d.toIso8601String()).toList(),
      'userCalendars': userCalendars,
      'timeEventInstance': timeEventInstance?.toJson(),
      'createdBy': createdBy,
      'sourceCalendar': sourceCalendar,
      'calendarId': calendarId,
      'source': source,
      'microsoftEventId': microsoftEventId,
      'googleEventId': googleEventId,
      'appleEventId': appleEventId,
    };
  }

  CustomAppointment copyWith({
    String? id,
    String? organizer,
    String? title,
    String? description,
    DateTime? startTime,
    String? startTimeZone,
    DateTime? endTime,
    String? endTimeZone,
    String? catTitle,
    Color? catColor,
    String? participants,
    bool? isAllDay,
    String? location,
    String? recurrenceRule,
    String? recurrenceId,
    DateTime? originalStart,
    List<String>? exDates,
    List<DateTime>? recurrenceExceptionDates,
    List<String>? userCalendars,
    TimeEvent? timeEventInstance,
    String? createdBy,
    String? sourceCalendar,
    String? calendarId,
    Map<String, dynamic>? source,
    String? microsoftEventId,
    String? googleEventId,
    String? appleEventId,
  }) {
    return CustomAppointment(
      id: id ?? this.id,
      organizer: organizer ?? this.organizer,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      startTimeZone: startTimeZone ?? this.startTimeZone,
      endTime: endTime ?? this.endTime,
      endTimeZone: endTimeZone ?? this.endTimeZone,
      catTitle: catTitle ?? this.catTitle,
      catColor: catColor ?? this.catColor,
      participants: participants ?? this.participants,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      originalStart: originalStart ?? this.originalStart,
      exDates: exDates ?? this.exDates,
      recurrenceExceptionDates: recurrenceExceptionDates ?? this.recurrenceExceptionDates,
      userCalendars: userCalendars ?? this.userCalendars,
      timeEventInstance: timeEventInstance ?? this.timeEventInstance,
      createdBy: createdBy ?? this.createdBy,
      sourceCalendar: sourceCalendar ?? this.sourceCalendar,
      calendarId: calendarId ?? this.calendarId,
      source: source ?? this.source,
      microsoftEventId: microsoftEventId ?? this.microsoftEventId,
      googleEventId: googleEventId ?? this.googleEventId,
      appleEventId: appleEventId ?? this.appleEventId,
    );
  }
}
