import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../models/customApp.dart';
import '../../models/timeEvent.dart';
import '../utils/logger.dart';
import '../config/logging_config.dart';
import '../utils/eventsMapper.dart';
import '../../utils/apiClient.dart';

class EventService {
  static ApiClient apiClient = ApiClient();

  static Future<List<CustomAppointment>> fetchEvents(
      String userId, String authToken, {
      DateTime? startDate,
      DateTime? endDate,
    }) async {
    
    // Use provided date range or default to broader range
    final start = startDate ?? DateTime.now().subtract(Duration(days: 90));
    final end = endDate ?? DateTime.now().add(Duration(days: 120));
    
    final startDateStr = start.toUtc().toIso8601String();
    final endDateStr = end.toUtc().toIso8601String();
    
    try {
      // Construct query parameters
      final queryParams = {
        'startDate': startDateStr,
        'endDate': endDateStr,
      };
      
      final uri = Uri.parse('${Config.backendURL}/events').replace(queryParameters: queryParams);

      LogService.info('EventService', 'GET $uri');
      final response = await apiClient.get(
        uri.toString(),
        token: authToken,
      );

      if (response.statusCode == 200) {
        final body = response.body;

        if (body == 'null') {
           LogService.info('EventService', 'Body is "null" string');
           return [];
        }

        final List<dynamic> data = jsonDecode(body);
        
        final List<TimeEvent> events = data.map((json) {
          try {
            return TimeEvent.fromJson(json);
          } catch (e) {
            LogService.error('EventService', 'Error parsing TimeEvent', e);
            LogService.verbose('EventService', 'JSON: $json');
            rethrow;
          }
        }).toList();

        return events
            .map((event) {
              try {
                return EventMapper.mapTimeEventToCustomAppointment(event);
              } catch (e) {
                LogService.warn('EventService', 'Error mapping event ${event.id}: $e');
                return null;
              }
            })
            .where((event) => event != null)
            .cast<CustomAppointment>()
            .toList();
      } else {
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LogService.error('EventService', 'Exception in fetchEvents', e, stackTrace);
      rethrow;
    }
  }

  static Future<CustomAppointment> createEvent(
      Map<String, dynamic> eventInput, String authToken) async {
    try {
      final response = await apiClient.post(
        '${Config.backendURL}/events',
        body: eventInput,
        token: authToken,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final TimeEvent event = TimeEvent.fromJson(data);
        return EventMapper.mapTimeEventToCustomAppointment(event);
      } else {
        throw Exception('Failed to create event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<CustomAppointment> updateEvent(
      String id, Map<String, dynamic> eventInput, String authToken) async {
    try {
      final response = await apiClient.put(
        '${Config.backendURL}/events/$id',
        body: eventInput,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final TimeEvent event = TimeEvent.fromJson(data);
        return EventMapper.mapTimeEventToCustomAppointment(event);
      } else {
        throw Exception('Failed to update event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteEvent(
    String id, 
    String authToken,
    {String? deleteScope}  // 'occurrence' or 'series'
  ) async {
    try {
      // Build URL with query parameter if scope provided
      String url = '${Config.backendURL}/events/$id';
      if (deleteScope != null && deleteScope.isNotEmpty) {
        url += '?deleteScope=$deleteScope';
        LogService.info('EventService', 'Deleting with scope: $deleteScope');
      }
      
      final response = await apiClient.delete(
        url,
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete event: ${response.statusCode} - ${response.body}');
      }
      
      LogService.info('EventService', 'Event deleted successfully');
    } catch (e) {
      LogService.error('EventService', 'Delete failed', e);
      rethrow;
    }
  }

  // ============ RECURRING EVENT OPERATIONS ============

  /// Fetch calendar view with master events, exceptions, and occurrence counts
  static Future<Map<String, dynamic>> getCalendarView({
    required String authToken,
    required DateTime start,
    required DateTime end,
    bool expand = true,  // Request expanded occurrences from backend
  }) async {
    try {
      final queryParams = {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'expand': expand.toString(),
      };

      final uri = Uri.parse('${Config.backendURL}/api/calendar')
          .replace(queryParameters: queryParams);

      LogService.info('EventService', 'GET $uri (calendar view)');
      final response = await apiClient.get(
        uri.toString(),
        token: authToken,
      );

      if (response.statusCode == 200) {
        if (LoggingConfig.shouldLogApiResponses) {
          final body = response.body;
          final truncatedBody = body.length > 200 ? '${body.substring(0, 200)}...' : body;
          LogService.verbose('EventService', 'getCalendarView response body: $truncatedBody');
        }
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch calendar view: ${response.statusCode}');
      }
    } catch (e) {
      LogService.error('EventService', 'Exception in getCalendarView', e);
      rethrow;
    }
  }

  /// Update single occurrence (creates/updates exception)
  static Future<TimeEvent> updateThisOccurrence({
    required String authToken,
    required String masterEventId,
    required DateTime originalStart,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await apiClient.put(
        '${Config.backendURL}/recurring-events/$masterEventId/occurrences/${originalStart.toIso8601String()}',
        body: updates,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TimeEvent.fromJson(data);
      } else {
        throw Exception('Failed to update occurrence: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update this and future occurrences (splits series)
  static Future<Map<String, dynamic>> updateThisAndFuture({
    required String authToken,
    required String masterEventId,
    required DateTime fromDate,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final queryParams = {'from': fromDate.toIso8601String()};
      final uri = Uri.parse('${Config.backendURL}/recurring-events/$masterEventId/split')
          .replace(queryParameters: queryParams);

      final response = await apiClient.put(
        uri.toString(),
        body: updates,
        token: authToken,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to split series: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update all occurrences (updates master)
  /// preserveExceptions defaults to true to keep existing modified/cancelled occurrences
  static Future<TimeEvent> updateAllOccurrences({
    required String authToken,
    required String masterEventId,
    required Map<String, dynamic> updates,
    bool preserveExceptions = true,
  }) async {
    try {
      final queryParams = {'preserveExceptions': preserveExceptions.toString()};
      final uri = Uri.parse('${Config.backendURL}/recurring-events/$masterEventId')
          .replace(queryParameters: queryParams);

      final response = await apiClient.put(
        uri.toString(),
        body: updates,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TimeEvent.fromJson(data);
      } else {
        throw Exception('Failed to update all occurrences: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete single occurrence (creates cancelled exception)
  static Future<void> deleteThisOccurrence({
    required String authToken,
    required String masterEventId,
    required DateTime originalStart,
  }) async {
    try {
      final response = await apiClient.delete(
        '${Config.backendURL}/recurring-events/$masterEventId/occurrences/${originalStart.toIso8601String()}',
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete occurrence: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete this and future occurrences (truncates series)
  static Future<TimeEvent> deleteThisAndFuture({
    required String authToken,
    required String masterEventId,
    required DateTime fromDate,
  }) async {
    try {
      final queryParams = {'from': fromDate.toIso8601String()};
      final uri = Uri.parse('${Config.backendURL}/recurring-events/$masterEventId/future')
          .replace(queryParameters: queryParams);

      final response = await apiClient.delete(
        uri.toString(),
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TimeEvent.fromJson(data);
      } else {
        throw Exception('Failed to delete future occurrences: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all occurrences (deletes master and all exceptions)
  static Future<void> deleteAllOccurrences({
    required String authToken,
    required String masterEventId,
  }) async {
    try {
      final queryParams = {'deleteAll': 'true'};
      final uri = Uri.parse('${Config.backendURL}/recurring-events/$masterEventId')
          .replace(queryParameters: queryParams);

      final response = await apiClient.delete(
        uri.toString(),
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete all occurrences: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}