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
      final serverAuthCode =
          await _googleAuthService.requestServerAuthenticatioinCode();
      if (serverAuthCode != null) {
        return await _googleSignInOutService.googleSignIn(serverAuthCode);
      } else {
        // The user closed the sign-in popup
        return null;
      }
    } on GoogleSignInException catch (e) {
      _showError(context, e.message);
      return null;
    } catch (e) {
      _showError(context, 'An unexpected error occurred: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignInOutService.googleSignOut();
    } on GoogleSignInException catch (e) {
      // In this context, we can ignore sign-out errors
      print('Error during sign-out: ${e.message}');
    }
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
