import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timelyst_flutter/models/calendars.dart';

class CalendarsService {
  static Future<List<Calendar>> fetchUserCalendars(
      String userId, String authToken) async {
    print("Entering fetchUserCalendars in CalendarsService");
    // print("UserId: $userId");
    // print("AuthToken: $authToken");

    // Define the GraphQL query string
    final String query = '''
        query User(\$userId: String!) {
        user(id: \$userId)
        {
          id
          email
          googleAccounts: googleAccounts {
          email
          selectedCalendars: selectedCalendars{
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
      // print('Raw response: ${response.body}');
      final data = jsonDecode(response.body);
      // print('Parsed data: ${data}');

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
}
