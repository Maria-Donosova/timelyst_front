import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleAuthService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';
import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

class GoogleSignInManager {
  final GoogleSignInOutService _googleSignInOutService;
  final GoogleAuthService _googleAuthService;

  GoogleSignInManager(
      {GoogleSignInOutService? signInService, GoogleAuthService? authService})
      : _googleSignInOutService = signInService ?? GoogleSignInOutService(),
        _googleAuthService = authService ?? GoogleAuthService();

  Future<GoogleSignInResult?> signIn(BuildContext context) async {
    try {
      print('🔍 [GoogleSignInManager] Starting Google Sign-In process...');
      print('🔍 [GoogleSignInManager] Context mounted: ${context.mounted}');
      
      final serverAuthCode =
          await _googleAuthService.requestServerAuthenticatioinCode();
      
      if (serverAuthCode != null) {
        print('✅ [GoogleSignInManager] Server auth code obtained successfully');
        print('🔍 [GoogleSignInManager] Auth code length: ${serverAuthCode.length}');
        print('🔍 [GoogleSignInManager] Proceeding with backend authentication...');
        
        final result = await _googleSignInOutService.googleSignIn(serverAuthCode);
        print('✅ [GoogleSignInManager] Google Sign-In process completed successfully');
        return result;
      } else {
        print('⚠️ [GoogleSignInManager] Server auth code is null - user likely closed the sign-in popup');
        return null;
      }
    } on GoogleSignInException catch (e, stackTrace) {
      print('❌ [GoogleSignInManager] GoogleSignInException caught: ${e.message}');
      print('🔍 [GoogleSignInManager] Exception type: ${e.runtimeType}');
      print('🔍 [GoogleSignInManager] Stack trace: $stackTrace');
      _showError(context, e.message);
      return null;
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInManager] Generic exception caught: $e');
      print('🔍 [GoogleSignInManager] Exception type: ${e.runtimeType}');
      print('🔍 [GoogleSignInManager] Stack trace: $stackTrace');
      _showError(context, 'An unexpected error occurred: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      print('🔍 [GoogleSignInManager] Starting Google sign-out process...');
      await _googleSignInOutService.googleSignOut();
      print('✅ [GoogleSignInManager] Google sign-out completed successfully');
    } on GoogleSignInException catch (e, stackTrace) {
      // In this context, we can ignore sign-out errors
      print('⚠️ [GoogleSignInManager] GoogleSignInException during sign-out: ${e.message}');
      print('🔍 [GoogleSignInManager] Stack trace: $stackTrace');
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInManager] Generic exception during sign-out: $e');
      print('🔍 [GoogleSignInManager] Exception type: ${e.runtimeType}');
      print('🔍 [GoogleSignInManager] Stack trace: $stackTrace');
    }
  }

  void _showError(BuildContext context, String message) {
    print('🔍 [GoogleSignInManager] Showing error to user: $message');
    print('🔍 [GoogleSignInManager] Context mounted: ${context.mounted}');
    
    if (context.mounted) {
      print('✅ [GoogleSignInManager] Displaying SnackBar to user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      print('⚠️ [GoogleSignInManager] Context not mounted - cannot display error to user');
    }
  }
}
