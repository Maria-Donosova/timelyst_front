import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';

class EventDeletionController {
  static Future<bool> deleteEvent(
    BuildContext context, 
    String? eventId, 
    bool allDay,
    {bool isAllDay = false, String? deleteScope}  // Added deleteScope parameter
  ) async {
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

      print('🗑️ [EventDeletionController] Deleting event $eventId with scope: ${deleteScope ?? "default"}');
      
      // Pass deleteScope to provider
      final success = await eventProvider.deleteEvent(eventId, deleteScope: deleteScope);

      if (success) {
        // Customize success message based on scope
        final message = deleteScope == 'series' 
          ? 'Series deleted successfully' 
          : 'Event deleted successfully';
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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