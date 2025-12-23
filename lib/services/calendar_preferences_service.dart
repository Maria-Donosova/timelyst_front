import 'dart:convert';
import '../config/envVarConfig.dart';
import '../utils/apiClient.dart';
import '../models/calendars.dart';
import '../models/calendar_import_config.dart';
import 'authService.dart';
import 'calendar_exceptions.dart';

class CalendarPreferencesService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  Future<CalendarPreferences> getPreferences(String calendarId) async {
    try {
      final token = await _authService.getAuthToken();
      final url = '${Config.backendURL}/calendars/$calendarId/preferences';
      
      final response = await _apiClient.get(url, token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalendarPreferences.fromJson(data);
      } else if (response.statusCode == 404) {
        throw CalendarNotFoundException('Calendar with ID $calendarId not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw CalendarException('Failed to get preferences: ${response.statusCode}');
      }
    } catch (e) {
      if (e is CalendarException) rethrow;
      throw CalendarException('Error getting preferences: $e');
    }
  }

  Future<UpdatePreferencesResponse> updatePreferences(String calendarId, CalendarPreferences preferences) async {
    try {
      final token = await _authService.getAuthToken();
      final url = '${Config.backendURL}/calendars/$calendarId/preferences';
      
      final response = await _apiClient.put(
        url,
        body: preferences.toJson(),
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UpdatePreferencesResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw CalendarNotFoundException('Calendar with ID $calendarId not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw ValidationException('Invalid preferences', data['errors']);
      } else {
        throw CalendarException('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      if (e is CalendarException) rethrow;
      throw CalendarException('Error updating preferences: $e');
    }
  }

  Future<UpdatePreferencesResponse> updateFromConfig(String calendarId, CalendarImportConfig config) async {
    final preferences = CalendarPreferences(
      importSettings: config.importSettings,
      category: config.category,
      userColor: config.color,
    );
    return updatePreferences(calendarId, preferences);
  }

  Future<List<UpdatePreferencesResponse>> updateMultipleFromConfigs(List<CalendarImportConfig> configs) async {
    final results = <UpdatePreferencesResponse>[];
    for (final config in configs) {
      if (config.calendarId != null) {
        results.add(await updateFromConfig(config.calendarId!, config));
      }
    }
    return results;
  }
}
