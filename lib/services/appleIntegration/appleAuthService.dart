import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';

class AppleAuthService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> connectAppleAccount(String appleId, String appPassword) async {
    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        Config.backendAppleConnect,
        body: {
          'appleId': appleId,
          'appPassword': appPassword,
        },
        token: authToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Apple account connected',
        };
      } else {
        print('❌ [AppleAuthService] Backend error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to connect Apple account: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [AppleAuthService] Exception connecting Apple account: $e');
      return {
        'success': false,
        'message': 'Failed to connect Apple account: $e',
      };
    }
  }
}