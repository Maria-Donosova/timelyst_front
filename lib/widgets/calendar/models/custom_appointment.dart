import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/calendar/models/calendar_model.dart';

class CustomAppointment {
  CustomAppointment({
    this.id = '',
    // this.creator = '',
    // List<UserProfile> userProfiles = '',
    this.userCalendars = const [],
    // this.eventOrganizer = '',
    this.subject = '',
    required this.startTime,
    required this.endTime,
    // this.startTimeZone,
    // this.endTimeZone,
    this.isAllDay = false,
    // this.recurrenceId,
    this.recurrenceRule = '',
    // this.recurrenceExceptionDates,
    this.catTitle = '',
    this.catColor = Colors.grey,
    this.participants = '',
    this.description = '',
    this.location = '',
    // this.resourceIds,
    // required DateTime dateCreated,
    // required DateTime dateChanged,
    this.startTimeZone = '',
    this.endTimeZone = '',
  });
  String id;
  // String? creator;
  // List<UserProfile> userProfiles;
  late List<Calendars> userCalendars;
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
  String participants;
  String description;
  String location;
  // List<Object>? resourceIds;
  // DateTime dateCreated;
  // DateTime dateChanged;
  String startTimeZone;
  String endTimeZone;
}
