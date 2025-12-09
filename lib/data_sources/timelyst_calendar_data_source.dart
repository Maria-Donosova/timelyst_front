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
class TimelystCalendarDataSource extends CalendarDataSource {
  final Map<String, int> _occurrenceCounts;

  TimelystCalendarDataSource({
    required List<TimeEvent> masterEvents,
    required List<TimeEvent> exceptionEvents,
    required Map<String, int> occurrenceCounts,
  }) : _occurrenceCounts = occurrenceCounts {
    appointments = _buildAppointments(masterEvents, exceptionEvents);
  }

  /// Builds SyncFusion appointments from master events and exceptions
  List<Appointment> _buildAppointments(
    List<TimeEvent> masters,
    List<TimeEvent> exceptions,
  ) {
    final List<Appointment> appointments = [];
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
        appointments.add(Appointment(
          id: master.id,
          subject: master.eventTitle.isEmpty ? 'Untitled Event' : master.eventTitle,
          startTime: master.start.toLocal(),
          endTime: master.end.toLocal(),
          startTimeZone: master.startTimeZone,
          endTimeZone: master.endTimeZone,
          isAllDay: master.isAllDay,
          color: _getColorFromCategory(master.category),
          recurrenceRule: master.recurrenceRule,
          recurrenceExceptionDates: recurrenceExceptionDates,
          notes: master.description,
          location: master.location,
        ));

        // Add non-cancelled exceptions as separate appointments linked to master
        for (final exception in masterExceptions) {
          if (!exception.isCancelled) {
            appointments.add(Appointment(
              id: exception.id,
              subject: exception.eventTitle.isEmpty ? 'Untitled Event' : exception.eventTitle,
              startTime: exception.start.toLocal(),
              endTime: exception.end.toLocal(),
              startTimeZone: exception.startTimeZone,
              endTimeZone: exception.endTimeZone,
              isAllDay: exception.isAllDay,
              color: _getColorFromCategory(exception.category),
              recurrenceRule: null,
              recurrenceExceptionDates: null,
              notes: exception.description,
              location: exception.location,
              recurrenceId: master.id, // Links to master appointment
            ));
          }
        }
      } else if (!master.isException) {
        // Non-recurring single event
        appointments.add(Appointment(
          id: master.id,
          subject: master.eventTitle.isEmpty ? 'Untitled Event' : master.eventTitle,
          startTime: master.start.toLocal(),
          endTime: master.end.toLocal(),
          startTimeZone: master.startTimeZone,
          endTimeZone: master.endTimeZone,
          isAllDay: master.isAllDay,
          color: _getColorFromCategory(master.category),
          notes: master.description,
          location: master.location,
        ));
      }
    }

    return appointments;
  }

  /// Returns the total occurrence count for a master event
  /// Used for displaying occurrence count in dialogs
  int getOccurrenceCount(String masterEventId) {
    return _occurrenceCounts[masterEventId] ?? 0;
  }

  /// Helper to map category to color
  Color _getColorFromCategory(String category) {
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

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;

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
