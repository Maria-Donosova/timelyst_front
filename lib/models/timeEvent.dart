import '../../utils/dateUtils.dart';

class TimeEvent {
  final String id;
  final String userId;
  final List<String> calendarIds;
  final String providerEventId;
  final String etag;
  final String eventTitle;
  final DateTime start;
  final DateTime end;
  final String startTimeZone;
  final String endTimeZone;
  final String recurrenceRule;
  final String? recurrenceId;
  final bool isAllDay;
  final String category;
  final String location;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeEvent({
    required this.id,
    required this.userId,
    required this.calendarIds,
    required this.providerEventId,
    required this.etag,
    required this.eventTitle,
    required this.start,
    required this.end,
    this.startTimeZone = 'UTC',
    this.endTimeZone = 'UTC',
    required this.recurrenceRule,
    this.recurrenceId,
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
      calendarIds: (json['calendarIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      providerEventId: json['providerEventId'] ?? '',
      etag: json['etag'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      startTimeZone: json['startTimeZone'] ?? 'UTC',
      endTimeZone: json['endTimeZone'] ?? 'UTC',
      recurrenceRule: json['recurrenceRule'] ?? '',
      recurrenceId: json['recurrenceId'],
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
      'calendarIds': calendarIds,
      'providerEventId': providerEventId,
      'etag': etag,
      'eventTitle': eventTitle,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'startTimeZone': startTimeZone,
      'endTimeZone': endTimeZone,
      'recurrenceRule': recurrenceRule,
      'recurrenceId': recurrenceId,
      'isAllDay': isAllDay,
      'category': category,
      'location': location,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
