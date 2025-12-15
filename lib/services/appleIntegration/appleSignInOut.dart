import 'dart:async';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalDAVService.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

/// Updated Apple Sign-In/Out Service using CalDAV authentication
class AppleSignInOutService {
  late final AppleCalDAVService _calDAVService;
  late final AuthService _authService;

  AppleSignInOutService({
    AppleCalDAVService? calDAVService,
    AuthService? authService,
  })  : _calDAVService = calDAVService ?? AppleCalDAVService(),
        _authService = authService ?? AuthService();

  /// Handles Apple Calendar connection with Apple ID and App-Specific Password
  Future<AppleSignInResult> appleSignIn(String appleId, String appPassword) async {

    try {
      // Connect to Apple Calendar using CalDAV
      final response = await _calDAVService.connectAppleCalendar(
        appleId: appleId,
        appPassword: appPassword,
      );

      
      if (response['success']) {
        // Get userId from stored auth token
        final userId = await _authService.getUserId();
        
        // Get email from response or use appleId
        final email = response['email'] ?? appleId;
        
        // Fetch initial calendars using unified endpoint
        final calendarsList = await _calDAVService.fetchAppleCalendars();
        
        return AppleSignInResult(
          userId: userId ?? '',
          email: email,
          authCode: null, // Not used for CalDAV
          calendars: calendarsList,
        );
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';
        print('❌ [AppleSignInOutService] Apple Calendar connection failed: $errorMessage');
        throw Exception('Apple Calendar connection failed: $errorMessage');
      }
    } catch (e) {
      print('❌ [AppleSignInOutService] Exception during Apple Calendar connection: $e');
      rethrow;
    }
  }

  /// Disconnects Apple Calendar account
  Future<void> appleSignOut({String? email}) async {
    try {
      
      if (email != null) {
        await _calDAVService.disconnectAppleAccount(email);
      } else {
        await _calDAVService.deleteAppleCalendars();
      }
      
    } catch (e) {
      print('❌ [AppleSignInOutService] Error during Apple Calendar disconnect: $e');
      rethrow;
    }
  }

  /// Saves selected calendars
  Future<void> saveSelectedCalendars({
    required String email,
    required List<Map<String, dynamic>> calendars,
  }) async {
    try {
      
      await _calDAVService.saveSelectedCalendars(
        email: email,
        calendars: calendars,
      );
      
    } catch (e) {
      print('❌ [AppleSignInOutService] Error saving calendars: $e');
      rethrow;
    }
  }

  /// Fetches calendars for an email
  Future<List<Calendar>> fetchCalendars() async {
    try {
      return await _calDAVService.fetchAppleCalendars();
    } catch (e) {
      print('❌ [AppleSignInOutService] Error fetching calendars: $e');
      rethrow;
    }
  }
}