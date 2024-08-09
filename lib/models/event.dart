import 'package:flutter/material.dart';
import '../models/user_calendar.dart';
import '../models/user_profile.dart';

class Event {
  // Object? id;
  // String creator;
  String eventOrganizer;
  // List<UserProfile> userProfiles;
  // List<UserCalendar> userCalendars;
  String eventTitle;
  DateTime? dateText;
  DateTime from;
  DateTime to;
  bool isAllDay;
  Object? recurrenceId;
  String? recurrenceRule;
  List<DateTime>? recurrenceExceptions;
  // bool reminder;
  // bool holiday;
  String catTitle;
  Color catColor;
  String participants;
  String? eventBody;
  String eventLocation;
  // List<DateTime>? exceptionDates;
  // DateTime dateCreated;
  // DateTime dateChanged;

  Event({
    // this.id,
    //required this.creator,
    required this.eventOrganizer,
    // required this.userProfiles,
    // required this.userCalendars,
    this.eventTitle = '',
    required this.dateText,
    required this.from,
    required this.to,
    this.isAllDay = false,
    this.recurrenceId,
    this.recurrenceRule,
    this.recurrenceExceptions,
    // required this.reminder,
    // required this.holiday,
    required this.catTitle,
    required this.catColor,
    this.participants = '',
    this.eventBody,
    this.eventLocation = '',
    // this.exceptionDates,
    // required this.dateCreated,
    // required this.dateChanged,
  });
}
