import 'dart:async';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInResult.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftAuthService.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

class MicrosoftSignInOutService {
  late final MicrosoftAuthService _microsoftAuthService;
  late final AuthService _authService;

  MicrosoftSignInOutService({
    MicrosoftAuthService? microsoftAuthService,
    AuthService? authService,
  })  : _microsoftAuthService = microsoftAuthService ?? MicrosoftAuthService(),
        _authService = authService ?? AuthService();

  /// Handles Microsoft sign-in with authorization code
  Future<MicrosoftSignInResult> microsoftSignIn(String authCode) async {

    try {
      // Send auth code to backend for token exchange
      final response = await _microsoftAuthService.sendAuthCodeToBackend(authCode);
      
      print('🔍 [MicrosoftSignInOutService] Backend response: $response');

      
      if (response['success']) {
        // Get userId from stored auth token instead of backend response  
        final userId = await _authService.getUserId();
        
        // Try multiple possible locations for email in the response
        // Backend response structure: { data: { calendars: [...], user: { email: "..." } } }
        final email = response['email'] ?? 
                     response['data']?['email'] ?? 
                     response['data']?['microsoftEmail'] ??
                     response['data']?['user']?['email'];
        
        // Extract calendars from response or data object
        // Standardized backend response: { success: true, data: { calendars: [...], user: {...} } }
        final calendarsData = response['data']?['calendars'] ?? 
                            response['data']?['data']?['calendars'];
        
        List<Calendar> calendars = [];
        if (calendarsData != null) {
          try {
            calendars = (calendarsData as List)
                .map((item) => Calendar.fromJson(item))
                .toList();
          } catch (e) {
            print('❌ [MicrosoftSignInOutService] Error parsing calendars: $e');
          }
        }
        
        
        return MicrosoftSignInResult(
          userId: userId ?? '',
          email: email ?? '',
          authCode: authCode,
          calendars: calendars,
        );
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';
        print('❌ [MicrosoftSignInOutService] Microsoft Sign-In failed: $errorMessage');
        throw Exception('Microsoft authentication failed: $errorMessage');
      }
    } catch (e) {
      print('❌ [MicrosoftSignInOutService] Exception during Microsoft sign-in: $e');
      rethrow;
    }
  }

  /// Signs out from Microsoft (if needed)
  Future<void> microsoftSignOut() async {
    try {
      // Implement Microsoft-specific sign-out logic if needed
      // This might involve revoking tokens or clearing local state
    } catch (e) {
      print('❌ [MicrosoftSignInOutService] Error during Microsoft sign-out: $e');
      rethrow;
    }
  }
}