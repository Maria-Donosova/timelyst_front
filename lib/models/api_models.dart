import '../models/timeEvent.dart';

/// Response model for calendar view API endpoint
/// Returns structured data with masters, exceptions, and occurrence counts
class CalendarViewResponse {
  final List<TimeEvent> masterEvents;
  final List<TimeEvent> exceptions;
  final Map<String, int> occurrenceCounts;

  CalendarViewResponse({
    required this.masterEvents,
    required this.exceptions,
    required this.occurrenceCounts,
  });

  factory CalendarViewResponse.fromJson(Map<String, dynamic> json) {
    return CalendarViewResponse(
      masterEvents: (json['masterEvents'] as List<dynamic>)
          .map((e) => TimeEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      exceptions: (json['exceptions'] as List<dynamic>)
          .map((e) => TimeEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      occurrenceCounts: Map<String, int>.from(json['occurrenceCounts'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'masterEvents': masterEvents.map((e) => e.toJson()).toList(),
      'exceptions': exceptions.map((e) => e.toJson()).toList(),
      'occurrenceCounts': occurrenceCounts,
    };
  }
}

/// Response model for split series operation
/// Returns the modified original master and the new master starting from split point
class SplitSeriesResponse {
  final TimeEvent originalMaster; // Modified with UNTIL
  final TimeEvent newMaster; // New series starting from split point

  SplitSeriesResponse({
    required this.originalMaster,
    required this.newMaster,
  });

  factory SplitSeriesResponse.fromJson(Map<String, dynamic> json) {
    return SplitSeriesResponse(
      originalMaster: TimeEvent.fromJson(json['originalMaster'] as Map<String, dynamic>),
      newMaster: TimeEvent.fromJson(json['newMaster'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalMaster': originalMaster.toJson(),
      'newMaster': newMaster.toJson(),
    };
  }
}
