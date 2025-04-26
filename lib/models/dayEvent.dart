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
  final bool is_AllDay;
  final List<String> recurrence;
  final String recurrenceId;
  final List<String> exceptionDates;
  final String dayEventInstance;
  final String category;
  final String eventBody;
  final String eventLocation;
  final String eventConferenceDetails;
  final String participants;
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
    required this.is_AllDay,
    required this.recurrence,
    required this.recurrenceId,
    required this.exceptionDates,
    required this.dayEventInstance,
    required this.category,
    required this.eventBody,
    required this.eventLocation,
    required this.eventConferenceDetails,
    required this.participants,
    required this.reminder,
    required this.holiday,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert DayEvent to a Map for sending to backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'createdBy': createdBy,
      'user_calendars': userCalendars,
      'source_calendar': calendarId,
      'googleEventId': googleEventId,
      'googleKind': googleKind,
      'googleEtag': googleEtag,
      'creator': creator,
      'event_organizer': organizer['displayName'] ?? '',
      'event_title': eventTitle,
      // Flatten the start and end date objects to match backend expectations
      'event_startDate': start['dateTime'] ?? start['date'] ?? '',
      'event_endDate': end['dateTime'] ?? end['date'] ?? '',
      'is_AllDay': is_AllDay,
      'recurrenceRule': recurrence.isNotEmpty ? recurrence.first : '',
      'recurrenceId': recurrenceId,
      'exceptionDates': exceptionDates,
      'day_EventInstance': dayEventInstance,
      'category': category,
      'event_body': eventBody,
      'event_location': eventLocation,
      'event_ConferenceDetails': eventConferenceDetails,
      'event_attendees': participants,
      'reminder': reminder,
      'holiday': holiday,
    };
    return data;
  }

  factory DayEvent.fromJson(Map<String, dynamic> json) {
    return DayEvent(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      userCalendars: (json['user_calendars'] is String)
          ? [json['user_calendars']]
          : (json['user_calendars'] as List<dynamic>?)?.cast<String>() ?? [],
      calendarId: json['source_calendar'] ?? json['calendarId'] ?? '',
      googleEventId: json['googleEventId'] ?? '',
      googleKind: json['googleKind'] ?? '',
      googleEtag: json['googleEtag'] ?? '',
      creator: (json['creator'] as Map<String, dynamic>?) ?? {},
      organizer: json['event_organizer'] != null
          ? {'displayName': json['event_organizer']}
          : (json['organizer'] as Map<String, dynamic>?) ?? {},
      eventTitle: json['event_title'] ?? '',
      start: json['event_startDate'] != null
          ? {'dateTime': json['event_startDate']}
          : (json['start'] as Map<String, dynamic>?) ?? {},
      end: json['event_endDate'] != null
          ? {'dateTime': json['event_endDate']}
          : (json['end'] as Map<String, dynamic>?) ?? {},
      is_AllDay: json['is_AllDay'] ?? false,
      recurrence: json['recurrenceRule'] != null
          ? [json['recurrenceRule']]
          : (json['recurrence'] as List<dynamic>?)?.cast<String>() ?? [],
      recurrenceId: json['recurrenceId'] ?? '',
      exceptionDates:
          (json['exceptionDates'] as List<dynamic>?)?.cast<String>() ?? [],
      dayEventInstance:
          json['day_EventInstance'] ?? json['day_eventInstance'] ?? '',
      category: json['category'] ?? '',
      eventBody: json['event_body'] ?? '',
      eventLocation: json['event_location'] ?? '',
      eventConferenceDetails: json['event_ConferenceDetails'] ??
          json['event_conferencedetails'] ??
          '',
      participants: json['event_attendees'] ?? '',
      reminder: json['reminder'] ?? false,
      holiday: json['holiday'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
