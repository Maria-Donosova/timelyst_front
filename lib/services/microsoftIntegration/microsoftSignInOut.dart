import 'dart:async';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInResult.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftAuthService.dart';
import 'package:timelyst_flutter/services/authService.dart';

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

      
      if (response['success']) {
        // Get userId from stored auth token instead of backend response  
        final userId = await _authService.getUserId();
        
        // Try multiple possible locations for email in the response
        final email = response['email'] ?? 
                     response['data']?['email'] ?? 
                     response['data']?['microsoftEmail'];
        final calendars = response['calendars'];
        
        
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