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

      // Remove fields that are not needed for the API
      eventData.remove('isUpdate');

      // Keep eventId for update operations but remove from payload
      if (isUpdate && eventId != null) {
        eventData.remove('eventId');
      }

      // Determine if this is a create or update operation
      CustomAppointment? result;
      if (isUpdate && eventId != null && eventId.isNotEmpty) {
        // Update existing event
        if (isAllDay) {
          result =
              await eventProvider.updateDayEvent(eventId, eventData, token);
        } else {
          result =
              await eventProvider.updateTimeEvent(eventId, eventData, token);
        }

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update event'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        // Create new event
        if (isAllDay) {
          result = await eventProvider.createDayEvent(eventData, token);
        } else {
          result = await eventProvider.createTimeEvent(eventData, token);
        }

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create event'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving event: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../providers/eventProvider.dart';
// import '../../../services/authService.dart';
// import '../../../models/customApp.dart';

// class EventSaveController {
//   /// Saves an event with the given details
//   ///
//   /// Parameters:
//   /// - context: BuildContext for accessing providers and showing messages
//   /// - eventData: Map containing all the event data to be saved
//   ///
//   /// Returns a Future<bool> indicating whether the save was successful
//   static Future<bool> saveEvent(
//       BuildContext context, Map<String, dynamic> eventData) async {
//     try {
//       final authService = AuthService();
//       final token = await authService.getAuthToken();
//       final userId = await authService.getUserId();

//       if (token == null || userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Authentication error. Please log in again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return false;
//       }

//       // Get the event provider
//       final eventProvider = Provider.of<EventProvider>(context, listen: false);

//       // Extract data from eventData
//       final isUpdate = eventData['isUpdate'] as bool;
//       final eventId = eventData['eventId'] as String?;
//       final isAllDay = eventData['isAllDay'] as bool;

//       // Remove fields that are not needed for the API
//       eventData.remove('isUpdate');
      
//       // Keep eventId for update operations but remove from payload
//       if (isUpdate && eventId != null) {
//         eventData.remove('eventId');
//       }

//       // Determine if this is a create or update operation
//       bool success;
//       if (isUpdate && eventId != null && eventId.isNotEmpty) {
//         // Update existing event
//         success = await eventProvider.updateEvent(
//           eventId, 
//           userId, 
//           token, 
//           eventData, 
//           isAllDay
//         );
        
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Event updated successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to update event'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } else {
//         // Create new event
//         success = await eventProvider.createEvent(
//           userId, 
//           token, 
//           eventData, 
//           isAllDay
//         );
        
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Event created successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to create event'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }

//       return success;
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error saving event: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//   }
// }
