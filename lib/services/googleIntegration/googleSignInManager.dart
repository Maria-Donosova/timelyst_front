import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';
import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

class GoogleSignInManager {
  final GoogleSignInOutService _googleSignInOutService;

  GoogleSignInManager({GoogleSignInOutService? signInService})
      : _googleSignInOutService = signInService ?? GoogleSignInOutService();

  Future<GoogleSignInResult?> signIn(BuildContext context) async {
    try {
      _googleSignInOutService.initialize();
      return await _googleSignInOutService.googleSignIn();
    } on GoogleSignInException catch (e) {
      _showError(context, e.message);
      return null;
    } catch (e) {
      _showError(context, 'An unexpected error occurred: $e');
      return null;
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
