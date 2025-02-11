import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timelyst_flutter/models/calendars.dart';

class CalendarsService {
  static Future<List<Calendar>> fetchUserCalendars(String email) async {
    print("Entering fetchUserCalendars in CalendarsService");

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
    final Map<String, dynamic> variables = {
      'email': email,
    };

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/graphql'), // Replace with your GraphQL endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
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

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:timelyst_flutter/models/calendars.dart';

// class CalendarsService {
//   static Future<Map<String, dynamic>> fetchUserCalendars(String email) async {
//     print("Entering fetchUserCalendars in CalendarsService");

//     // Define the GraphQL query string
//     final String query = '''
//       query GetUserCalendars(\$email: String!) {
//         user(email: \$email) {
//           email
//           googleAccounts {
//             email
//             selectedCalendars {
//               id
//               summary
//               syncToken
//             }
//             allCalendars {
//               id
//               summary
//               description
//               primary
//               timeZone
//             }
//           }
//           outlook {
//             selectedCalendars {
//               id
//               summary
//             }
//           }
//           apple {
//             selectedCalendars {
//               id
//               summary
//             }
//           }
//         }
//       }
//     ''';

//     // Define the variables
//     final Map<String, dynamic> variables = {
//       'email': email,
//     };

//     // Send the HTTP POST request
//     final response = await http.post(
//       Uri.parse(
//           'http://localhost:3000/graphql'), // Replace with your GraphQL endpoint
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'query': query,
//         'variables': variables,
//       }),
//     );

//     // Check the status code
//     if (response.statusCode == 200) {
//       // If the server returns a 200 OK response, parse the JSON
//       final data = jsonDecode(response.body);

//       // Check for GraphQL errors
//       if (data['errors'] != null && data['errors'].length > 0) {
//         final errors = data['errors'];
//         print('Fetching calendars failed with errors: $errors');
//         throw Exception(
//             'Fetching calendars failed: ${errors.map((e) => e['message']).join(", ")}');
//       }

//       // Return the user data
//       return data['data']['user'];
//     } else {
//       // Handle non-200 status codes
//       print('Failed to fetch calendars: ${response.statusCode}');
//       throw Exception('Failed to fetch calendars: ${response.statusCode}');
//     }
//   }

//   static List<Calendar> parseCalendarsFromUserData(
//       Map<String, dynamic> userData) {
//     final List<Calendar> calendars = [];

//     // Parse Google calendars
//     if (userData['googleAccounts'] != null) {
//       for (var account in userData['googleAccounts']) {
//         if (account['selectedCalendars'] != null) {
//           for (var calendar in account['selectedCalendars']) {
//             calendars.add(Calendar(
//               user: account['email'],
//               id: calendar['id'],
//               title: calendar['summary'],
//               // Add other fields as needed
//             ));
//           }
//         }
//       }
//     }

//     // Parse Outlook calendars
//     if (userData['outlook'] != null &&
//         userData['outlook']['selectedCalendars'] != null) {
//       for (var calendar in userData['outlook']['selectedCalendars']) {
//         calendars.add(Calendar(
//           user: userData['email'],
//           id: calendar['id'],
//           title: calendar['summary'],
//           // Add other fields as needed
//         ));
//       }
//     }

//     // Parse Apple calendars
//     if (userData['apple'] != null &&
//         userData['apple']['selectedCalendars'] != null) {
//       for (var calendar in userData['apple']['selectedCalendars']) {
//         calendars.add(Calendar(
//           user: userData['email'],
//           id: calendar['id'],
//           title: calendar['summary'],
//           // Add other fields as needed
//         ));
//       }
//     }

//     return calendars;
//   }
// }
