import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../models/customApp.dart';
import '../../models/timeEvent.dart';
import '../utils/eventsMapper.dart';
import '../../utils/apiClient.dart';

class EventService {
  static final ApiClient _apiClient = ApiClient();

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

      final response = await _apiClient.get(
        uri.toString(),
        token: authToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        final List<TimeEvent> events = data.map((json) => TimeEvent.fromJson(json)).toList();

        return events
            .map((event) {
              try {
                return EventMapper.mapTimeEventToCustomAppointment(event);
              } catch (e) {
                print('Error mapping event ${event.id}: $e');
                return null;
              }
            })
            .where((event) => event != null)
            .cast<CustomAppointment>()
            .toList();
      } else {
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<CustomAppointment> createEvent(
      Map<String, dynamic> eventInput, String authToken) async {
    try {
      final response = await _apiClient.post(
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
      final response = await _apiClient.put(
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

  static Future<void> deleteEvent(String id, String authToken) async {
    try {
      final response = await _apiClient.delete(
        '${Config.backendURL}/events/$id',
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}