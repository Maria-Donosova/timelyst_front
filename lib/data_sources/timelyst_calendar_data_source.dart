import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/timeEvent.dart';
import '../models/customApp.dart';
import '../utils/eventsMapper.dart';
import '../utils/calendar_utils.dart';

/// Custom CalendarDataSource for SyncFusion Calendar
/// 
/// With backend expansion (expand=true), this is now a pure adapter:
/// - Receives pre-expanded occurrences from backend
/// - Each occurrence has unique ID and masterId for edit/delete
/// - No manual expansion logic needed
class TimelystCalendarDataSource extends CalendarDataSource<CustomAppointment> {
  final Map<String, int> _occurrenceCounts;

  /// Constructor for expanded mode (default)
  /// Accepts a flat list of appointments that are already mapped and synced
  TimelystCalendarDataSource({
    required List<CustomAppointment> appointments,
    required Map<String, int> occurrenceCounts,
    double? summarizeWidth,
  }) : _occurrenceCounts = occurrenceCounts {
    if (summarizeWidth != null) {
      this.appointments = CalendarUtils.groupAndSummarize(appointments, summarizeWidth);
    } else {
      this.appointments = appointments;
    }
  }

  /// Returns the total occurrence count for a master event
  /// Used for displaying occurrence count in dialogs
  int getOccurrenceCount(String masterEventId) {
    return _occurrenceCounts[masterEventId] ?? 0;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].title;

  @override
  Color getColor(int index) => appointments![index].catColor;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String? getRecurrenceRule(int index) {
    final app = appointments![index];
    
    // Backend-expanded occurrences should NOT be re-expanded by SyncFusion
    if (app.isOccurrence) {
      return null;
    }
    
    // Safety net: never pass YEARLY all-day rules to SyncFusion (known crash)
    final rule = app.recurrenceRule;
    if (rule != null && rule.isNotEmpty && rule.contains('FREQ=YEARLY') && app.isAllDay) {
      return null;
    }
    
    // For non-expanded master events (fallback case), add RRULE: prefix
    if (rule != null && rule.isNotEmpty) {
      if (!rule.startsWith('RRULE:') && rule.contains('FREQ=')) {
        return 'RRULE:$rule';
      }
      return rule;
    }
    return null;
  }

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) =>
      appointments![index].recurrenceExceptionDates;

  @override
  Object? getRecurrenceId(int index) => appointments![index].recurrenceId;

  @override
  Object? getId(int index) => appointments![index].id;
}
