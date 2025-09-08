import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';
import 'googleAuthService.dart';
import 'google_sign_in_singleton.dart';

class GoogleSignInOutService {
  final GoogleSignIn _googleSignIn;
  late final GoogleAuthService _googleAuthService;

  GoogleSignInOutService({GoogleSignIn? googleSignIn, GoogleAuthService? googleAuthService})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _googleAuthService = googleAuthService ?? GoogleAuthService();

  Future<GoogleSignInResult> googleSignIn(String serverAuthCode) async {
    try {
      print('🔍 [GoogleSignInOutService] Starting Google Sign-In process...');
      print('🔍 [GoogleSignInOutService] Server auth code provided: ${serverAuthCode.length > 10 ? serverAuthCode.substring(0, 10) + '...' : serverAuthCode}');
      
      final response =
          await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

      print('🔍 [GoogleSignInOutService] Received response from GoogleAuthService');
      print('🔍 [GoogleSignInOutService] Response success: ${response['success']}');
      
      if (response['success']) {
        final userId = response['data']['userId'];
        final email = response['email'];
        final calendars = response['calendars'];
        
        print('✅ [GoogleSignInOutService] Google Sign-In successful');
        print('🔍 [GoogleSignInOutService] User ID: $userId');
        print('🔍 [GoogleSignInOutService] User email: $email');
        print('🔍 [GoogleSignInOutService] Number of calendars: ${calendars?.length ?? 0}');
        
        if (calendars != null && calendars.isNotEmpty) {
          print('🔍 [GoogleSignInOutService] Calendar names: ${(calendars as List<Calendar>).map((c) => c.metadata.title ?? 'No name').toList()}');
        }
        
        return GoogleSignInResult(
          userId: userId,
          email: email,
          authCode: serverAuthCode,
          calendars: calendars,
        );
      } else {
        print('❌ [GoogleSignInOutService] Backend response unsuccessful');
        print('🔍 [GoogleSignInOutService] Error message: ${response['message']}');
        print('🔍 [GoogleSignInOutService] Error details: ${response['error']}');
        throw GoogleSignInException(
            'Error from backend: ${response['message']}');
      }
    } on TimeoutException {
      print('❌ [GoogleSignInOutService] Google Sign-In timed out');
      throw GoogleSignInException('Google Sign-In timed out');
    } catch (error, stackTrace) {
      print('❌ [GoogleSignInOutService] Exception during Google Sign-In: $error');
      print('🔍 [GoogleSignInOutService] Exception type: ${error.runtimeType}');
      print('🔍 [GoogleSignInOutService] Stack trace: $stackTrace');
      if (error is GoogleSignInException) {
        rethrow;
      }
      throw GoogleSignInException('Error during web sign-in: $error');
    }
  }

  Future<void> googleDisconnect() async {
    try {
      print('🔍 [GoogleSignInOutService] Starting Google account disconnect...');
      await _googleSignIn.disconnect();
      print('✅ [GoogleSignInOutService] Google account disconnected successfully');
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInOutService] Error disconnecting Google account: $e');
      print('🔍 [GoogleSignInOutService] Stack trace: $stackTrace');
      throw GoogleSignInException('Error disconnecting Google account: $e');
    }
  }

  Future<void> googleSignOut() async {
    try {
      print('🔍 [GoogleSignInOutService] Starting Google sign-out...');
      await _googleSignIn.signOut();
      print('✅ [GoogleSignInOutService] Google sign-out completed successfully');
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInOutService] Google sign-out failed: $e');
      print('🔍 [GoogleSignInOutService] Stack trace: $stackTrace');
      throw GoogleSignInException('Google sign-out failed: $e');
    }
  }
}
