import 'package:flutter/material.dart';
import '../models/customApp.dart';
import '../models/timeEvent.dart';
import '../widgets/calendar/dialogs/recurring_event_dialog.dart';
import './eventsService.dart';

/// Centralized service for handling recurring event operations
/// Provides unified logic for edit and delete operations with proper scope handling
class EventHandlerService {
  final String authToken;

  EventHandlerService({required this.authToken});

  /// Handles editing any calendar event with proper recurring event logic
  /// 
  /// For non-recurring events: Updates directly
  /// For recurring events: Shows dialog and routes to appropriate service method
  Future<void> handleEventEdit({
    required BuildContext context,
    required CustomAppointment appointment,
    required Map<String, dynamic> updates,
    DateTime? occurrenceDate,
    int? totalOccurrences,
  }) async {
    final isRecurring = appointment.isMasterEvent || appointment.isException;

    if (!isRecurring) {
      // Simple single event - just update
      await EventService.updateEvent(
        appointment.id,
        updates,
        authToken,
      );
      return;
    }

    // Get the master event ID
    final masterId = appointment.isException && appointment.recurrenceId != null
        ? appointment.recurrenceId!
        : appointment.id;

    // Show dialog to select edit scope
    final editType = await RecurringEventDialog(
      totalOccurrences: totalOccurrences ?? 0,
    ).showEditDialog(context);

    if (editType == null) return; // User cancelled

    final originalStart = occurrenceDate ?? appointment.startTime;

    switch (editType) {
      case RecurringEditType.thisOccurrence:
        // Update single occurrence (creates/updates exception)
        await EventService.updateThisOccurrence(
          authToken: authToken,
          masterEventId: masterId,
          originalStart: originalStart,
          updates: updates,
        );
        break;

      case RecurringEditType.thisAndFuture:
        // Split series and update future occurrences
        await EventService.updateThisAndFuture(
          authToken: authToken,
          masterEventId: masterId,
          fromDate: originalStart,
          updates: updates,
        );
        break;

      case RecurringEditType.allOccurrences:
        // Update master event (preserves exceptions by default)
        await EventService.updateAllOccurrences(
          authToken: authToken,
          masterEventId: masterId,
          updates: updates,
          preserveExceptions: true,
        );
        break;
    }
  }

  /// Handles deleting any calendar event with proper recurring event logic
  /// 
  /// For non-recurring events: Deletes directly
  /// For recurring events: Shows dialog and routes to appropriate service method
  Future<void> handleEventDelete({
    required BuildContext context,
    required CustomAppointment appointment,
    DateTime? occurrenceDate,
    int? totalOccurrences,
  }) async {
    final isRecurring = appointment.isMasterEvent || appointment.isException;

    if (!isRecurring) {
      // Simple single event - just delete
      await EventService.deleteEvent(appointment.id, authToken);
      return;
    }

    // Get the master event ID
    final masterId = appointment.isException && appointment.recurrenceId != null
        ? appointment.recurrenceId!
        : appointment.id;

    // Show dialog to select delete scope
    final deleteType = await RecurringEventDialog(
      totalOccurrences: totalOccurrences ?? 0,
    ).showDeleteDialog(context);

    if (deleteType == null) return; // User cancelled

    final originalStart = occurrenceDate ?? appointment.startTime;

    switch (deleteType) {
      case RecurringDeleteType.thisOccurrence:
        // Delete single occurrence (creates cancelled exception)
        await EventService.deleteThisOccurrence(
          authToken: authToken,
          masterEventId: masterId,
          originalStart: originalStart,
        );
        break;

      case RecurringDeleteType.thisAndFuture:
        // Truncate series from this point forward
        await EventService.deleteThisAndFuture(
          authToken: authToken,
          masterEventId: masterId,
          fromDate: originalStart,
        );
        break;

      case RecurringDeleteType.allOccurrences:
        // Delete entire series (master + all exceptions)
        await EventService.deleteAllOccurrences(
          authToken: authToken,
          masterEventId: masterId,
        );
        break;
    }
  }

  /// Handles drag-and-drop for recurring events with simplified 2-option dialog
  Future<void> handleDragDrop({
    required BuildContext context,
    required CustomAppointment appointment,
    required DateTime newStartTime,
    required Duration eventDuration,
    int? totalOccurrences,
  }) async {
    final isRecurring = appointment.isMasterEvent || appointment.isException;

    if (!isRecurring) {
      // Simple single event - update directly
      final updates = {
        'start': newStartTime.toUtc().toIso8601String(),
        'end': newStartTime.add(eventDuration).toUtc().toIso8601String(),
      };
      await EventService.updateEvent(appointment.id, updates, authToken);
      return;
    }

    // Get the master event ID
    final masterId = appointment.isException && appointment.recurrenceId != null
        ? appointment.recurrenceId!
        : appointment.id;

    // Show simplified 2-option dialog for drag-and-drop
    final scope = await RecurringEventDialog(
      totalOccurrences: totalOccurrences ?? 0,
    ).showDragDropDialog(context);

    if (scope == null) return; // User cancelled

    final updates = {
      'start': newStartTime.toUtc().toIso8601String(),
      'end': newStartTime.add(eventDuration).toUtc().toIso8601String(),
    };

    switch (scope) {
      case DragDropScope.thisOccurrence:
        // Update single occurrence (creates exception)
        await EventService.updateThisOccurrence(
          authToken: authToken,
          masterEventId: masterId,
          originalStart: appointment.startTime,
          updates: updates,
        );
        break;

      case DragDropScope.allOccurrences:
        // Update master event
        await EventService.updateAllOccurrences(
          authToken: authToken,
          masterEventId: masterId,
          updates: updates,
          preserveExceptions: true,
        );
        break;
    }
  }
}
