import 'dart:convert';
import '../../models/calendars.dart';
import '../../config/envVarConfig.dart';
import '../utils/apiClient.dart';
//import '../../utils/logger.dart';

class CalendarsService {
  static final ApiClient _apiClient = ApiClient();

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
            user
            isSelected
            isPrimary
            source
            providerCalendarId
            email
            metadata {
              title
              description
              color
              timeZone
              defaultReminders {
                method
                minutes
              }
            }
            preferences {
              category
              color
              importSettings {
                importAll
                importSubject
                importBody
                importConferenceInfo
                importOrganizer
                importRecipients
              }
            }
            sync {
              etag
              syncToken
              lastSyncedAt
              expiration
            }
          }
          totalCount
          hasMore
        }
      }
    ''';

    try {
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': query,
          'variables': {
            'limit': limit,
            'offset': offset,
          },
        },
        token: authToken,
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

        final responseData = data['data']?['calendars'];
        if (responseData == null) {
          print('❌ [CalendarsService] "calendars" key not found in data object.');
          return PaginatedCalendars(calendars: [], totalCount: 0, hasMore: false);
        }

        final calendarsData = responseData['calendars'];
        if (calendarsData == null || calendarsData is! List) {
          print('❌ [CalendarsService] "calendars" list not found or not a list within paginated data.');
          return PaginatedCalendars(calendars: [], totalCount: 0, hasMore: false);
        }

        final parsedCalendars = calendarsData
            .map((json) => Calendar.fromJson(json as Map<String, dynamic>))
            .toList();

        return PaginatedCalendars(
          calendars: parsedCalendars,
          totalCount: responseData['totalCount'] ?? 0,
          hasMore: responseData['hasMore'] ?? false,
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
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': query,
          'variables': {
            'id': calendarId,
            'withEvents': withEvents,
          },
        },
        token: authToken,
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
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': mutation,
          'variables': {
            'input': input.toJson(),
          },
        },
        token: authToken,
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
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': mutation,
          'variables': {
            'id': calendarId,
            'input': input.toJson(),
          },
        },
        token: authToken,
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
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': mutation,
          'variables': {
            'id': calendarId,
          },
        },
        token: authToken,
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
      final response = await _apiClient.post(
        Config.backendGraphqlURL,
        body: {
          'query': mutation,
          'variables': {
            'ids': calendarIds,
          },
        },
        token: authToken,
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
