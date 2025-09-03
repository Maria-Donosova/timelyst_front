import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';

class GoogleAuthService {
  late final ApiClient _apiClient;
  late final AuthService _authService;

  GoogleAuthService() {
    _apiClient = ApiClient();
    _authService = AuthService();
  }

  GoogleAuthService.test(this._apiClient, this._authService);

  // Method for sending the authentication code to the backend
  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode, String email) async {
    // logger.i('Entering sendAuthCodeToBackend Future');
    // logger.i("Auth Code: $authCode");
    try {
      final body = {
        'code': authCode,
        'email': email,
      };

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
        token: await _authService.getAuthToken(),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // logger.i('Auth code sent to backend successfully');
        final responseData = jsonDecode(response.body);
        // logger.i('Response data: $responseData');

        // Return the response data as a JSON object
        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': responseData['email'],
          'data': responseData,
        };
      } else {
        // logger.e('Failed to send Auth code to backend: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        // logger.e('Error data: $errorData');

        // Return the error data as a JSON object
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e) {
      // logger.e('Error sending Auth code to backend: $e');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend',
      };
    }
  }
}