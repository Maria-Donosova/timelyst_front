import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalDAVService.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';
import 'package:timelyst_flutter/models/calendars.dart';

/// Manager for Apple Calendar CalDAV integration
/// Replaces the OAuth-based AppleSignInManager with direct credential authentication
class AppleCalDAVManager {
  final AppleCalDAVService _calDAVService;

  AppleCalDAVManager({
    AppleCalDAVService? calDAVService,
  }) : _calDAVService = calDAVService ?? AppleCalDAVService();

  /// Connects to Apple Calendar using Apple ID and App-Specific Password
  /// This replaces the OAuth flow with direct credential authentication
  Future<AppleSignInResult> connectAppleCalendar({
    required String appleId,
    required String appPassword,
  }) async {
    try {
      print('🔍 [AppleCalDAVManager] Starting Apple Calendar connection');
      print('🔍 [AppleCalDAVManager] Apple ID: $appleId');

      // Validate inputs
      if (!_calDAVService.isValidAppleId(appleId)) {
        throw Exception('Please enter a valid Apple ID (email address)');
      }

      if (!_calDAVService.isValidAppPassword(appPassword)) {
        throw Exception('Please enter a valid 16-character App-Specific Password');
      }

      // Format the app password properly
      final formattedPassword = _calDAVService.formatAppPassword(appPassword);
      
      // Connect to Apple Calendar
      final response = await _calDAVService.connectAppleCalendar(
        appleId: appleId,
        appPassword: formattedPassword,
      );

      if (response['success'] == true) {
        print('✅ [AppleCalDAVManager] Apple Calendar connected successfully');
        
        // Fetch initial calendars
        final calendarsResponse = await _calDAVService.fetchAppleCalendars(appleId);
        
        final calendarsData = calendarsResponse['data'];
        final calendarsList = calendarsData is List 
          ? calendarsData.map((cal) => Calendar.fromAppleJson(cal as Map<String, dynamic>)).toList()
          : <Calendar>[];
        
        return AppleSignInResult(
          userId: response['userId'] ?? '',
          email: response['email'] ?? appleId,
          authCode: null, // Not used for CalDAV
          calendars: calendarsList,
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to connect Apple Calendar');
      }
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error connecting Apple Calendar: $e');
      rethrow;
    }
  }

  /// Fetches Apple calendars for a connected account
  Future<List<Calendar>> fetchCalendars(String email) async {
    try {
      print('🔍 [AppleCalDAVManager] Fetching Apple calendars for: $email');
      
      final response = await _calDAVService.fetchAppleCalendars(email);
      
      if (response['success'] == true) {
        final calendars = response['data'] as List?;
        
        final calendarsList = calendars is List 
          ? calendars.map((cal) => Calendar.fromAppleJson(cal as Map<String, dynamic>)).toList()
          : <Calendar>[];
        
        print('✅ [AppleCalDAVManager] Fetched ${calendarsList.length} calendars');
        
        return calendarsList;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch calendars');
      }
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error fetching calendars: $e');
      rethrow;
    }
  }

  /// Saves selected calendars and their events
  Future<void> saveSelectedCalendars({
    required String email,
    required List<Map<String, dynamic>> selectedCalendars,
  }) async {
    try {
      print('🔍 [AppleCalDAVManager] Saving ${selectedCalendars.length} selected calendars');
      
      // Filter out calendars with no import options enabled
      final validCalendars = selectedCalendars.where((calendar) {
        return calendar['importAll'] == true ||
               calendar['importSubject'] == true ||
               calendar['importBody'] == true ||
               calendar['importConferenceInfo'] == true ||
               calendar['importOrganizer'] == true ||
               calendar['importRecipients'] == true;
      }).toList();

      if (validCalendars.isEmpty) {
        throw Exception('No valid calendars to save. Please enable at least one import option.');
      }

      final response = await _calDAVService.saveSelectedCalendars(
        email: email,
        calendars: validCalendars,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to save calendars');
      }

      print('✅ [AppleCalDAVManager] Apple calendars and events saved successfully');
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error saving calendars: $e');
      rethrow;
    }
  }

  /// Deletes all Apple calendars for the user
  Future<void> deleteCalendars() async {
    try {
      print('🔍 [AppleCalDAVManager] Deleting Apple calendars');
      
      final response = await _calDAVService.deleteAppleCalendars();
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete calendars');
      }

      print('✅ [AppleCalDAVManager] Apple calendars deleted successfully');
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error deleting calendars: $e');
      rethrow;
    }
  }

  /// Disconnects an Apple account
  Future<void> disconnectAccount(String email) async {
    try {
      print('🔍 [AppleCalDAVManager] Disconnecting Apple account: $email');
      
      final response = await _calDAVService.disconnectAppleAccount(email);
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to disconnect account');
      }

      print('✅ [AppleCalDAVManager] Apple account disconnected successfully');
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error disconnecting account: $e');
      rethrow;
    }
  }

  /// Shows a help dialog explaining how to generate an App-Specific Password
  static void showAppPasswordHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Generate App-Specific Password'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'To connect your Apple Calendar, you need an App-Specific Password:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('1. Go to appleid.apple.com'),
                SizedBox(height: 8),
                Text('2. Sign in with your Apple ID'),
                SizedBox(height: 8),
                Text('3. Navigate to "Sign-In and Security"'),
                SizedBox(height: 8),
                Text('4. Click "App-Specific Passwords"'),
                SizedBox(height: 8),
                Text('5. Click "Generate Password"'),
                SizedBox(height: 8),
                Text('6. Enter "Timelyst" as the label'),
                SizedBox(height: 8),
                Text('7. Copy the 16-character password'),
                SizedBox(height: 8),
                Text('8. Use this password (not your Apple ID password) here'),
                SizedBox(height: 16),
                Text(
                  'Note: You need to have Two-Factor Authentication enabled on your Apple ID to generate App-Specific Passwords.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}