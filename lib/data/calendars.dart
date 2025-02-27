import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/calendars.dart';

class CalendarsService {
  static Future<List<Calendar>> fetchUserCalendars(
      String userId, String authToken) async {
    print("Entering fetchUserCalendars in CalendarsService");

    // Define the GraphQL query string
    final String query = '''
        query User(\$userId: String!) {
          user(id: \$userId) {
            id
            email
            googleAccounts {
              email
              selectedCalendars {
                id
                summary
              }
            }
          }
        }
    ''';

    final String encodedQuery = Uri.encodeComponent(query);
    // Send the HTTP POST request
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/graphql?query=$encodedQuery&variables={"userId":"$userId"}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
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

      // Extract the user data from the response
      final userData = data['data']['user'];

      // Parse the calendars into a List<Calendar>
      final List<Calendar> calendars = (userData['googleAccounts'] as List?)
              ?.expand((googleAccount) =>
                  (googleAccount['selectedCalendars'] as List?)
                      ?.map((calendar) => Calendar.fromJson(calendar)) ??
                  <Calendar>[])
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

  static Future<void> updateCalendar(
      String calendarId, String authToken, Calendar updatedCalendar) async {
    print("Entering updateCalendar in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateCalendar(\$calendarId: String!, \$input: CalendarInput!) {
          updateCalendar(id: \$calendarId, input: \$input) {
            id
            summary
            description
            timeZone
            category
            catColor
            defaultReminders
            notificationSettings
            conferenceProperties
            organizer
            recipients
            importAll
            importSubject
            importBody
            importConferenceInfo
            importOrganizer
            importRecipients
          }
        }
    ''';

    final Map<String, dynamic> variables = {
      'calendarId': calendarId,
      'input': updatedCalendar.toJson(email: updatedCalendar.user),
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
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
      print('Calendar updated successfully');
    } else {
      print('Failed to update calendar: ${response.statusCode}');
      throw Exception('Failed to update calendar: ${response.statusCode}');
    }
  }

  static Future<void> deleteCalendar(
      String calendarId, String authToken) async {
    print("Entering deleteCalendar in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation DeleteCalendar(\$calendarId: String!) {
          deleteCalendar(id: \$calendarId)
        }
    ''';

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'calendarId': calendarId},
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
      print('Calendar deleted successfully');
    } else {
      print('Failed to delete calendar: ${response.statusCode}');
      throw Exception('Failed to delete calendar: ${response.statusCode}');
    }
  }

  static Future<void> updateCategory(
      String calendarId, String authToken, String category) async {
    print("Entering updateCategory in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateCategory(\$calendarId: String!, \$category: String!) {
          updateCategory(id: \$calendarId, category: \$category) {
            id
            category
          }
        }
    ''';

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'calendarId': calendarId, 'category': category},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Updating category failed with errors: $errors');
        throw Exception(
            'Updating category failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      print('Category updated successfully');
    } else {
      print('Failed to update category: ${response.statusCode}');
      throw Exception('Failed to update category: ${response.statusCode}');
    }
  }

  static Future<void> updateNotifications(String calendarId, String authToken,
      Map<String, dynamic> notificationSettings) async {
    print("Entering updateNotifications in CalendarsService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateNotifications(\$calendarId: String!, \$notificationSettings: NotificationSettingsInput!) {
          updateNotifications(id: \$calendarId, notificationSettings: \$notificationSettings) {
            id
            notificationSettings
          }
        }
    ''';

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {
          'calendarId': calendarId,
          'notificationSettings': notificationSettings,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Updating notifications failed with errors: $errors');
        throw Exception(
            'Updating notifications failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      print('Notifications updated successfully');
    } else {
      print('Failed to update notifications: ${response.statusCode}');
      throw Exception('Failed to update notifications: ${response.statusCode}');
    }
  }
}
