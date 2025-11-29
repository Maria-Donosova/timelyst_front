import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../utils/apiClient.dart';

class MicrosoftCalendarService {
  static final ApiClient _apiClient = ApiClient();

  static Future<void> syncMicrosoftCalendars(String authToken) async {
    try {
      final response = await _apiClient.post(
        Config.backendMicrosoftSync,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Microsoft Sync response: ${data['message']}');
      } else {
        throw Exception('Failed to sync Microsoft calendars: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}