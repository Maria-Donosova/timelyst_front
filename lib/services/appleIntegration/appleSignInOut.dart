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
    print('🔍 [AppleSignInOutService] Starting Apple Calendar connection');
    print('🔍 [AppleSignInOutService] Apple ID: $appleId');

    try {
      // Connect to Apple Calendar using CalDAV
      final response = await _calDAVService.connectAppleCalendar(
        appleId: appleId,
        appPassword: appPassword,
      );

      print('🔍 [AppleSignInOutService] Received response from CalDAV service');
      print('🔍 [AppleSignInOutService] Response success: ${response['success']}');
      
      if (response['success']) {
        // Get userId from stored auth token
        final userId = await _authService.getUserId();
        
        // Get email from response or use appleId
        final email = response['email'] ?? appleId;
        
        // Fetch initial calendars
        final calendarsResponse = await _calDAVService.fetchAppleCalendars(email);
        final calendars = calendarsResponse['data'] as List?;
        
        print('✅ [AppleSignInOutService] Apple Calendar connection successful');
        print('🔍 [AppleSignInOutService] User ID: $userId');
        print('🔍 [AppleSignInOutService] User email: $email');
        print('🔍 [AppleSignInOutService] Number of calendars: ${calendars?.length ?? 0}');
        
        final calendarsList = calendars is List 
          ? calendars.map((cal) => Calendar.fromAppleJson(cal as Map<String, dynamic>)).toList()
          : <Calendar>[];
        
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
      print('🔍 [AppleSignInOutService] Starting Apple Calendar disconnect');
      
      if (email != null) {
        await _calDAVService.disconnectAppleAccount(email);
      } else {
        await _calDAVService.deleteAppleCalendars();
      }
      
      print('✅ [AppleSignInOutService] Apple Calendar disconnect completed');
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
      print('🔍 [AppleSignInOutService] Saving selected calendars');
      
      await _calDAVService.saveSelectedCalendars(
        email: email,
        calendars: calendars,
      );
      
      print('✅ [AppleSignInOutService] Calendars saved successfully');
    } catch (e) {
      print('❌ [AppleSignInOutService] Error saving calendars: $e');
      rethrow;
    }
  }

  /// Fetches calendars for an email
  Future<List<Calendar>> fetchCalendars(String email) async {
    try {
      print('🔍 [AppleSignInOutService] Fetching calendars for: $email');
      
      final response = await _calDAVService.fetchAppleCalendars(email);
      final calendars = response['data'] as List?;
      
      final calendarsList = calendars is List 
        ? calendars.map((cal) => Calendar.fromAppleJson(cal as Map<String, dynamic>)).toList()
        : <Calendar>[];
      
      print('✅ [AppleSignInOutService] Fetched ${calendarsList.length} calendars');
      return calendarsList;
    } catch (e) {
      print('❌ [AppleSignInOutService] Error fetching calendars: $e');
      rethrow;
    }
  }
}