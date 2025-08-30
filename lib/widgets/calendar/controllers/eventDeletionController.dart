import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';

class EventDeletionController {
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
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      bool success;

      if (isAllDay) {
        success = await eventProvider.deleteDayEvent(eventId);
      } else {
        success = await eventProvider.deleteTimeEvent(eventId);
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