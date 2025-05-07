import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';
import '../../../services/authService.dart';

class EventDeletionController {
  /// Deletes an event with the given ID
  ///
  /// Parameters:
  /// - context: BuildContext for accessing providers and showing messages
  /// - eventId: ID of the event to delete
  /// - isAllDay: Whether the event is an all-day event (day event) or not (time event)
  ///
  /// Returns a Future<bool> indicating whether the deletion was successful
  static Future<bool> deleteEvent(
      BuildContext context, String? eventId, bool allDay,
      {bool isAllDay = false}) async {
    if (eventId == null || eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete event: Invalid event ID'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final authService = AuthService();
      final token = await authService.getAuthToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Get the event provider
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      bool success;

      // Call the appropriate delete method based on the event type
      if (isAllDay) {
        success = await eventProvider.deleteDayEvent(eventId, token);
      } else {
        success = await eventProvider.deleteTimeEvent(eventId, token);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete event'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return success;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
