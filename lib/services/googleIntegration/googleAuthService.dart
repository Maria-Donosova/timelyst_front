import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in_web/web_only.dart';

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';

class GoogleAuthService {
  final ApiClient _apiClient = ApiClient();

  // Method for requesting server authentication code
  Future<String?> requestServerAuthenticatioinCode() async {
    try {
      return await requestServerAuthCode().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Google auth timed out'),
      );
    } catch (e) {
      print('Error requesting auth code: $e');
      rethrow;
    }
  }

  // Method for sending the authentication code to the backend
  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    // logger.i('Entering sendAuthCodeToBackend Future');
    // logger.i("Auth Code: $authCode");
    try {
      final body = {
        'code': authCode,
      };

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
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
