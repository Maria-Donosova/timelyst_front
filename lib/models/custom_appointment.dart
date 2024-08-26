import 'package:flutter/material.dart';

class CustomAppointment {
  CustomAppointment({
    // this.id = '',
    // this.creator = '',
    // List<UserProfile> userProfiles = '',
    // List<UserCalendar> userCalendars = '',
    // this.eventOrganizer = '',
    this.subject = '',
    required this.startTime,
    required this.endTime,
    // this.startTimeZone,
    // this.endTimeZone,
    this.isAllDay = false,
    // this.recurrenceId,
    this.recurrenceRule,
    // this.recurrenceExceptionDates,
    this.catTitle = '',
    this.catColor = Colors.grey,
    this.participants = '',
    this.body,
    // this.location,
    // this.resourceIds,
  });
  // String id;
  // String? creator;
  // List<UserProfile> userProfiles;
  // List<UserCalendar> userCalendars;
  // String? eventOrganizer;
  String subject;
  DateTime startTime;
  DateTime endTime;
  // String? startTimeZone;
  // String? endTimeZone;
  bool isAllDay;
  // Object? recurrenceId;
  String? recurrenceRule;
  // List<DateTime>? recurrenceExceptionDates;
  String catTitle;
  Color catColor;
  String? participants;
  String? body;
  // String? location;
  // List<Object>? resourceIds;
}
