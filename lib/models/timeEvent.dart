import '../../utils/dateUtils.dart';
import 'attendee.dart';

class TimeEvent {
  final String id;
  final String userId;
  final List<String> calendarIds;
  final String provider; // 'google', 'microsoft', 'apple', 'timelyst'
  final String providerEventId;
  final String? providerCalendarId;
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
  final String status; // 'confirmed', 'cancelled', 'tentative'
  final int sequence;
  final String? busyStatus; // 'busy', 'free', 'tentative', 'oof'
  final String? visibility; // 'public', 'private', 'confidential'
  final List<Attendee>? attendees;
  final String? organizerEmail;
  final String? organizerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? rawData;

  // Computed properties
  bool get isMasterEvent => recurrenceRule.isNotEmpty && (recurrenceId == null || recurrenceId!.isEmpty);
  bool get isException => recurrenceId != null && recurrenceId!.isNotEmpty;
  bool get isCancelled => status == 'cancelled';
  bool get isRecurring => isMasterEvent || isException;

  TimeEvent({
    required this.id,
    required this.userId,
    required this.calendarIds,
    required this.provider,
    required this.providerEventId,
    this.providerCalendarId,
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
    this.status = 'confirmed',
    this.sequence = 0,
    this.busyStatus,
    this.visibility,
    this.attendees,
    this.organizerEmail,
    this.organizerName,
    required this.createdAt,
    required this.updatedAt,
    this.rawData,
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
      provider: json['provider'] ?? 'timelyst',
      providerEventId: json['providerEventId'] ?? json['provider_event_id'] ?? '',
      providerCalendarId: json['providerCalendarId'] ?? json['provider_calendar_id'],
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
      status: json['status'] ?? 'confirmed',
      sequence: json['sequence'] ?? 0,
      busyStatus: json['busyStatus'] ?? json['busy_status'],
      visibility: json['visibility'],
      attendees: json['attendees'] != null
          ? (json['attendees'] as List<dynamic>)
              .map((a) => Attendee.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
      organizerEmail: json['organizerEmail'] ?? json['organizer_email'],
      organizerName: json['organizerName'] ?? json['organizer_name'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      rawData: json['rawData'] ?? json['raw_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'calendarIds': calendarIds,
      'provider': provider,
      'providerEventId': providerEventId,
      'providerCalendarId': providerCalendarId,
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
      'status': status,
      'sequence': sequence,
      'busyStatus': busyStatus,
      'visibility': visibility,
      'attendees': attendees?.map((a) => a.toJson()).toList(),
      'organizerEmail': organizerEmail,
      'organizerName': organizerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rawData': rawData,
    };
  }
}
