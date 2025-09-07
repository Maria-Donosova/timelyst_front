import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web_only;

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';
import 'google_sign_in_singleton.dart';
import '../../models/calendars.dart';

class GoogleAuthService {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _apiClient = ApiClient(),
        _authService = AuthService();

  GoogleAuthService.test(this._apiClient, this._authService, this._googleSignIn);

  Future<String?> requestServerAuthenticatioinCode() async {
    try {
      print('🔍 [GoogleAuthService] Starting server auth code request...');
      print('🔍 [GoogleAuthService] GoogleSignIn scopes: ${_googleSignIn.scopes}');
      final authCode = await web_only.requestServerAuthCode();
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      print('✅ [GoogleAuthService] Server auth code received successfully: $maskedCode');
      return authCode;
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error requesting auth code: $e');
      print('🔍 [GoogleAuthService] Stack trace: $stackTrace');
      print('🔍 [GoogleAuthService] Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      print('🔍 [GoogleAuthService] Starting to send auth code to backend...');
      print('🔍 [GoogleAuthService] Backend URL: ${Config.backendGoogleCalendar}');
      
      final authToken = await _authService.getAuthToken();
      final maskedToken = (authToken?.length ?? 0) > 10 ? '${authToken?.substring(0, 10)}...' : authToken;
      print('🔍 [GoogleAuthService] Auth token obtained: $maskedToken');
      
      final body = {
        'code': authCode,
      };
      print('🔍 [GoogleAuthService] Request body prepared with auth code');

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
        token: authToken,
      );
      
      print('🔍 [GoogleAuthService] Backend response status code: ${response.statusCode}');
      print('🔍 [GoogleAuthService] Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [GoogleAuthService] Backend response successful');
        print('🔍 [GoogleAuthService] Response data keys: ${responseData.keys.toList()}');
        print('🔍 [GoogleAuthService] User email: ${responseData['email']}');
        print('🔍 [GoogleAuthService] User ID: ${responseData['userId']}');
        
        // Debug: Print the entire response structure
        print('🔍 [GoogleAuthService] Full response structure:');
        responseData.forEach((key, value) {
          if (value is Map || value is List) {
            print('  $key: ${value.runtimeType} (keys/length: ${value is Map ? value.keys.toList() : value.length})');
          } else {
            print('  $key: $value (${value.runtimeType})');
          }
        });
        
        // Extract calendars from the unified response
        List<Calendar> calendars = [];
        List? calendarsData;
        
        // Try different possible locations for calendars
        if (responseData['calendars'] != null) {
          calendarsData = responseData['calendars'] as List;
          print('🔍 [GoogleAuthService] Found calendars directly in response');
        } else if (responseData['data'] != null && responseData['data']['calendars'] != null) {
          calendarsData = responseData['data']['calendars'] as List;
          print('🔍 [GoogleAuthService] Found calendars in data.calendars');
        } else if (responseData['data'] != null && responseData['data']['allCalendars'] != null) {
          calendarsData = responseData['data']['allCalendars'] as List;
          print('🔍 [GoogleAuthService] Found calendars in data.allCalendars');
        } else if (responseData['data'] != null) {
          // Debug: Show what's in the data object
          final dataObj = responseData['data'];
          print('🔍 [GoogleAuthService] Data object keys: ${dataObj is Map ? dataObj.keys.toList() : 'Not a map'}');
          if (dataObj is Map && dataObj.containsKey('items')) {
            calendarsData = dataObj['items'] as List;
            print('🔍 [GoogleAuthService] Found calendars in data.items');
          }
        }
        
        if (calendarsData != null) {
          print('🔍 [GoogleAuthService] Found ${calendarsData.length} calendars in response');
          print('🔍 [GoogleAuthService] First calendar sample: ${calendarsData.isNotEmpty ? calendarsData.first : 'None'}');
          calendars = calendarsData
              .map((json) => Calendar.fromGoogleJson(json))
              .toList();
          print('🔍 [GoogleAuthService] Parsed ${calendars.length} calendar objects');
        } else {
          print('⚠️ [GoogleAuthService] No calendars found in backend response');
          print('🔍 [GoogleAuthService] Available response fields: ${responseData.keys.toList()}');
          if (responseData['data'] != null) {
            print('🔍 [GoogleAuthService] Data fields: ${responseData['data'] is Map ? responseData['data'].keys.toList() : 'Not a map'}');
          }
        }

        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': responseData['email'] ?? responseData['data']?['email'],
          'data': responseData,
          'calendars': calendars,
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ [GoogleAuthService] Backend request failed with status: ${response.statusCode}');
        print('🔍 [GoogleAuthService] Error response: $errorData');
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Exception in sendAuthCodeToBackend: $e');
      print('🔍 [GoogleAuthService] Exception type: ${e.runtimeType}');
      print('🔍 [GoogleAuthService] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend: $e',
      };
    }
  }
}