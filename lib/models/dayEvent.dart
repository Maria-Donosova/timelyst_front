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
  final String start;
  final String end;
  // final Map<String, dynamic> start;
  // final Map<String, dynamic> end;
  final bool is_AllDay;
  final List<String> recurrence;
  final String recurrenceId;
  final List<String> recurrenceExceptionDates;
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
    required this.recurrenceExceptionDates,
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
      start: ['start'] as String,
      end: ['end'] as String,
      'is_AllDay': is_AllDay,
      'recurrenceRule': recurrence.isNotEmpty ? recurrence.first : '',
      'recurrenceId': recurrenceId,
      'recurrenceExceptionDates': recurrenceExceptionDates,
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
      start: json['start'] as String, // Directly assign the ISO string
      end: json['end'] as String,
      // start: json['event_startDate'] != null
      //     ? {'dateTime': json['event_startDate']}
      //     : (json['start'] as Map<String, dynamic>?) ?? {},
      // end: json['event_endDate'] != null
      //     ? {'dateTime': json['event_endDate']}
      //     : (json['end'] as Map<String, dynamic>?) ?? {},
      is_AllDay: json['is_AllDay'] ?? false,
      recurrence: json['recurrenceRule'] != null
          ? [json['recurrenceRule']]
          : (json['recurrence'] as List<dynamic>?)?.cast<String>() ?? [],
      recurrenceId: json['recurrenceId'] ?? '',
      recurrenceExceptionDates:
          (json['recurrenceExceptionDates'] as List<dynamic>?)?.cast<String>() ?? 
          (json['exceptionDates'] as List<dynamic>?)?.cast<String>() ?? [], // fallback for migration
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

  // Add these methods to parse date times

  DateTime getStartDateTime() {
    try {
      return DateTime.parse(start);
    } catch (e) {
      return DateTime.now(); // Fallback
    }
  }

  DateTime getEndDateTime() {
    try {
      return DateTime.parse(end);
    } catch (e) {
      return DateTime.now(); // Fallback
    }
  }

//   DateTime getStartDateTime() {
//     try {
//       if (start == null) return DateTime.now();

//       // Check if start is a Map with dateTime or date
//       if (start is Map<String, dynamic>) {
//         String? dateTimeStr = start['dateTime'] ?? start['date'];
//         if (dateTimeStr == null) return DateTime.now();

//         // Try parsing as ISO date first
//         try {
//           return DateTime.parse(dateTimeStr);
//         } catch (e) {
//           // Try parsing as Unix timestamp (milliseconds)
//           if (dateTimeStr.length > 8 && int.tryParse(dateTimeStr) != null) {
//             return DateTime.fromMillisecondsSinceEpoch(int.parse(dateTimeStr));
//           }
//           // If all parsing fails, return current time
//           return DateTime.now();
//         }
//       } else if (start is String) {
//         // Try parsing as ISO date first
//         try {
//           return DateTime.parse(start as String);
//         } catch (e) {
//           // Try parsing as Unix timestamp (milliseconds)
//           if ((start as String).length > 8 &&
//               int.tryParse(start as String) != null) {
//             return DateTime.fromMillisecondsSinceEpoch(
//                 int.parse(start as String));
//           }
//           // If all parsing fails, return current time
//           return DateTime.now();
//         }
//       }

//       return DateTime.now(); // Default fallback
//     } catch (e) {
//       print('Error parsing start date: $e');
//       return DateTime.now(); // Fallback value
//     }
//   }

//   DateTime getEndDateTime() {
//     try {
//       if (end == null) return DateTime.now();

//       // Check if end is a Map with dateTime or date
//       if (end is Map<String, dynamic>) {
//         String? dateTimeStr = end['dateTime'] ?? end['date'];
//         if (dateTimeStr == null) return DateTime.now();

//         // Try parsing as ISO date first
//         try {
//           return DateTime.parse(dateTimeStr);
//         } catch (e) {
//           // Try parsing as Unix timestamp (milliseconds)
//           if (dateTimeStr.length > 8 && int.tryParse(dateTimeStr) != null) {
//             return DateTime.fromMillisecondsSinceEpoch(int.parse(dateTimeStr));
//           }
//           // If all parsing fails, return current time
//           return DateTime.now();
//         }
//       } else if (end is String) {
//         // Try parsing as ISO date first
//         try {
//           return DateTime.parse(end as String);
//         } catch (e) {
//           // Try parsing as Unix timestamp (milliseconds)
//           if ((end as String).length > 8 &&
//               int.tryParse(end as String) != null) {
//             return DateTime.fromMillisecondsSinceEpoch(
//                 int.parse(end as String));
//           }
//           // If all parsing fails, return current time
//           return DateTime.now();
//         }
//       }

//       return DateTime.now(); // Default fallback
//     } catch (e) {
//       print('Error parsing end date: $e');
//       return DateTime.now(); // Fallback value
//     }
//   }
// }
}
