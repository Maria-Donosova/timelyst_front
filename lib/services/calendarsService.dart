import 'dart:convert';
import '../../models/calendars.dart';
import '../../config/envVarConfig.dart';
import '../utils/apiClient.dart';

class CalendarsService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<Calendar>> fetchUserCalendars({
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.get(
        '${Config.backendURL}/calendars',
        token: authToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Calendar.fromJson(json)).toList();
      } else {
        throw CalendarServiceException(
          'Failed to fetch calendars: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Calendar> createCalendar({
    required String authToken,
    required Map<String, dynamic> input,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Config.backendURL}/calendars',
        body: input,
        token: authToken,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Calendar.fromJson(data);
      } else {
        throw CalendarServiceException(
          'Failed to create calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Calendar> updateCalendar({
    required String calendarId,
    required String authToken,
    required Map<String, dynamic> input,
  }) async {
    try {
      final response = await _apiClient.put(
        '${Config.backendURL}/calendars/$calendarId',
        body: input,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Calendar.fromJson(data);
      } else {
        throw CalendarServiceException(
          'Failed to update calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteCalendar({
    required String calendarId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.delete(
        '${Config.backendURL}/calendars/$calendarId',
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw CalendarServiceException(
          'Failed to delete calendar: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

class CalendarServiceException implements Exception {
  final String message;
  final int? statusCode;

  CalendarServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'CalendarServiceException: $message';
}
