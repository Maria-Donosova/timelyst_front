import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/timeEvent.dart';
import '../models/customApp.dart';
import '../utils/eventsMapper.dart';
import '../utils/calendar_utils.dart';
import '../utils/logger.dart';

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
    LogService.debug('DataSource', 'Initializing with ${events.length} events');
    final apps = _buildAppointments(events);
    if (summarizeWidth != null) {
      appointments = CalendarUtils.groupAndSummarize(apps, summarizeWidth);
      LogService.debug('DataSource', 'Grouped into ${appointments?.length} items (width: $summarizeWidth)');
    } else {
      appointments = apps;
    }
  }

  @override
  CustomAppointment? convertAppointmentToObject(CustomAppointment? customData, Appointment appointment) {
    // If customData is already provided, return it
    if (customData != null) {
      return customData;
    }
    
    // Syncfusion sometimes passes an Appointment object during drag/resize
    // Try to find the original CustomAppointment in our local list
    final dynamic id = appointment.id;
    LogService.verbose('DataSource', 'convertAppointmentToObject for ID: $id');
    if (id != null) {
      final match = appointments?.whereType<CustomAppointment>().firstWhere(
        (e) => e.id == id,
        orElse: () => CustomAppointment(
          id: 'temp', 
          title: appointment.subject, 
          startTime: appointment.startTime, 
          endTime: appointment.endTime, 
          isAllDay: appointment.isAllDay,
        ),
      );
      if (match != null && match.id != 'temp') {
        LogService.verbose('DataSource', 'Resolved Appointment -> CustomAppointment');
        return match;
      }
    }
    
    // Final fallback
    LogService.warn('DataSource', 'Could not resolve appointment ID: $id');
    return null;
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
      LogService.debug('DataSource', 'Filtered $cancelledCount cancelled occurrences');
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
