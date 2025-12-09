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
  final DateTime? originalStart;
  final List<String>? exDates;
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
    this.originalStart,
    this.exDates,
    required this.isAllDay,
    required this.category,
    required this.location,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeEvent.fromJson(Map<String, dynamic> json) {
    final title = json['eventTitle'] ?? json['event_title'] ?? '';

    return TimeEvent(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      calendarIds: ((json['calendarIds'] ?? json['calendar_ids']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      providerEventId: json['providerEventId'] ?? json['provider_event_id'] ?? '',
      etag: json['etag'] ?? '',
      eventTitle: title,
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      startTimeZone: json['startTimeZone'] ?? json['start_time_zone'] ?? 'UTC',
      endTimeZone: json['endTimeZone'] ?? json['end_time_zone'] ?? 'UTC',
      recurrenceRule: json['recurrenceRule'] ?? json['recurrence_rule'] ?? '',
      recurrenceId: json['recurrenceId'] ?? json['recurrence_id'],
      originalStart: json['originalStart'] != null 
          ? DateTime.parse(json['originalStart']) 
          : (json['original_start'] != null ? DateTime.parse(json['original_start']) : null),
      exDates: json['exDates'] != null
          ? (json['exDates'] as List<dynamic>).map((e) => e.toString()).toList()
          : (json['ex_dates'] != null 
              ? (json['ex_dates'] as List<dynamic>).map((e) => e.toString()).toList() 
              : null),
      isAllDay: json['isAllDay'] ?? json['is_all_day'] ?? false,
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
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
      'originalStart': originalStart?.toIso8601String(),
      'exDates': exDates,
      'isAllDay': isAllDay,
      'category': category,
      'location': location,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
