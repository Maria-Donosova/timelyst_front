import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalendarService.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleAuthService.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalDAVService.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';
import 'package:timelyst_flutter/models/calendars.dart';

/// Manager for Apple Calendar CalDAV integration
/// Replaces the OAuth-based AppleSignInManager with direct credential authentication
class AppleCalDAVManager {
  final AppleCalendarService _appleCalendarService;
  final AppleAuthService _appleAuthService;
  final AppleCalDAVService _appleCalDAVService;

  AppleCalDAVManager({
    AppleCalendarService? appleCalendarService,
    AppleAuthService? appleAuthService,
    AppleCalDAVService? appleCalDAVService,
  })  : _appleCalendarService = appleCalendarService ?? AppleCalendarService(),
        _appleAuthService = appleAuthService ?? AppleAuthService(),
        _appleCalDAVService = appleCalDAVService ?? AppleCalDAVService();

  /// Connects to Apple Calendar using Apple ID and App-Specific Password
  Future<AppleSignInResult> connectAppleCalendar({
    required String appleId,
    required String appPassword,
  }) async {
    try {
      // 1. Connect/Authenticate
      final authResult = await _appleAuthService.connectAppleAccount(
        appleId,
        appPassword,
      );

      if (authResult['success'] == true) {
        // 2. Fetch calendars from Apple (using the legacy service for now as it has the endpoint)
        // Ideally this should be part of the connect response or a method in AppleCalendarService
        final calendarsResponse =
            await _appleCalDAVService.fetchAppleCalendars(appleId);

        // Standardized backend response: { success: true, data: { calendars: [...], user: {...} } }
        final calendarsData = calendarsResponse['data']?['calendars'];
        final calendarsList = calendarsData is List
            ? calendarsData
                .map((cal) => Calendar.fromJson(cal as Map<String, dynamic>))
                .toList()
            : <Calendar>[];

        return AppleSignInResult(
          userId: authResult['userId'] ?? '', // Assuming auth returns userId
          email: appleId,
          authCode: null,
          calendars: calendarsList,
        );
      } else {
        throw Exception(
            authResult['message'] ?? 'Failed to connect Apple Calendar');
      }
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error connecting Apple Calendar: $e');
      rethrow;
    }
  }

  /// Fetches Apple calendars for a connected account
  Future<List<Calendar>> fetchCalendars(String email) async {
    try {
      final response = await _appleCalDAVService.fetchAppleCalendars(email);
      
      // Standardized backend response: { success: true, data: { calendars: [...], user: {...} } }
      final calendarsData = response['data']?['calendars'];

      if (calendarsData != null) {
        final calendars = calendarsData as List;
        return calendars
            .map((cal) => Calendar.fromJson(cal as Map<String, dynamic>))
            .toList();
      }
      return [];
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
      // Enhanced logging: Show each calendar to be saved
      for (int i = 0; i < selectedCalendars.length; i++) {
        final calendar = selectedCalendars[i];
        print('  🍎 ID: ${calendar['id'] ?? calendar['providerCalendarId']}');
        print(
            '  🍎 Title: ${calendar['metadata']?['title'] ?? calendar['title']}');
        print('  🍎 Import All: ${calendar['importAll']}');
        print('  🍎 Import Subject: ${calendar['importSubject']}');
        print('  🍎 Category: ${calendar['category']}');
        print('  🍎 Color: ${calendar['color']}');
      }

      // Filter out calendars with no import options enabled
      final validCalendars = selectedCalendars.where((calendar) {
        final hasImportOptions = calendar['importAll'] == true ||
            calendar['importSubject'] == true ||
            calendar['importBody'] == true ||
            calendar['importConferenceInfo'] == true ||
            calendar['importOrganizer'] == true ||
            calendar['importRecipients'] == true;

        return hasImportOptions;
      }).toList();

      if (validCalendars.isEmpty) {
        print('❌ [AppleCalDAVManager] No valid calendars to save');
        throw Exception(
            'No valid calendars to save. Please enable at least one import option.');
      }

      // Convert Map<String, dynamic> to List<Calendar>
      final List<Calendar> calendarsToSync = validCalendars.map((calMap) {
        // Ensure required fields are present and map correctly
        // We use fromJson if possible, or manual mapping if the map structure is different
        // The selectedCalendars map comes from the UI selection which might be slightly different from backend JSON
        // But let's try to construct a Calendar object.

        return Calendar(
          id: calMap['id'] ?? '',
          userId: calMap['user'] ?? '',
          source: CalendarSource.APPLE,
          providerCalendarId: calMap['providerCalendarId'] ?? '',
          metadata: CalendarMetadata(
            title: calMap['metadata']?['title'] ?? calMap['title'] ?? 'Unknown',
            color: calMap['metadata']?['color'] ?? calMap['color'] ?? '#000000',
            timeZone: calMap['metadata']?['timeZone'] ?? 'UTC',
          ),
          preferences: CalendarPreferences(
            category: calMap['category'],
            importSettings: CalendarImportSettings(
              importAll: calMap['importAll'] ?? false,
              importSubject: calMap['importSubject'] ?? false,
              importBody: calMap['importBody'] ?? false,
              importConferenceInfo: calMap['importConferenceInfo'] ?? false,
              importOrganizer: calMap['importOrganizer'] ?? false,
              importRecipients: calMap['importRecipients'] ?? false,
            ),
          ),
          sync: CalendarSyncInfo(
            syncToken: calMap['syncToken'],
            lastSyncedAt: calMap['lastSync'] != null
                ? DateTime.tryParse(calMap['lastSync'])
                : null,
          ),
          isSelected: true,
          isPrimary: calMap['isPrimary'] ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      await _appleCalendarService.syncAppleCalendars(
        userId: '', // This will be handled by the backend or service if needed
        email: email,
        calendars: calendarsToSync,
      );
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error saving calendars: $e');
      rethrow;
    }
  }

  /// Deletes all Apple calendars for the user
  Future<void> deleteCalendars() async {
    try {
      await _appleCalDAVService.deleteAppleCalendars();
    } catch (e) {
      print('❌ [AppleCalDAVManager] Error deleting calendars: $e');
      rethrow;
    }
  }

  /// Disconnects an Apple account
  Future<void> disconnectAccount(String email) async {
    try {
      await _appleCalDAVService.disconnectAppleAccount(email);
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