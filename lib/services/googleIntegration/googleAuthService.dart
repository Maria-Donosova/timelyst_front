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
      final authCode = await web_only.requestServerAuthCode();
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      return authCode;
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error requesting auth code: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        return currentUser.email;
      } else {
        print('⚠️ [GoogleAuthService] No current user found');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error getting user email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      
      final authToken = await _authService.getAuthToken();
      final maskedToken = (authToken?.length ?? 0) > 10 ? '${authToken?.substring(0, 10)}...' : authToken;
      
      final body = {
        'code': authCode,
      };

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
        token: authToken,
      );
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract calendars from the unified response
        List<Calendar> calendars = [];
        if (responseData['calendars'] != null) {
          final calendarsData = responseData['calendars'] as List;
          calendars = <Calendar>[];
          for (var item in calendarsData) {
            if (item is Map<String, dynamic>) {
              calendars.add(Calendar.fromGoogleJson(item));
            } else {
              print('❌ [GoogleAuthService] Found invalid item in calendars list: $item');
            }
          }
        } else {
          print('⚠️ [GoogleAuthService] No calendars found in backend response');
        }

        // Get email from backend response, fallback to Google Sign-In if not provided
        String? email = responseData['email'];
        if (email == null) {
          print('⚠️ [GoogleAuthService] Email not found in backend response, getting from Google Sign-In...');
          email = await getCurrentUserEmail();
        }

        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': email,
          'data': responseData,
          'calendars': calendars,
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ [GoogleAuthService] Backend request failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Exception in sendAuthCodeToBackend: $e');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend: $e',
      };
    }
  }
}