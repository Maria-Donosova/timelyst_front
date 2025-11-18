import '../../utils/dateUtils.dart';

class TimeEvent {
  final String id;
  final String userId;
  final String createdBy;
  final List<String> userCalendars;
  final String calendarId;
  final String googleEventId;
  final String googleKind;
  final String googleEtag;
  final String? microsoftEventId;
  final String? appleEventId;
  final Map<String, dynamic>? source;
  final Map<String, dynamic> creator;
  final Map<String, dynamic> organizer;
  final String eventTitle;
  final String start;
  final String end;
  // final Map<String, dynamic> start;
  // final Map<String, dynamic> end;
  final String startTimeZone;  // IANA timezone for start (e.g., "America/New_York")
  final String endTimeZone;    // IANA timezone for end (e.g., "America/New_York")
  final String timeZone;       // Legacy single timezone field for backward compatibility
  final bool is_AllDay;
  final List<String> recurrence;
  final String recurrenceId;
  final List<String> recurrenceExceptionDates;
  final List<String> timeEventInstances;
  final String category;
  final String eventBody;
  final String eventLocation;
  final String eventConferenceDetails;
  final String participants;
  final bool reminder;
  final bool holiday;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeEvent({
    this.id = '',
    required this.userId,
    required this.createdBy,
    required this.userCalendars,
    required this.calendarId,
    required this.googleEventId,
    required this.googleKind,
    required this.googleEtag,
    this.microsoftEventId,
    this.appleEventId,
    this.source,
    required this.creator,
    required this.organizer,
    required this.eventTitle,
    required this.start,
    required this.end,
    this.startTimeZone = '',
    this.endTimeZone = '',
    this.timeZone = '',
    required this.is_AllDay,
    required this.recurrence,
    required this.recurrenceId,
    required this.recurrenceExceptionDates,
    required this.timeEventInstances,
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

  // Convert TimeEvent to a Map for sending to backend
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
      'start': start, // Already a string, no conversion needed
      'end': end,
      'start_timeZone': startTimeZone,
      'end_timeZone': endTimeZone,
      'timeZone': timeZone, // Legacy field for backward compatibility
      'is_AllDay': is_AllDay,
      'recurrenceRule': recurrence.isNotEmpty ? recurrence.first : '',
      'recurrenceId': recurrenceId,
      'exceptionDates':
          recurrenceExceptionDates, // backend expects exceptionDates
      'time_EventInstance': timeEventInstances,
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

  // In TimeEvent class
  factory TimeEvent.fromJson(Map<String, dynamic> json) {
    // Debug logging to see what's coming from backend
    print(
        '🔍 [TimeEvent.fromJson] Parsing JSON for event: ${json['event_title']}');
    print('  - source field: ${json['source']}');
    print('  - googleEventId: "${json['googleEventId']}"');
    print('  - microsoftEventId: "${json['microsoftEventId']}"');
    print('  - appleEventId: "${json['appleEventId']}"');
    print('  - source_calendar: "${json['source_calendar']}"');
    print('  - createdBy: "${json['createdBy']}"');

    return TimeEvent(
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
      microsoftEventId: json['microsoftEventId'],
      appleEventId: json['appleEventId'],
      source: json['source'] as Map<String, dynamic>?,
      creator: (json['creator'] as Map<String, dynamic>?) ?? {},
      organizer: json['event_organizer'] != null
          ? {'displayName': json['event_organizer']}
          : (json['organizer'] as Map<String, dynamic>?) ?? {},
      eventTitle: json['event_title'] ?? '',
      start: _parseStartEnd(json['start']),
      end: _parseStartEnd(json['end']),
      // start: json['event_startDate'] != null
      //     ? {'dateTime': json['event_startDate']}
      //     : (json['start'] as Map<String, dynamic>?) ?? {},
      // end: json['event_endDate'] != null
      //     ? {'dateTime': json['event_endDate']}
      //     : (json['end'] as Map<String, dynamic>?) ?? {},
      startTimeZone: json['start_timeZone'] ?? json['startTimeZone'] ?? '',
      endTimeZone: json['end_timeZone'] ?? json['endTimeZone'] ?? '',
      timeZone: json['timeZone'] ?? '',
      is_AllDay: json['is_AllDay'] ?? false,
      recurrence: json['recurrenceRule'] != null
          ? [json['recurrenceRule']]
          : (json['recurrence'] is List)
              ? (json['recurrence'] as List<dynamic>).cast<String>()
              : [],
      recurrenceId: json['recurrenceId'] ?? '',
      recurrenceExceptionDates:
          (json['exceptionDates'] as List<dynamic>?)?.cast<String>() ??
              [], // backend uses exceptionDates
      timeEventInstances:
          (json['time_EventInstance'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] ?? '',
      eventBody: json['event_body'] ?? '',
      eventLocation: json['event_location'] ?? '',
      eventConferenceDetails: json['event_ConferenceDetails'] ??
          json['event_conferenceDetails'] ??
          '',
      participants: json['event_attendees'] ?? '',
      reminder: json['reminder'] ?? false,
      holiday: json['holiday'] ?? false,
      createdAt: DateTimeUtils.parseAnyFormat(json['createdAt']),
      updatedAt: DateTimeUtils.parseAnyFormat(json['updatedAt']),
    );
  }

  // Helper method to parse start/end that can be either timestamp or ISO string
  static String _parseStartEnd(dynamic value) {
    if (value == null) return '';

    // If it's already a string, return as-is
    if (value is String) return value;

    // If it's a number (Unix timestamp in milliseconds), convert to ISO string
    if (value is num) {
      try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        return dateTime.toIso8601String();
      } catch (e) {
        return '';
      }
    }

    // Fallback: convert to string
    return value.toString();
  }

  // Add these methods to parse date times
  DateTime getStartDateTime() {
    return DateTimeUtils.parseAnyFormat(start);
  }

  DateTime getEndDateTime() {
    return DateTimeUtils.parseAnyFormat(end);
  }
}
