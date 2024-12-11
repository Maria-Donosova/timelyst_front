import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in_web/web_only.dart';

import '../service/auth_service.dart';
import '../config/env_variables_config.dart';

class GoogleAuthService {
  // Method for requesting server authentication code
  Future<String?> requestServerAuthenticatioinCode() async {
    print("entering request server auth code");
    return requestServerAuthCode();
  }

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

      // Send the HTTP POST request with the Authorization header
      final response = await http.post(
        Uri.parse(Config.backendGoogleCallback),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token', // Include the JWT token
        },
        body: {
          'code': authCode,
        },
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

      // // Parse the response body as JSON
      // Map<String, dynamic> responseData;
      // try {
      //   responseData = json.decode(response.body);
      // } catch (e) {
      //   print('Error parsing response JSON: $e');
      //   return {
      //     'success': false,
      //     'message': 'Failed to parse backend response',
      //   };
      // }

      // // Check the response status code
      // if (response.statusCode == 200) {
      //   print('Auth code sent to backend successfully');
      //   final responseData = jsonDecode(response.body);
      //   print('Response data: $responseData');

      //   // Return the response data as a JSON object
      //   return {
      //     'success': true,
      //     'message': 'Auth code sent to backend successfully',
      //     'data': responseData,
      //   };
      // } else {
      //   print('Failed to send Auth code to backend: ${response.statusCode}');
      //   final errorData = jsonDecode(response.body);
      //   print('Error data: $errorData');

      //   // Return the error data as a JSON object
      //   return {
      //     'success': false,
      //     'message':
      //         'Failed to send Auth code to backend: ${response.statusCode}',
      //     'error': errorData,
      //   };
      // }
    } catch (e) {
      print('Error sending Auth code to backend: $e');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend',
      };
    }
  }

  // Future<bool> isGoogleLoggedIn() async {
  //   try {
  //     print('Google Logged Out');
  //     return true;
  //   } catch (e) {
  //     print('Error checking login status: $e');
  //     return false;
  //   }
  // }
}
