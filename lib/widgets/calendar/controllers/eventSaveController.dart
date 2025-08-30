import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/eventProvider.dart';
import '../../../models/customApp.dart';

class EventSaveController {
  static Future<bool> saveEvent(
      BuildContext context, Map<String, dynamic> eventData) async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      final isUpdate = eventData['isUpdate'] as bool;
      final eventId = eventData['eventId'] as String?;
      final isAllDay = eventData['isAllDay'] as bool;

      final Map<String, dynamic> cleanEventData = Map.from(eventData);

      cleanEventData.remove('isUpdate');
      cleanEventData.remove('eventId');
      cleanEventData.remove('isAllDay');

      cleanEventData['is_AllDay'] = isAllDay;

      CustomAppointment? result;
      if (isUpdate && eventId != null && eventId.isNotEmpty) {
        if (isAllDay) {
          result = await eventProvider.updateDayEvent(
              eventId, cleanEventData);
        } else {
          result = await eventProvider.updateTimeEvent(
              eventId, cleanEventData);
        }
      } else {
        if (isAllDay) {
          result = await eventProvider.createDayEvent(cleanEventData);
        } else {
          result = await eventProvider.createTimeEvent(cleanEventData);
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