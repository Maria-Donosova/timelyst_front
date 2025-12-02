import 'dart:convert';
import '../../config/envVarConfig.dart';
import '../../utils/apiClient.dart';
import '../../models/calendars.dart';
import '../authService.dart';

class MicrosoftCalendarService {
  static final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  Future<void> syncMicrosoftCalendars({
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

      final token = await _authService.getAuthToken();

      final response = await _apiClient.post(
        Config.backendMicrosoftSync,
        body: body,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Microsoft Sync response: ${data['message']}');
      } else {
        throw Exception(
            'Failed to sync Microsoft calendars: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error syncing Microsoft calendars: $e');
      rethrow;
    }
  }
}