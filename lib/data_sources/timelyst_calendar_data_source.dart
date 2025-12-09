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
class TimelystCalendarDataSource extends CalendarDataSource<CustomAppointment> {
  final Map<String, int> _occurrenceCounts;

  TimelystCalendarDataSource({
    required List<TimeEvent> masterEvents,
    required List<TimeEvent> exceptionEvents,
    required Map<String, int> occurrenceCounts,
  }) : _occurrenceCounts = occurrenceCounts {
    appointments = _buildAppointments(masterEvents, exceptionEvents);
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

        // Create master appointment with recurrence
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
              recurrenceId: master.id, // Links to master appointment ID
            ));
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
  String? getRecurrenceRule(int index) => appointments![index].recurrenceRule;

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) =>
      appointments![index].recurrenceExceptionDates;

  @override
  Object? getRecurrenceId(int index) => appointments![index].recurrenceId;
}
