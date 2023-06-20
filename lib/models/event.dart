import 'dart:ffi';

class Event {
  Object? id;
  String eventTitle;
  String eventCategory;
  DateTime from;
  DateTime to;
  String source_calendar;
  String calendar_type;
  Object? recurrenceId;
  String? event_body;
  bool isAllDay;
  String event_conferencedetails;
  String event_organizer;
  String event_attendees;
  Bool reminder;
  Bool holiday;
  List<DateTime>? exceptionDates;
  String? recurrenceRule;
  DateTime dateCreated;
  DateTime dateChanged;
  String creator;

  Event({
    this.id,
    this.eventTitle = '',
    required this.eventCategory,
    required this.from,
    required this.to,
    required this.source_calendar,
    required this.calendar_type,
    this.recurrenceId,
    this.event_body,
    this.isAllDay = false,
    required this.event_conferencedetails,
    required this.event_organizer,
    required this.event_attendees,
    required this.reminder,
    required this.holiday,
    this.exceptionDates,
    this.recurrenceRule,
    required this.dateCreated,
    required this.dateChanged,
    required this.creator,
  });
}
