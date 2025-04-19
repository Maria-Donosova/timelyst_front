import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/env_variables_config.dart';
import '../../models/customApp.dart';
import '../../models/dayEvent.dart';
import '../../models/timeEvent.dart';
import '../utils/eventsMapper.dart';

class EventService {
  // Fetch DayEvents and map them to CustomAppointment
  static Future<List<CustomAppointment>> fetchDayEvents(
      String userId, String authToken) async {
    print("Entering fetchDayEvents in EventService");

    final String query = '''
      query DayEvents {
        dayEvents {
          dayEvents {
            id
            user_id
            createdBy
            user_calendars
            source_calendar
            event_organizer
            event_title
            event_startDate
            event_endDate
            start_timeZone
            end_timeZone
            is_AllDay
            recurrenceId
            recurrenceRule
            exceptionDates
            day_Event_Instance
            category
            event_attendees
            event_body
            event_location
            event_conferencedetails
            reminder
            holiday
            createdAt
            updatedAt
          }
        }
      }
    ''';

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
      }),
    );

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Fetching day events failed with errors: $errors');
        throw Exception(
            'Fetching day events failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the day events from the response
      final List<dynamic> dayEventsJson =
          data['data']['dayEvents']['dayEvents'];

      // Parse the day events into a List<DayEvent>
      final List<DayEvent> dayEvents =
          dayEventsJson.map((json) => DayEvent.fromJson(json)).toList();

      // Map to CustomAppointment and return
      return dayEvents
          .map((event) => EventMapper.mapDayEventToCustomAppointment(event))
          .toList();
    } else {
      // Handle non-200 status codes
      print('Failed to fetch day events: ${response.statusCode}');
      throw Exception('Failed to fetch day events: ${response.statusCode}');
    }
  }

  // Fetch TimeEvents and map them to CustomAppointment
  static Future<List<CustomAppointment>> fetchTimeEvents(
      String userId, String authToken) async {
    print("Entering fetchTimeEvents in EventService");

    final String query = '''
      query TimeEvents {
        timeEvents {
          timeEvents {
            id
            user_id
            createdBy
            user_calendars
            source_calendar
            event_organizer
            event_title
            event_startDate
            event_endDate
            start_timeZone
            end_timeZone
            is_AllDay
            recurrenceId
            recurrenceRule
            exceptionDates
            time_eventInstance
            category
            event_attendees
            event_body
            event_location
            event_conferenceDetails
            reminder
            holiday
            createdAt
            updatedAt
          }
        }
      }
    ''';

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'userId': userId},
      }),
    );

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Fetching time events failed with errors: $errors');
        throw Exception(
            'Fetching time events failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the time events from the response
      final List<dynamic> timeEventsJson =
          data['data']['timeEvents']['timeEvents'];

      // Parse the time events into a List<TimeEvent>
      final List<TimeEvent> timeEvents =
          timeEventsJson.map((json) => TimeEvent.fromJson(json)).toList();

      // Map to CustomAppointment and return
      return timeEvents
          .map((event) => EventMapper.mapTimeEventToCustomAppointment(event))
          .toList();
    } else {
      // Handle non-200 status codes
      print('Failed to fetch time events: ${response.statusCode}');
      throw Exception('Failed to fetch time events: ${response.statusCode}');
    }
  }

  // Create a TimeEvent and map it to CustomAppointment
  static Future<CustomAppointment> createTimeEvent(
      Map<String, dynamic> timeEventInput, String authToken) async {
    print("Entering createTimeEvent in EventService");
    print("TimeEventInput: $timeEventInput");
    print("AuthToken in Event Service: $authToken");

    final String mutation = '''
      mutation CreateTimeEvent(\$timeEventInput: TimeEventInputData!) {
        createTimeEvent(timeEventInput: \$timeEventInput) {
          id
          user_id
          createdBy
          user_calendars
          source_calendar
          event_organizer
          event_title
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_eventInstance
          category
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'timeEventInput': timeEventInput},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Creating time event failed with errors: $errors');
          throw Exception(
              'Creating time event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        // Add debug logging to see the response structure
        print('Response data: ${data['data']}');
        print('CreateTimeEvent response: ${data['data']['createTimeEvent']}');

        // Parse and return the created time event
        final TimeEvent timeEvent =
            TimeEvent.fromJson(data['data']['createTimeEvent']);
        print('Time event created successfully: ${timeEvent.id}');
        return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
      } else {
        print('Failed to create time event: ${response.statusCode}');
        throw Exception('Failed to create time event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create time event: $e');
      throw Exception('Failed to create time event: $e');
    }
  }

  // Create a DayEvent and map it to CustomAppointment
  static Future<CustomAppointment> createDayEvent(
      Map<String, dynamic> dayEventInput, String authToken) async {
    print("Entering createDayEvent in EventService");
    print("DayEventInput: $dayEventInput");
    print("AuthToken in Event Service: $authToken");

    final String mutation = '''
      mutation CreateDayEvent(\$dayEventInput: DayEventInputData!) {
        createDayEvent(dayEventInput: \$dayEventInput) {
          id
          user_id
          createdBy
          user_calendars
          source_calendar
          event_organizer
          event_title
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          day_Event_Instance
          category
          event_attendees
          event_body
          event_location
          event_conferencedetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'dayEventInput': dayEventInput},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Creating day event failed with errors: $errors');
          throw Exception(
              'Creating day event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        // Add debug logging to see the response structure
        print('Response data: ${data['data']}');
        print('CreateDayEvent response: ${data['data']['createDayEvent']}');

        // Parse and return the created day event
        final DayEvent dayEvent =
            DayEvent.fromJson(data['data']['createDayEvent']);
        print('Day event created successfully: ${dayEvent.id}');
        return EventMapper.mapDayEventToCustomAppointment(dayEvent);
      } else {
        print('Failed to create day event: ${response.statusCode}');
        throw Exception('Failed to create day event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create day event: $e');
      throw Exception('Failed to create day event: $e');
    }
  }

  // Update a TimeEvent and map it to CustomAppointment
  static Future<CustomAppointment> updateTimeEvent(
      String id, Map<String, dynamic> timeEventInput, String authToken) async {
    print("Entering updateTimeEvent in EventService");
    print("TimeEventInput: $timeEventInput");
    print("AuthToken in Event Service: $authToken");
    print("Event Id: $id");

    final String mutation = '''
      mutation UpdateTimeEvent(\$id: String, \$timeEventInput: TimeEventInputData!) {
        updateTimeEvent(id: \$id, timeEventInput: \$timeEventInput) {
          id
          user_id
          createdBy
          user_calendars
          source_calendar
          event_organizer
          event_title
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_eventInstance
          category
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'id': id, 'timeEventInput': timeEventInput},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Updating time event failed with errors: $errors');
          throw Exception(
              'Updating time event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        print('Time event updated successfully');

        // Parse and return the updated time event
        final TimeEvent timeEvent =
            TimeEvent.fromJson(data['data']['updateTimeEvent']);
        return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
      } else {
        print('Failed to update time event: ${response.statusCode}');
        throw Exception('Failed to update time event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update time event: $e');
      throw Exception('Failed to update time event: $e');
    }
  }

  // Update a DayEvent and map it to CustomAppointment
  static Future<CustomAppointment> updateDayEvent(
      String id, Map<String, dynamic> dayEventInput, String authToken) async {
    print("Entering updateDayEvent in EventService");
    print("DayEventInput: $dayEventInput");
    print("AuthToken in Event Service: $authToken");
    print("Event Id: $id");

    final String mutation = '''
      mutation UpdateDayEvent(\$id: String, \$dayEventInput: DayEventInputData!) {
        updateDayEvent(id: \$id, dayEventInput: \$dayEventInput) {
          id
          user_id
          createdBy
          user_calendars
          source_calendar
          event_organizer
          event_title
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          day_Event_Instance
          category
          event_attendees
          event_body
          event_location
          event_conferencedetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'id': id, 'dayEventInput': dayEventInput},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Updating day event failed with errors: $errors');
          throw Exception(
              'Updating day event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        print('Day event updated successfully');

        // Parse and return the updated day event
        final DayEvent dayEvent =
            DayEvent.fromJson(data['data']['updateDayEvent']);
        return EventMapper.mapDayEventToCustomAppointment(dayEvent);
      } else {
        print('Failed to update day event: ${response.statusCode}');
        throw Exception('Failed to update day event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update day event: $e');
      throw Exception('Failed to update day event: $e');
    }
  }

  // Delete a TimeEvent
  static Future<bool> deleteTimeEvent(String id, String authToken) async {
    print("Entering deleteTimeEvent in EventService");
    print("Event Id: $id");

    final String mutation = '''
      mutation DeleteTimeEvent(\$id: String) {
        deleteTimeEvent(id: \$id)
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'id': id},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Deleting time event failed with errors: $errors');
          throw Exception(
              'Deleting time event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        print('Time event deleted successfully');
        return data['data']['deleteTimeEvent'];
      } else {
        print('Failed to delete time event: ${response.statusCode}');
        throw Exception('Failed to delete time event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete time event: $e');
      throw Exception('Failed to delete time event: $e');
    }
  }

  // Delete a DayEvent
  static Future<bool> deleteDayEvent(String id, String authToken) async {
    print("Entering deleteDayEvent in EventService");
    print("Event Id: $id");

    final String mutation = '''
      mutation DeleteDayEvent(\$id: String) {
        deleteDayEvent(id: \$id)
      }
    ''';

    try {
      // Send the HTTP POST request
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {'id': id},
        }),
      );

      // Check the status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Deleting day event failed with errors: $errors');
          throw Exception(
              'Deleting day event failed: ${errors.map((e) => e['message']).join(", ")}');
        }

        print('Day event deleted successfully');
        return data['data']['deleteDayEvent'];
      } else {
        print('Failed to delete day event: ${response.statusCode}');
        throw Exception('Failed to delete day event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete day event: $e');
      throw Exception('Failed to delete day event: $e');
    }
  }
}
