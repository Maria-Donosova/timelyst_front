import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/calendars.dart';
import '../../config/envVarConfig.dart';
//import '../../utils/logger.dart';

class CalendarsService {
  static Future<PaginatedCalendars> fetchUserCalendars({
    required String userId,
    required String authToken,
    int limit = 20,
    int offset = 0,
  }) async {
    //logger.i('Fetching user calendars with limit $limit and offset $offset');

    // Define the optimized GraphQL query
    final String query = '''
      query UserCalendars(\$limit: Int!, \$offset: Int!) {
        calendars(limit: \$limit, offset: \$offset) {
          calendars {
            id
            title
            description
            timeZone
            isPrimary
            source
            color
            createdAt
            updatedAt
          }
          totalCount
          hasMore
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': query,
          'variables': {
            'limit': limit,
            'offset': offset,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          //logger.e('Failed to fetch calendars: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to fetch calendars',
            errors: errors,
          );
        }

        final responseData = data['data']['calendars'];
        final calendarsData = responseData['calendars'] as List;

        return PaginatedCalendars(
          calendars:
              calendarsData.map((json) => Calendar.fromJson(json)).toList(),
          totalCount: responseData['totalCount'],
          hasMore: responseData['hasMore'],
        );
      } else {
        //logger.e('Failed to fetch calendars: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to fetch calendars: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      //logger.e('Exception while fetching calendars: $e');
      rethrow;
    }
  }

  static Future<Calendar> fetchCalendar({
    required String calendarId,
    required String authToken,
    bool withEvents = false,
  }) async {
    //logger.i('Fetching calendar $calendarId withEvents: $withEvents');

    // Define the GraphQL query with optional event loading
    final String query = '''
      query FetchCalendar(\$id: ID!, \$withEvents: Boolean!) {
        calendar(id: \$id) {
          id
          title
          description
          timeZone
          isPrimary
          source
          color
          createdAt
          updatedAt
          events @include(if: \$withEvents) {
            id
            title
            start
            end
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': query,
          'variables': {
            'id': calendarId,
            'withEvents': withEvents,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          //logger.e('Failed to fetch calendar: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to fetch calendar',
            errors: errors,
          );
        }

        return Calendar.fromJson(data['data']['calendar']);
      } else {
        //logger.e('Failed to fetch calendar: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to fetch calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      //logger.e('Exception while fetching calendar: $e');
      rethrow;
    }
  }

  static Future<Calendar> createCalendar({
    required String authToken,
    required CalendarInput input,
  }) async {
    //logger.i('Creating new calendar with title: ${input.title}');

    final String mutation = '''
      mutation CreateCalendar(\$input: CalendarInput!) {
        createCalendar(input: \$input) {
          id
          title
          description
          timeZone
          isPrimary
          source
          color
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {
            'input': input.toJson(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          // logger.e(
          //     'Failed to create calendar: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to create calendar',
            errors: errors,
          );
        }

        // logger.i(
        //     'Successfully created calendar ${data['data']['createCalendar']['id']}');
        return Calendar.fromJson(data['data']['createCalendar']);
      } else {
        // logger.e('Failed to create calendar: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to create calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // logger.e('Exception while creating calendar: $e');
      rethrow;
    }
  }

  static Future<Calendar> updateCalendar({
    required String calendarId,
    required String authToken,
    required CalendarInput input,
  }) async {
    // logger.i('Updating calendar $calendarId');

    final String mutation = '''
      mutation UpdateCalendar(\$id: ID!, \$input: CalendarInput!) {
        updateCalendar(id: \$id, input: \$input) {
          id
          title
          description
          timeZone
          isPrimary
          source
          color
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {
            'id': calendarId,
            'input': input.toJson(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          // logger.e(
          //     'Failed to update calendar: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to update calendar',
            errors: errors,
          );
        }

        // logger.i('Successfully updated calendar $calendarId');
        return Calendar.fromJson(data['data']['updateCalendar']);
      } else {
        // logger.e('Failed to update calendar: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to update calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // logger.e('Exception while updating calendar: $e');
      rethrow;
    }
  }

  static Future<bool> deleteCalendar({
    required String calendarId,
    required String authToken,
  }) async {
    // logger.i('Deleting calendar $calendarId');

    final String mutation = '''
      mutation DeleteCalendar(\$id: ID!) {
        deleteCalendar(id: \$id) {
          id
          title
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {
            'id': calendarId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          // logger.e(
          //     'Failed to delete calendar: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to delete calendar',
            errors: errors,
          );
        }

        // logger.i('Successfully deleted calendar $calendarId');
        return true;
      } else {
        // logger.e('Failed to delete calendar: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to delete calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // logger.e('Exception while deleting calendar: $e');
      rethrow;
    }
  }

  static Future<List<Calendar>> deleteCalendars({
    required List<String> calendarIds,
    required String authToken,
  }) async {
    // logger.i('Deleting multiple calendars: $calendarIds');

    final String mutation = '''
      mutation DeleteCalendars(\$ids: [ID!]!) {
        deleteCalendars(ids: \$ids) {
          id
          title
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(Config.backendGraphqlURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'query': mutation,
          'variables': {
            'ids': calendarIds,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'];
          // logger.e(
          //     'Failed to delete calendars: ${errors.map((e) => e['message']).join(", ")}');
          throw CalendarServiceException(
            'Failed to delete calendars',
            errors: errors,
          );
        }

        final deletedCalendars = (data['data']['deleteCalendars'] as List)
            .map((json) => Calendar.fromJson(json))
            .toList();

        // logger.i('Successfully deleted ${deletedCalendars.length} calendars');
        return deletedCalendars;
      } else {
        // logger.e('Failed to delete calendars: HTTP ${response.statusCode}');
        throw CalendarServiceException(
          'Failed to delete calendars: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // logger.e('Exception while deleting calendars: $e');
      rethrow;
    }
  }
}

class PaginatedCalendars {
  final List<Calendar> calendars;
  final int totalCount;
  final bool hasMore;

  PaginatedCalendars({
    required this.calendars,
    required this.totalCount,
    required this.hasMore,
  });
}

class CalendarInput {
  final String title;
  final String? description;
  final String timeZone;
  final bool isPrimary;
  final String source;
  final String color;

  CalendarInput({
    required this.title,
    this.description,
    required this.timeZone,
    required this.isPrimary,
    required this.source,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timeZone': timeZone,
      'isPrimary': isPrimary,
      'source': source,
      'color': color,
    };
  }
}

class CalendarServiceException implements Exception {
  final String message;
  final List<dynamic>? errors;
  final int? statusCode;

  CalendarServiceException(
    this.message, {
    this.errors,
    this.statusCode,
  });

  @override
  String toString() {
    if (errors != null) {
      return 'CalendarServiceException: $message (Errors: ${errors!.map((e) => e['message']).join(', ')})';
    }
    return 'CalendarServiceException: $message';
  }
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../models/calendars.dart';
// import '../../config/env_variables_config.dart';

// class CalendarsService {
//   static Future<List<Calendar>> fetchUserCalendars(
//       String userId, String authToken) async {
//     print("Entering fetchUserCalendars in CalendarsService");

//     // Define the GraphQL query string
//     final String query = '''
//         query {
//           calendars {
//             calendars {
//               id
//               user
//               sourceCalendar
//               calendarId
//               etag
//               kind
//               summary
//               ownerAccount
//               description
//               timeZone
//               defaultReminders {
//                 method
//                 minutes
//               }
//               notificationSettings {
//                 notifications {
//                   type
//                   method
//                 }
//               }
//               calendarPrimary
//               category
//               catColor
//               conferenceProperties {
//                 allowedConferenceSolutionTypes
//               }
//               createdAt
//               updatedAt
//             }
//           }
//         }
//     ''';

//     // Send the HTTP POST request
//     final response = await http.post(
//       Uri.parse(Config.backendGraphqlURL),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({
//         'query': query,
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

//       // Extract the calendars from the response
//       final calendarsData = data['data']['calendars']['calendars'];

//       // Parse the calendars into a List<Calendar>
//       final List<Calendar> calendars = (calendarsData as List?)
//               ?.map((calendar) => Calendar.fromJson(calendar))
//               .toList() ??
//           [];

//       if (calendars.isEmpty) {
//         print('No calendars found for user');
//       }
//       return calendars;
//     } else {
//       // Handle non-200 status codes
//       print('Failed to fetch calendars: ${response.statusCode}');
//       throw Exception('Failed to fetch calendars: ${response.statusCode}');
//     }
//   }

//   static Future<Calendar> fetchCalendar(
//       String calendarId, String authToken) async {
//     print("Entering fetchCalendar in CalendarsService");

//     // Define the GraphQL query string
//     final String query = '''
//         query Calendar(\$id: String!) {
//           calendar(id: \$id) {
//             id
//             user
//             sourceCalendar
//             calendarId
//             etag
//             kind
//             summary
//             ownerAccount
//             description
//             timeZone
//             defaultReminders {
//               method
//               minutes
//             }
//             notificationSettings {
//               notifications {
//                 type
//                 method
//               }
//             }
//             calendarPrimary
//             category
//             catColor
//             conferenceProperties {
//               allowedConferenceSolutionTypes
//             }
//             createdAt
//             updatedAt
//           }
//         }
//     ''';

//     final response = await http.post(
//       Uri.parse(Config.backendGraphqlURL),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({
//         'query': query,
//         'variables': {'id': calendarId},
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['errors'] != null && data['errors'].length > 0) {
//         final errors = data['errors'];
//         print('Fetching calendar failed with errors: $errors');
//         throw Exception(
//             'Fetching calendar failed: ${errors.map((e) => e['message']).join(", ")}');
//       }

//       final calendarData = data['data']['calendar'];
//       return Calendar.fromJson(calendarData);
//     } else {
//       print('Failed to fetch calendar: ${response.statusCode}');
//       throw Exception('Failed to fetch calendar: ${response.statusCode}');
//     }
//   }

//   static Future<Calendar> createCalendar(
//       String authToken, Calendar calendar) async {
//     print("Entering createCalendar in CalendarsService");

//     // Define the GraphQL mutation string
//     final String mutation = '''
//         mutation CreateCalendar(\$input: CalendarInput!) {
//           createCalendar(input: \$input) {
//             id
//             user
//             sourceCalendar
//             calendarId
//             etag
//             kind
//             summary
//             ownerAccount
//             description
//             timeZone
//             defaultReminders {
//               method
//               minutes
//             }
//             notificationSettings {
//               notifications {
//                 type
//                 method
//               }
//             }
//             calendarPrimary
//             category
//             catColor
//             conferenceProperties {
//               allowedConferenceSolutionTypes
//             }
//             createdAt
//             updatedAt
//           }
//         }
//     ''';

//     final Map<String, dynamic> variables = {
//       'input': calendar.toJson(email: calendar.user),
//     };

//     final response = await http.post(
//       Uri.parse(Config.backendGraphqlURL),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({
//         'query': mutation,
//         'variables': variables,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['errors'] != null && data['errors'].length > 0) {
//         final errors = data['errors'];
//         print('Creating calendar failed with errors: $errors');
//         throw Exception(
//             'Creating calendar failed: ${errors.map((e) => e['message']).join(", ")}');
//       }

//       final calendarData = data['data']['createCalendar'];
//       return Calendar.fromJson(calendarData);
//     } else {
//       print('Failed to create calendar: ${response.statusCode}');
//       throw Exception('Failed to create calendar: ${response.statusCode}');
//     }
//   }

//   static Future<Calendar> updateCalendar(
//       String calendarId, String authToken, Calendar updatedCalendar) async {
//     print("Entering updateCalendar in CalendarsService");

//     // Define the GraphQL mutation string
//     final String mutation = '''
//         mutation UpdateCalendar(\$id: String!, \$input: CalendarInput!) {
//           updateCalendar(id: \$id, input: \$input) {
//             id
//             user
//             sourceCalendar
//             calendarId
//             etag
//             kind
//             summary
//             ownerAccount
//             description
//             timeZone
//             defaultReminders {
//               method
//               minutes
//             }
//             notificationSettings {
//               notifications {
//                 type
//                 method
//               }
//             }
//             calendarPrimary
//             category
//             catColor
//             conferenceProperties {
//               allowedConferenceSolutionTypes
//             }
//             createdAt
//             updatedAt
//           }
//         }
//     ''';

//     final Map<String, dynamic> variables = {
//       'id': calendarId,
//       'input': updatedCalendar.toJson(email: updatedCalendar.user),
//     };

//     final response = await http.post(
//       Uri.parse(Config.backendGraphqlURL),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({
//         'query': mutation,
//         'variables': variables,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['errors'] != null && data['errors'].length > 0) {
//         final errors = data['errors'];
//         print('Updating calendar failed with errors: $errors');
//         throw Exception(
//             'Updating calendar failed: ${errors.map((e) => e['message']).join(", ")}');
//       }

//       final calendarData = data['data']['updateCalendar'];
//       return Calendar.fromJson(calendarData);
//     } else {
//       print('Failed to update calendar: ${response.statusCode}');
//       throw Exception('Failed to update calendar: ${response.statusCode}');
//     }
//   }

//   static Future<bool> deleteCalendar(
//       String calendarId, String authToken) async {
//     print("Entering deleteCalendar in CalendarsService");

//     // Define the GraphQL mutation string
//     final String mutation = '''
//         mutation DeleteCalendar(\$id: String!) {
//           deleteCalendar(id: \$id)
//         }
//     ''';

//     final response = await http.post(
//       Uri.parse(Config.backendGraphqlURL),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $authToken',
//       },
//       body: jsonEncode({
//         'query': mutation,
//         'variables': {'id': calendarId},
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['errors'] != null && data['errors'].length > 0) {
//         final errors = data['errors'];
//         print('Deleting calendar failed with errors: $errors');
//         throw Exception(
//             'Deleting calendar failed: ${errors.map((e) => e['message']).join(", ")}');
//       }

//       final result = data['data']['deleteCalendar'];
//       print('Calendar deleted successfully');
//       return result;
//     } else {
//       print('Failed to delete calendar: ${response.statusCode}');
//       throw Exception('Failed to delete calendar: ${response.statusCode}');
//     }
//   }
// }
