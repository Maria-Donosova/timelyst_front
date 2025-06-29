import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in_web/web_only.dart';

import '../../services/authService.dart';
import '../../config/envVarConfig.dart';

class GoogleAuthService {
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
    print('Entering sendAuthCodeToBackend Future');
    print("Auth Code: $authCode");
    try {
      // Retrieve the JWT token from secure storage
      final authService = AuthService();
      final token = await authService.getAuthToken();
      print("Token: $token");

      if (token == null) {
        throw Exception('No JWT token found. Please log in again.');
      }

      // Create the properly encoded request body
      final body = jsonEncode({
        'code': authCode,
      });

      // Send the HTTP POST request with the Authorization header
      final response = await http.post(
        Uri.parse(Config.backendGoogleCallback),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the JWT token
        },
        body: body,
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Auth code sent to backend successfully');
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Return the response data as a JSON object
        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': responseData['email'],
          'data': responseData,
        };
      } else {
        print('Failed to send Auth code to backend: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        print('Error data: $errorData');

        // Return the error data as a JSON object
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e) {
      print('Error sending Auth code to backend: $e');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend',
      };
    }
  }
}
