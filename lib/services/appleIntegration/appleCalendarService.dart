import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../utils/apiClient.dart';

class AppleCalendarService {
  static final ApiClient _apiClient = ApiClient();

  static Future<void> syncAppleCalendars(String authToken) async {
    try {
      final response = await _apiClient.post(
        Config.backendAppleSync,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Apple Sync response: ${data['message']}');
      } else {
        throw Exception('Failed to sync Apple calendars: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}