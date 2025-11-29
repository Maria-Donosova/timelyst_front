import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../utils/apiClient.dart';

class GoogleCalendarService {
  static final ApiClient _apiClient = ApiClient();

  static Future<void> syncGoogleCalendars(String authToken) async {
    try {
      final response = await _apiClient.post(
        Config.backendGoogleSync,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Google Sync response: ${data['message']}');
      } else {
        throw Exception('Failed to sync Google calendars: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
