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
            start
            end
            is_AllDay
            recurrenceId
            recurrenceRule
            exceptionDates
            day_EventInstance
            category
            event_attendees
            event_body
            event_location
            event_ConferenceDetails
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

  // Fetch a single TimeEvent by ID and map it to CustomAppointment
  static Future<CustomAppointment> fetchTimeEvent(
      String id, String authToken) async {
    print("Entering fetchTimeEvent in EventService");

    final String query = '''
      query TimeEvent($id: String) {
        timeEvent(id: $id) {
          id
          user_id
          createdBy
          user_calendars
          source_calendar
          event_organizer
          event_title
          start
          end
          timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_EventInstance
          category
          event_attendees
          event_body
          event_location
          event_ConferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
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
        'variables': {'id': id},
      }),
    );

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Fetching time event failed with errors: $errors');
        throw Exception(
            'Fetching time event failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the time event from the response
      final timeEventJson = data['data']['timeEvent'];

      // Parse the time event into a TimeEvent
      final TimeEvent timeEvent = TimeEvent.fromJson(timeEventJson);

      // Map to CustomAppointment and return
      return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
    } else {
      // Handle non-200 status codes
      print('Failed to fetch time event: ${response.statusCode}');
      throw Exception('Failed to fetch time event: ${response.statusCode}');
    }
  }

  // Fetch TimeEvents and map them to CustomAppointment
  static Future<List<CustomAppointment>> fetchTimeEvents(
      String userId, String authToken) async {
    print("Entering fetchTimeEvents in EventService");

    final String query = '''
      query GetTimeEvents {
        timeEvents {
            id
            user_id
            createdBy
            user_calendars
            source_calendar
            event_organizer
            event_title
            start
            end
            timeZone
            is_AllDay
            recurrenceId
            recurrenceRule
            exceptionDates
            time_EventInstance
            category
            event_attendees
            event_body
            event_location
            event_ConferenceDetails
            reminder
            holiday
            createdAt
            updatedAt
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
        print('Fetching time events failed with errors: $errors');
        throw Exception(
            'Fetching time events failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the time events from the response
      final List<dynamic> timeEventsJson = data['data']['timeEvents'];
      ;

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

    // Ensure start and end dates are properly formatted as strings, not nested objects
    // if (timeEventInput['start'] != null) {
    //   timeEventInput['event_startDate'] = timeEventInput['start']['dateTime'] ??
    //       timeEventInput['start']['date'];
    //   timeEventInput.remove('start');
    // }

    // if (timeEventInput['end'] != null) {
    //   timeEventInput['event_endDate'] =
    //       timeEventInput['end']['dateTime'] ?? timeEventInput['end']['date'];
    //   timeEventInput.remove('end');
    // }

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
          start
          end
          timeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_EventInstance
          category
          event_attendees
          event_body
          event_location
          event_ConferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Validate input data before sending
      if (timeEventInput == null || timeEventInput.isEmpty) {
        print('Error: TimeEventInput is null or empty');
        throw Exception('Cannot create time event with empty data');
      }

      // Check for required fields
      final requiredFields = ['event_title', 'start', 'end'];
      for (final field in requiredFields) {
        if (timeEventInput[field] == null ||
            timeEventInput[field].toString().isEmpty) {
          print('Error: Required field $field is missing or empty');
          throw Exception('Required field $field is missing or empty');
        }
      }

      // Validate auth token
      if (authToken == null || authToken.isEmpty) {
        print('Error: Authentication token is missing');
        throw Exception(
            'Authentication token is required to create a time event');
      }

      // Send the HTTP POST request
      http.Response response;
      try {
        response = await http
            .post(
          Uri.parse(Config.backendGraphqlURL),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'query': mutation,
            'variables': {'timeEventInput': timeEventInput},
          }),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('Error: Request timed out');
            throw Exception(
                'Network request timed out. Please check your connection and try again.');
          },
        );
      } on http.ClientException catch (e) {
        print('HTTP client error: $e');
        throw Exception(
            'Network error: Unable to connect to the server. Please check your connection.');
      }

      // Log the response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the status code
      if (response.statusCode == 200) {
        // Try to parse the response body
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          print('Error parsing response JSON: $e');
          throw Exception('Server returned invalid JSON response');
        }

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Creating time event failed with GraphQL errors: $errors');

          // Extract error messages and categorize them
          final errorMessages = errors.map((e) => e['message']).join(", ");

          // Check for specific error types
          if (errorMessages.contains('validation')) {
            throw Exception('Validation error: $errorMessages');
          } else if (errorMessages.contains('authentication') ||
              errorMessages.contains('unauthorized')) {
            throw Exception('Authentication error: $errorMessages');
          } else if (errorMessages.contains('not found')) {
            throw Exception('Resource not found: $errorMessages');
          } else {
            throw Exception('Creating time event failed: $errorMessages');
          }
        }

        // Check if data and createTimeEvent exist
        if (data['data'] == null || data['data']['createTimeEvent'] == null) {
          print('Error: Response missing expected data structure');
          throw Exception(
              'Server returned success but with invalid data structure');
        }

        // Add debug logging to see the response structure
        print('Response data: ${data['data']}');
        print('CreateTimeEvent response: ${data['data']['createTimeEvent']}');

        // Parse and return the created time event
        try {
          // In the createTimeEvent method, after successful creation
          final TimeEvent timeEvent = TimeEvent.fromJson(data['data']['createTimeEvent']);
          print('Time event created successfully: ${timeEvent.id}');
          final customAppointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);
          // Remove the Provider line that's causing the error
          return customAppointment;
        } catch (e) {
          print('Error mapping time event: $e');
          throw Exception('Error processing server response: $e');
        }
      } else if (response.statusCode == 400) {
        print('Bad request error (400): ${response.body}');
        throw Exception(
            'Invalid request data. Please check your event details and try again.');
      } else if (response.statusCode == 401) {
        print('Authentication error (401): ${response.body}');
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        print('Authorization error (403): ${response.body}');
        throw Exception('You do not have permission to create this event.');
      } else if (response.statusCode == 404) {
        print('Not found error (404): ${response.body}');
        throw Exception('The requested resource was not found.');
      } else if (response.statusCode >= 500) {
        print('Server error (${response.statusCode}): ${response.body}');
        throw Exception('Server error occurred. Please try again later.');
      } else {
        print(
            'Unexpected status code: ${response.statusCode}, body: ${response.body}');
        throw Exception(
            'Failed to create time event: Unexpected error (${response.statusCode})');
      }
    } catch (e) {
      // Handle any uncaught exceptions
      print('Failed to create time event: $e');
      if (e is Exception) {
        // Rethrow exceptions that we've already formatted
        rethrow;
      } else {
        // Wrap other errors
        throw Exception('Failed to create time event: $e');
      }
    }
  }

  // Create a DayEvent and map it to CustomAppointment
  static Future<CustomAppointment> createDayEvent(
      Map<String, dynamic> dayEventInput, String authToken) async {
    print("Entering createDayEvent in EventService");
    print("DayEventInput: $dayEventInput");
    print("AuthToken in Event Service: $authToken");

    // Ensure start and end dates are properly formatted as strings, not nested objects
    if (dayEventInput['start'] != null) {
      dayEventInput['start'] =
          dayEventInput['start']['dateTime'] ?? dayEventInput['start']['date'];
    }

    if (dayEventInput['end'] != null) {
      dayEventInput['end'] =
          dayEventInput['end']['dateTime'] ?? dayEventInput['end']['date'];
    }

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
          start
          end
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          day_EventInstance
          category
          event_attendees
          event_body
          event_location
          event_ConferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      // Validate input data before sending
      if (dayEventInput == null || dayEventInput.isEmpty) {
        print('Error: DayEventInput is null or empty');
        throw Exception('Cannot create day event with empty data');
      }

      // Check for required fields
      final requiredFields = ['event_title', 'start', 'end'];
      for (final field in requiredFields) {
        if (dayEventInput[field] == null ||
            dayEventInput[field].toString().isEmpty) {
          print('Error: Required field $field is missing or empty');
          throw Exception('Required field $field is missing or empty');
        }
      }

      // Validate auth token
      if (authToken == null || authToken.isEmpty) {
        print('Error: Authentication token is missing');
        throw Exception(
            'Authentication token is required to create a day event');
      }

      // Send the HTTP POST request
      http.Response response;
      try {
        response = await http
            .post(
          Uri.parse(Config.backendGraphqlURL),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'query': mutation,
            'variables': {'dayEventInput': dayEventInput},
          }),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('Error: Request timed out');
            throw Exception(
                'Network request timed out. Please check your connection and try again.');
          },
        );
      } on http.ClientException catch (e) {
        print('HTTP client error: $e');
        throw Exception(
            'Network error: Unable to connect to the server. Please check your connection.');
      }

      // Log the response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the status code
      if (response.statusCode == 200) {
        // Try to parse the response body
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          print('Error parsing response JSON: $e');
          throw Exception('Server returned invalid JSON response');
        }

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].length > 0) {
          final errors = data['errors'];
          print('Creating day event failed with GraphQL errors: $errors');

          // Extract error messages and categorize them
          final errorMessages = errors.map((e) => e['message']).join(", ");

          // Check for specific error types
          if (errorMessages.contains('validation')) {
            throw Exception('Validation error: $errorMessages');
          } else if (errorMessages.contains('authentication') ||
              errorMessages.contains('unauthorized')) {
            throw Exception('Authentication error: $errorMessages');
          } else if (errorMessages.contains('not found')) {
            throw Exception('Resource not found: $errorMessages');
          } else {
            throw Exception('Creating day event failed: $errorMessages');
          }
        }

        // Check if data and createDayEvent exist
        if (data['data'] == null || data['data']['createDayEvent'] == null) {
          print('Error: Response missing expected data structure');
          throw Exception(
              'Server returned success but with invalid data structure');
        }

        // Add debug logging to see the response structure
        print('Response data: ${data['data']}');
        print('CreateDayEvent response: ${data['data']['createDayEvent']}');

        // Parse and return the created day event
        try {
          final DayEvent dayEvent =
              DayEvent.fromJson(data['data']['createDayEvent']);
          print('Day event created successfully: ${dayEvent.id}');
          return EventMapper.mapDayEventToCustomAppointment(dayEvent);
        } catch (e) {
          print('Error mapping day event: $e');
          throw Exception('Error processing server response: $e');
        }
      } else if (response.statusCode == 400) {
        print('Bad request error (400): ${response.body}');
        throw Exception(
            'Invalid request data. Please check your event details and try again.');
      } else if (response.statusCode == 401) {
        print('Authentication error (401): ${response.body}');
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        print('Authorization error (403): ${response.body}');
        throw Exception('You do not have permission to create this event.');
      } else if (response.statusCode == 404) {
        print('Not found error (404): ${response.body}');
        throw Exception('The requested resource was not found.');
      } else if (response.statusCode >= 500) {
        print('Server error (${response.statusCode}): ${response.body}');
        throw Exception('Server error occurred. Please try again later.');
      } else {
        print(
            'Unexpected status code: ${response.statusCode}, body: ${response.body}');
        throw Exception(
            'Failed to create day event: Unexpected error (${response.statusCode})');
      }
    } catch (e) {
      // Handle any uncaught exceptions
      print('Failed to create day event: $e');
      if (e is Exception) {
        // Rethrow exceptions that we've already formatted
        rethrow;
      } else {
        // Wrap other errors
        throw Exception('Failed to create day event: $e');
      }
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
          start
          end
          imeZone
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_EventInstance
          category
          event_attendees
          event_body
          event_location
          event_ConferenceDetails
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
          start
          end
          is_AllDay
          recurrenceId
          recurrenceRule
          exceptionDates
          day_EventInstance
          category
          event_attendees
          event_body
          event_location
          event_ConferenceDetails
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
