// models/day_event.dart
class DayEvent {
  final String id;
  final String userId;
  final String createdBy;
  final List<String> userCalendars;
  final String calendarId;
  final String googleEventId;
  final String googleKind;
  final String googleEtag;
  final Map<String, dynamic> creator;
  final Map<String, dynamic> organizer;
  final String eventTitle;
  final Map<String, dynamic> start;
  final Map<String, dynamic> end;
  final bool isAllDay;
  final List<String> recurrence;
  final String recurrenceId;
  final List<String> exceptionDates;
  final String dayEventInstance;
  final String category;
  final String eventBody;
  final String eventLocation;
  final String eventConferenceDetails;
  final bool reminder;
  final bool holiday;
  final DateTime createdAt;
  final DateTime updatedAt;

  DayEvent({
    required this.id,
    required this.userId,
    required this.createdBy,
    required this.userCalendars,
    required this.calendarId,
    required this.googleEventId,
    required this.googleKind,
    required this.googleEtag,
    required this.creator,
    required this.organizer,
    required this.eventTitle,
    required this.start,
    required this.end,
    required this.isAllDay,
    required this.recurrence,
    required this.recurrenceId,
    required this.exceptionDates,
    required this.dayEventInstance,
    required this.category,
    required this.eventBody,
    required this.eventLocation,
    required this.eventConferenceDetails,
    required this.reminder,
    required this.holiday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DayEvent.fromJson(Map<String, dynamic> json) {
    return DayEvent(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      userCalendars:
          (json['user_calendars'] as List<dynamic>?)?.cast<String>() ?? [],
      calendarId: json['calendarId'] ?? '',
      googleEventId: json['googleEventId'] ?? '',
      googleKind: json['googleKind'] ?? '',
      googleEtag: json['googleEtag'] ?? '',
      creator: (json['creator'] as Map<String, dynamic>?) ?? {},
      organizer: (json['organizer'] as Map<String, dynamic>?) ?? {},
      eventTitle: json['event_title'] ?? '',
      start: (json['start'] as Map<String, dynamic>?) ?? {},
      end: (json['end'] as Map<String, dynamic>?) ?? {},
      isAllDay: json['is_allDay'] ?? false,
      recurrence: (json['recurrence'] as List<dynamic>?)?.cast<String>() ?? [],
      recurrenceId: json['recurrenceId'] ?? '',
      exceptionDates:
          (json['exceptionDates'] as List<dynamic>?)?.cast<String>() ?? [],
      dayEventInstance: json['day_eventInstance'] ?? '',
      category: json['category'] ?? '',
      eventBody: json['event_body'] ?? '',
      eventLocation: json['event_location'] ?? '',
      eventConferenceDetails: json['event_conferencedetails'] ?? '',
      reminder: json['reminder'] ?? false,
      holiday: json['holiday'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
