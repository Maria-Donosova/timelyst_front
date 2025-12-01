import '../../utils/dateUtils.dart';

class TimeEvent {
  final String id;
  final String userId;
  final String calendarId;
  final String providerEventId;
  final String etag;
  final String eventTitle;
  final DateTime start;
  final DateTime end;
  final String startTimeZone;
  final String endTimeZone;
  final String recurrenceRule;
  final bool isAllDay;
  final String category;
  final String location;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeEvent({
    required this.id,
    required this.userId,
    required this.calendarId,
    required this.providerEventId,
    required this.etag,
    required this.eventTitle,
    required this.start,
    required this.end,
    this.startTimeZone = 'UTC',
    this.endTimeZone = 'UTC',
    required this.recurrenceRule,
    required this.isAllDay,
    required this.category,
    required this.location,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeEvent.fromJson(Map<String, dynamic> json) {
    return TimeEvent(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      calendarId: json['calendarId'] ?? '',
      providerEventId: json['providerEventId'] ?? '',
      etag: json['etag'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      startTimeZone: json['startTimeZone'] ?? 'UTC',
      endTimeZone: json['endTimeZone'] ?? 'UTC',
      recurrenceRule: json['recurrenceRule'] ?? '',
      isAllDay: json['isAllDay'] ?? false,
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'calendarId': calendarId,
      'providerEventId': providerEventId,
      'etag': etag,
      'eventTitle': eventTitle,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'startTimeZone': startTimeZone,
      'endTimeZone': endTimeZone,
      'recurrenceRule': recurrenceRule,
      'isAllDay': isAllDay,
      'category': category,
      'location': location,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
