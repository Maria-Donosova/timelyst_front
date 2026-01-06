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
  /// Accepts a flat list of events that are already expanded by the backend
  TimelystCalendarDataSource({
    required List<TimeEvent> events,
    required Map<String, int> occurrenceCounts,
    double? summarizeWidth,
  }) : _occurrenceCounts = occurrenceCounts {
    final apps = _buildAppointments(events);
    if (summarizeWidth != null) {
      appointments = CalendarUtils.groupAndSummarize(apps, summarizeWidth);
      print('📊 [DataSource] Grouped ${apps.length} events into ${appointments?.length} (cellWidth: $summarizeWidth)');
    } else {
      appointments = apps;
      print('📊 [DataSource] Initialized with ${apps.length} flat events');
    }
  }

  @override
  CustomAppointment convertAppointmentToObject(Object? appointment) {
    if (appointment is CustomAppointment) {
      return appointment;
    }
    // Fallback or error case - Syncfusion should pass the CustomAppointment instance
    // but if it passes a wrapper, we'd need to unwrap it here.
    return appointment as CustomAppointment;
  }

  /// Builds CustomAppointments from backend-expanded events
  /// Since backend handles expansion, this is a simple map operation
  List<CustomAppointment> _buildAppointments(List<TimeEvent> events) {
    int cancelledCount = 0;
    final apps = events
        .where((e) {
          if (e.status == 'cancelled') {
            cancelledCount++;
            return false;
          }
          return true;
        })
        .map((e) => EventMapper.mapTimeEventToCustomAppointment(e))
        .toList();
        
    if (cancelledCount > 0) {
      print('📊 [DataSource] Filtered $cancelledCount cancelled occurrences');
    }
    return apps;
  }

  /// Returns the total occurrence count for a master event
  /// Used for displaying occurrence count in dialogs
  int getOccurrenceCount(String masterEventId) {
    return _occurrenceCounts[masterEventId] ?? 0;
  }

  @override
  DateTime getStartTime(int index) {
    if (appointments == null || appointments!.length <= index) {
      return DateTime.now();
    }
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    if (appointments == null || appointments!.length <= index) {
      return DateTime.now();
    }
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    if (appointments == null || appointments!.length <= index) {
      return '';
    }
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    if (appointments == null || appointments!.length <= index) {
      return Colors.grey;
    }
    return appointments![index].catColor;
  }

  @override
  bool isAllDay(int index) {
    if (appointments == null || appointments!.length <= index) {
      return false;
    }
    return appointments![index].isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    if (appointments == null || appointments!.length <= index) {
      return null;
    }
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
  List<DateTime>? getRecurrenceExceptionDates(int index) {
    if (appointments == null || appointments!.length <= index) {
      return null;
    }
    return appointments![index].recurrenceExceptionDates;
  }

  @override
  Object? getRecurrenceId(int index) {
    if (appointments == null || appointments!.length <= index) {
      return null;
    }
    return appointments![index].recurrenceId;
  }

  @override
  Object? getId(int index) {
    if (appointments == null || appointments!.length <= index) {
      return null;
    }
    return appointments![index].id;
  }
}
