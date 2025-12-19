import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/timeEvent.dart';
import '../models/customApp.dart';
import '../utils/eventsMapper.dart';

/// Custom CalendarDataSource for SyncFusion Calendar
/// Understands master/exception event model from backend
/// 
/// Key Logic:
/// 1. Groups exceptions by their recurrenceId (master's provider_event_id)
/// 2. For each master event:
///    - Extracts exception dates from exceptions where status != 'cancelled'
///    - Creates master Appointment with recurrenceRule and recurrenceExceptionDates
///    - For each non-cancelled exception, creates separate Appointment with recurrenceId linking to master
/// 3. For non-recurring events, creates simple appointments
/// 4. **YEARLY all-day events are manually expanded** since SyncFusion doesn't handle them correctly
class TimelystCalendarDataSource extends CalendarDataSource<CustomAppointment> {
  final Map<String, int> _occurrenceCounts;
  final DateTime _viewStart;
  final DateTime _viewEnd;

  TimelystCalendarDataSource({
    required List<TimeEvent> masterEvents,
    required List<TimeEvent> exceptionEvents,
    required Map<String, int> occurrenceCounts,
    DateTime? viewStart,
    DateTime? viewEnd,
  }) : _occurrenceCounts = occurrenceCounts,
       _viewStart = viewStart ?? DateTime.now().subtract(const Duration(days: 45)),
       _viewEnd = viewEnd ?? DateTime.now().add(const Duration(days: 45)) {
    appointments = _buildAppointments(masterEvents, exceptionEvents);
  }

  /// Checks if an event needs manual YEARLY expansion
  /// Returns true for YEARLY all-day master events (SyncFusion doesn't expand these correctly)
  bool _needsManualExpansion(TimeEvent event) {
    return event.isAllDay &&
           event.recurrenceRule.isNotEmpty &&
           event.recurrenceRule.contains('FREQ=YEARLY') &&
           event.isMasterEvent;
  }

  /// Manually expands a YEARLY all-day event into occurrences for the view range
  /// Preserves recurrence metadata for edit/delete flows
  List<CustomAppointment> _expandYearlyEvent(
    TimeEvent master,
    List<DateTime> exceptionDates,
  ) {
    final List<CustomAppointment> occurrences = [];
    
    // Get the month/day from the original master event (in UTC to avoid timezone shifts)
    final masterUtc = master.start.toUtc();
    final int month = masterUtc.month;
    final int day = masterUtc.day;
    
    // Calculate event duration (for all-day events, typically 1 day)
    final eventDuration = master.end.difference(master.start);
    
    // Generate occurrences for years in the view range (with buffer)
    for (int year = _viewStart.year - 1; year <= _viewEnd.year + 1; year++) {
      // Handle Feb 29 for non-leap years - shift to Feb 28
      int adjustedDay = day;
      if (month == 2 && day == 29 && !_isLeapYear(year)) {
        adjustedDay = 28;
      }
      
      final DateTime occurrenceStart = DateTime(year, month, adjustedDay);
      final DateTime occurrenceEnd = DateTime(year, month, adjustedDay, 23, 59, 59);
      
      // Check if this occurrence falls within view range (with 1 day buffer)
      if (occurrenceStart.isAfter(_viewStart.subtract(const Duration(days: 1))) &&
          occurrenceStart.isBefore(_viewEnd.add(const Duration(days: 1)))) {
        
        // Check if this occurrence is excepted (cancelled or modified)
        final isExcepted = exceptionDates.any((exDate) =>
            exDate.year == occurrenceStart.year &&
            exDate.month == occurrenceStart.month &&
            exDate.day == occurrenceStart.day);
        
        if (!isExcepted) {
          occurrences.add(CustomAppointment(
            id: master.id,  // Keep original ID for edit/delete operations
            title: master.eventTitle.isEmpty ? 'Untitled Event' : master.eventTitle,
            description: master.description,
            startTime: occurrenceStart,
            startTimeZone: master.startTimeZone,
            endTime: occurrenceEnd,
            endTimeZone: master.endTimeZone,
            isAllDay: true,
            location: master.location,
            recurrenceRule: master.recurrenceRule,  // PRESERVE for edit/delete flow
            recurrenceId: null,  // This is the master occurrence
            originalStart: null,
            exDates: master.exDates,
            catTitle: master.category,
            catColor: _getColorFromCategory(master.category),
            calendarId: master.calendarIds.isNotEmpty ? master.calendarIds.first : null,
            userCalendars: master.calendarIds,
            timeEventInstance: master,
          ));
        }
      }
    }
    
    return occurrences;
  }

