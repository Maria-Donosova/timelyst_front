import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../utils/apiClient.dart';
import '../../models/calendars.dart';
import '../authService.dart';

class GoogleCalendarService {
  static final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  Future<void> syncGoogleCalendars({
    required String userId,
    required String email,
    required List<Calendar> calendars,
  }) async {
    try {
      // The backend expects a list of calendars to sync/save
      final body = {
        'userId': userId,
        'email': email,
        'calendars': calendars.map((c) => c.toJson()).toList(),
      };

      print('📦 [GoogleCalendarService] Syncing calendars with body: ${jsonEncode(body)}');

      final token = await _authService.getAuthToken();

      final response = await _apiClient.post(
        Config.backendGoogleSync,
        body: body,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Google Sync response: ${data['message']}');
      } else {
        throw Exception(
            'Failed to sync Google calendars: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error syncing Google calendars: $e');
      rethrow;
    }
  }
}
