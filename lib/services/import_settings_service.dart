import 'dart:convert';
import '../config/envVarConfig.dart';
import '../utils/apiClient.dart';
import '../models/import_settings.dart';
import 'authService.dart';

class ImportSettingsService {
  static final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  Future<ImportSettings> getImportSettings(String calendarId) async {
    try {
      final token = await _authService.getAuthToken();
      final url = '${Config.backendUrl}/calendars/$calendarId/import-settings';
      
      final response = await _apiClient.get(url, token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImportSettings.fromJson(data);
      } else {
        throw Exception('Failed to get import settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting import settings: $e');
      rethrow;
    }
  }

  Future<void> updateImportSettings(String calendarId, ImportSettings settings) async {
    try {
      final token = await _authService.getAuthToken();
      final url = '${Config.backendUrl}/calendars/$calendarId/import-settings';
      
      final response = await _apiClient.put(
        url,
        body: settings.toJson(),
        token: token,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update import settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating import settings: $e');
      rethrow;
    }
  }

  Future<void> updatePreferences({
    required String calendarId,
    required ImportSettings importSettings,
    required Color color,
    required String category,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      final url = '${Config.backendUrl}/calendars/$calendarId/preferences';
      
      final body = {
        'calendarId': calendarId,
        'importSettings': importSettings.toJson(),
        'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        'category': category,
      };

      final response = await _apiClient.put(
        url,
        body: body,
        token: token,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating preferences: $e');
      rethrow;
    }
  }
}