  /// Check if a year is a leap year
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get color from category (matches EventMapper logic)
  static Color _getColorFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'meeting':
        return Colors.blue;
      case 'holiday':
        return Colors.red;
      case 'personal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Builds SyncFusion appointments from master events and exceptions
  List<CustomAppointment> _buildAppointments(
    List<TimeEvent> masters,
    List<TimeEvent> exceptions,
  ) {
    final List<CustomAppointment> appointments = [];
    final Map<String, List<TimeEvent>> exceptionsByMaster = {};

    // Group exceptions by their master's provider_event_id
    for (final exception in exceptions) {
      if (exception.recurrenceId != null && exception.recurrenceId!.isNotEmpty) {
        exceptionsByMaster
            .putIfAbsent(exception.recurrenceId!, () => [])
            .add(exception);
      }
    }

    // Process master events
    for (final master in masters) {
      if (master.isMasterEvent) {
        // Get exceptions for this master
        final masterExceptions = exceptionsByMaster[master.providerEventId] ?? [];

        // Build list of exception dates (for cancelled and modified occurrences)
        final recurrenceExceptionDates = masterExceptions
            .where((e) => e.originalStart != null)
            .map((e) => e.originalStart!)
            .toList();

        // Check if this needs manual YEARLY expansion
        if (_needsManualExpansion(master)) {
          // Manually expand YEARLY all-day events (SyncFusion doesn't handle these)
          appointments.addAll(_expandYearlyEvent(master, recurrenceExceptionDates));
          
          // Add non-cancelled exceptions as separate appointments
          for (final exception in masterExceptions) {
            if (!exception.isCancelled) {
              final exceptionApp = EventMapper.mapTimeEventToCustomAppointment(exception);
              appointments.add(exceptionApp.copyWith(
                recurrenceRule: null,  // Exceptions don't have their own rule
                recurrenceExceptionDates: null,
                recurrenceId: master.id,  // Links to master appointment ID
              ));
            }
          }
        } else {
          // Let SyncFusion handle other recurring events
          final masterApp = EventMapper.mapTimeEventToCustomAppointment(master);
          appointments.add(masterApp.copyWith(
            recurrenceExceptionDates: recurrenceExceptionDates,
          ));

          // Add non-cancelled exceptions as separate appointments linked to master
          for (final exception in masterExceptions) {
            if (!exception.isCancelled) {
              final exceptionApp = EventMapper.mapTimeEventToCustomAppointment(exception);
              appointments.add(exceptionApp.copyWith(
                recurrenceRule: null,
                recurrenceExceptionDates: null,
                recurrenceId: master.id,  // Links to master appointment ID
              ));
            }
          }
        }
      } else if (!master.isException) {
        // Non-recurring single event
        appointments.add(EventMapper.mapTimeEventToCustomAppointment(master));
      }
    }

    return appointments;
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
    final rule = appointments![index].recurrenceRule;
    // For manually expanded YEARLY events, return null to prevent SyncFusion 
    // from trying to expand them again (we've already created the occurrences)
    if (rule != null && rule.isNotEmpty && rule.contains('FREQ=YEARLY') && appointments![index].isAllDay) {
      return null;  // Don't let SyncFusion re-expand manually expanded events
    }
    if (rule != null && rule.isNotEmpty) {
      // SyncFusion requires RRULE: prefix to expand recurring events
      if (!rule.startsWith('RRULE:') && rule.contains('FREQ=')) {
        return 'RRULE:$rule';
      }
      return rule;
    }
    return rule;
  }

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) =>
      appointments![index].recurrenceExceptionDates;

  @override
  Object? getRecurrenceId(int index) => appointments![index].recurrenceId;

  @override
  Object? getId(int index) => appointments![index].id;
}
