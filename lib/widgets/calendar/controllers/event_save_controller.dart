import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';
import '../../../services/authService.dart';
//import '../../../models/customApp.dart';

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

      // Logic for saving the event
      // This would contain the implementation details from your _saveEvent method

      return true; // Return success/failure based on the operation result
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
