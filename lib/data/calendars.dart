import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/calendars.dart';
import '../../config/env_variables_config.dart';

class CalendarsService {
  static Future<List<Calendar>> fetchUserCalendars(
      String userId, String authToken) async {
    print("Entering fetchUserCalendars in CalendarsService");

    // Define the GraphQL query string
    final String query = '''
        query {
          calendars {
            calendars {
              id
              user
              sourceCalendar
              calendarId
              etag
              kind
              summary
              ownerAccount
              description
              timeZone
              defaultReminders {
                method
                minutes
              }
              notificationSettings {
                notifications {
                  type
                  method
                }
              }
              calendarPrimary
              category
              catColor
              conferenceProperties {
                allowedConferenceSolutionTypes
              }
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
        print('Fetching calendars failed with errors: $errors');
        throw Exception(
            'Fetching calendars failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the calendars from the response
      final calendarsData = data['data']['calendars']['calendars'];

      // Parse the calendars into a List<Calendar>
      final List<Calendar> calendars = (calendarsData as List?)
              ?.map((calendar) => Calendar.fromJson(calendar))
              .toList() ??
          [];

      if (calendars.isEmpty) {
        print('No calendars found for user');
      }
      return calendars;
    } else {
      // Handle non-200 status codes
      print('Failed to fetch calendars: ${response.statusCode}');
      throw Exception('Failed to fetch calendars: ${response.statusCode}');
    }
  }

  static Future<Calendar> fetchCalendar(
      String calendarId, String authToken) async {
    print("Entering fetchCalendar in CalendarsService");

    // Define the GraphQL query string
    final String query = '''
        query Calendar(\$id: String!) {
          calendar(id: \$id) {
            id
            user
            sourceCalendar
            calendarId
            etag
            kind
            summary
            ownerAccount
            description
            timeZone
            defaultReminders {
              method
              minutes
            }
            notificationSettings {
              notifications {
                type
                method
              }
            }
            calendarPrimary
            category
            catColor
            conferenceProperties {
              allowedConferenceSolutionTypes
            }
            createdAt
            updatedAt
          }
        }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'id': calendarId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Fetching calendar failed with errors: $errors');
        throw Exception(
            'Fetching calendar failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      final calendarData = data['data']['calendar'];
      return Calendar.fromJson(calendarData);
    } else {
      print('Failed to fetch calendar: ${response.statusCode}');
      throw Exception('Failed to fetch calendar: ${response.statusCode}');
    }
  }

  static Future<Calendar> createCalendar(
      String authToken, Calendar calendar) async {
    print("Entering createCalendar in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation CreateCalendar(\$input: CalendarInput!) {
          createCalendar(input: \$input) {
            id
            user
            sourceCalendar
            calendarId
            etag
            kind
            summary
            ownerAccount
            description
            timeZone
            defaultReminders {
              method
              minutes
            }
            notificationSettings {
              notifications {
                type
                method
              }
            }
            calendarPrimary
            category
            catColor
            conferenceProperties {
              allowedConferenceSolutionTypes
            }
            createdAt
            updatedAt
          }
        }
    ''';

    final Map<String, dynamic> variables = {
      'input': calendar.toJson(email: calendar.user),
    };

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Creating calendar failed with errors: $errors');
        throw Exception(
            'Creating calendar failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      final calendarData = data['data']['createCalendar'];
      return Calendar.fromJson(calendarData);
    } else {
      print('Failed to create calendar: ${response.statusCode}');
      throw Exception('Failed to create calendar: ${response.statusCode}');
    }
  }

  static Future<Calendar> updateCalendar(
      String calendarId, String authToken, Calendar updatedCalendar) async {
    print("Entering updateCalendar in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateCalendar(\$id: String!, \$input: CalendarInput!) {
          updateCalendar(id: \$id, input: \$input) {
            id
            user
            sourceCalendar
            calendarId
            etag
            kind
            summary
            ownerAccount
            description
            timeZone
            defaultReminders {
              method
              minutes
            }
            notificationSettings {
              notifications {
                type
                method
              }
            }
            calendarPrimary
            category
            catColor
            conferenceProperties {
              allowedConferenceSolutionTypes
            }
            createdAt
            updatedAt
          }
        }
    ''';

    final Map<String, dynamic> variables = {
      'id': calendarId,
      'input': updatedCalendar.toJson(email: updatedCalendar.user),
    };

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Updating calendar failed with errors: $errors');
        throw Exception(
            'Updating calendar failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      final calendarData = data['data']['updateCalendar'];
      return Calendar.fromJson(calendarData);
    } else {
      print('Failed to update calendar: ${response.statusCode}');
      throw Exception('Failed to update calendar: ${response.statusCode}');
    }
  }

  static Future<bool> deleteCalendar(
      String calendarId, String authToken) async {
    print("Entering deleteCalendar in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation DeleteCalendar(\$id: String!) {
          deleteCalendar(id: \$id)
        }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'id': calendarId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Deleting calendar failed with errors: $errors');
        throw Exception(
            'Deleting calendar failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      final result = data['data']['deleteCalendar'];
      print('Calendar deleted successfully');
      return result;
    } else {
      print('Failed to delete calendar: ${response.statusCode}');
      throw Exception('Failed to delete calendar: ${response.statusCode}');
    }
  }
}
