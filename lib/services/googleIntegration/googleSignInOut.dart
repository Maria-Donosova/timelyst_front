import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';
import '../../models/calendars.dart';
import 'googleAuthService.dart';
import 'google_sign_in_singleton.dart';
import '../authService.dart';

class GoogleSignInOutService {
  final GoogleSignIn _googleSignIn;
  late final GoogleAuthService _googleAuthService;
  late final AuthService _authService;

  GoogleSignInOutService({GoogleSignIn? googleSignIn, GoogleAuthService? googleAuthService, AuthService? authService})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _authService = authService ?? AuthService();

  Future<GoogleSignInResult> googleSignIn(String serverAuthCode) async {
    try {
      
      final response =
          await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

      
      if (response['success']) {
        // Get userId from stored auth token instead of backend response  
        final userId = await _authService.getUserId();
        
        print('🔍 [GoogleSignInOutService] Full backend response data: $response');
        
        // Try multiple possible locations for email in the response
        final email = response['email'] ?? 
                     response['data']?['email'] ?? 
                     response['data']?['googleEmail'];
        
        // Fix: Backend returns 'calendars' inside 'data' object
        // Also need to parse the JSON list into Calendar objects
        final calendarsList = (response['allCalendars'] ?? 
                              response['data']?['calendars'] ?? 
                              response['calendars']) as List?;
        final calendars = calendarsList
            ?.map((json) => Calendar.fromJson(json as Map<String, dynamic>))
            .toList();
        
        
        // CRITICAL FIX: Save the email to secure storage for Google Calendar integration
        if (email != null && email.isNotEmpty) {
          await _authService.saveUserEmail(email);
        } else {
          print('⚠️ [GoogleSignInOutService] No email found in Google Sign-In response - Google Calendar integration will not work');
        }
        
        return GoogleSignInResult(
          userId: userId ?? '',
          email: email ?? '',
          authCode: serverAuthCode,
          calendars: calendars,
        );
      } else {
        print('❌ [GoogleSignInOutService] Backend response unsuccessful');
        throw GoogleSignInException(
            'Error from backend: ${response['message']}');
      }
    } on TimeoutException {
      print('❌ [GoogleSignInOutService] Google Sign-In timed out');
      throw GoogleSignInException('Google Sign-In timed out');
    } catch (error, stackTrace) {
      print('❌ [GoogleSignInOutService] Exception during Google Sign-In: $error');
      if (error is GoogleSignInException) {
        rethrow;
      }
      throw GoogleSignInException('Error during web sign-in: $error');
    }
  }

  Future<void> googleDisconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInOutService] Error disconnecting Google account: $e');
      throw GoogleSignInException('Error disconnecting Google account: $e');
    }
  }

  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, stackTrace) {
      print('❌ [GoogleSignInOutService] Google sign-out failed: $e');
      throw GoogleSignInException('Google sign-out failed: $e');
    }
  }
}
