import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';
import '../../../services/authService.dart';
import '../../../models/customApp.dart';

class EventSaveController {
  /// Saves an event with the given details
  ///
  /// Parameters:
  /// - context: BuildContext for accessing providers and showing messages
  /// - eventData: Map containing all the event data to be saved
  ///
  /// Returns a Future<bool> indicating whether the save was successful
  static Future<bool> saveEvent(
      BuildContext context, Map<String, dynamic> eventData) async {
    try {
      final authService = AuthService();
      final token = await authService.getAuthToken();
      final userId = await authService.getUserId();

      if (token == null || userId == null) {
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

      // Extract data from eventData
      final isUpdate = eventData['isUpdate'] as bool;
      final eventId = eventData['eventId'] as String?;
      final isAllDay = eventData['isAllDay'] as bool;

      // Create a clean copy of the event data for the API
      final Map<String, dynamic> cleanEventData = Map.from(eventData);

      // Remove fields that are not needed for the API
      cleanEventData.remove('isUpdate');
      cleanEventData.remove('eventId'); // Always remove from payload
      cleanEventData.remove('isAllDay'); // Remove duplicate isAllDay field

      // Ensure is_AllDay field is properly set
      cleanEventData['is_AllDay'] = isAllDay;

      // Add userId to the event data if not already present
      if (!cleanEventData.containsKey('user_id')) {
        cleanEventData['user_id'] = userId;
      }

      CustomAppointment? result;
      if (isUpdate && eventId != null && eventId.isNotEmpty) {
        // Update existing event
        if (isAllDay) {
          result = await eventProvider.updateDayEvent(
              eventId, cleanEventData, token);
        } else {
          result = await eventProvider.updateTimeEvent(
              eventId, cleanEventData, token);
        }
      } else {
        // Create new event
        if (isAllDay) {
          result = await eventProvider.createDayEvent(cleanEventData, token);
        } else {
          result = await eventProvider.createTimeEvent(cleanEventData, token);
        }
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUpdate
                ? 'Event updated successfully'
                : 'Event created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isUpdate ? 'Failed to update event' : 'Failed to create event'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
