import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timelyst_flutter/models/calendars.dart';

class CalendarsService {
  static Future<List<Calendar>> fetchUserCalendars(
      String userId, String authToken) async {
    print("Entering fetchUserCalendars in CalendarsService");
    print("Email: $userId");
    print("AuthToken: $authToken");

    // Define the GraphQL query string
    final String query = '''
        query {user(id: "6796c7cae4edbe922aaded37")
        {
          id
          name
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

    // Define the variables
    // final Map<String, dynamic> variables = {
    //   'email': email,
    // };

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/graphql'), // Replace with your GraphQL endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': userId,
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

      // Extract the user data from the response
      final userData = data['data']['user'];

      // Parse the calendars into a List<Calendar>
      final List<Calendar> calendars = (userData['calendars'] as List)
          .map((calendar) => Calendar.fromJson(calendar))
          .toList();

      return calendars;
    } else {
      // Handle non-200 status codes
      print('Failed to fetch calendars: ${response.statusCode}');
      throw Exception('Failed to fetch calendars: ${response.statusCode}');
    }
  }
}
