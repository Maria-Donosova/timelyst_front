import 'package:flutter/material.dart';
import 'googleSignInOut.dart';
import 'googleCalendarService.dart';
import '../../models/calendars.dart';
import '../../screens/common/calendarSettings.dart';

class GoogleOrchestrator {
  final GoogleCalendarService _googleCalendarService;
  final GoogleSignInOutService _googleSignInOutService;
  String? _currentSyncToken;

  GoogleOrchestrator({
    GoogleCalendarService? calendarService,
    GoogleSignInOutService? signInService,
  })  : _googleCalendarService = calendarService ?? GoogleCalendarService(),
        _googleSignInOutService = signInService ?? GoogleSignInOutService();

  /// Orchestrates the complete Google sign-in and calendar sync process
  Future<CalendarSyncResult> signInAndSyncCalendars(
      BuildContext context) async {
    try {
      // Step 1: Sign in with Google
      final signInResult = await _googleSignInOutService.googleSignIn(context);
      final userId = signInResult['userId'];
      final email = signInResult['email'];

      // Step 2: Perform initial calendar sync
      final initialSyncResult = await _performInitialSync(userId, email);

      // Step 3: Navigate to calendar settings
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarSettings(
              userId: userId,
              email: email,
              calendars: initialSyncResult.calendars,
            ),
          ),
        );

        // After returning from CalendarSettings, perform a sync to get any changes
        return await syncCalendarChanges(userId, email);
      }

      return initialSyncResult;
    } catch (e) {
      _showError(context, 'Failed to sync calendars: $e');
      return CalendarSyncResult.error(e.toString());
    }
  }

  /// Performs initial calendar sync with pagination
  Future<CalendarSyncResult> _performInitialSync(
    String userId,
    String email,
  ) async {
    final allCalendars = <Calendar>[];
    String? pageToken;
    bool hasMore = true;

    while (hasMore) {
      final page = await _googleCalendarService.fetchCalendarsPage(
        userId: userId,
        email: email,
        pageToken: pageToken,
      );

      allCalendars.addAll(page.calendars);
      hasMore = page.hasMore;
      pageToken = page.nextPageToken;
      _currentSyncToken = page.syncToken;
    }

    return CalendarSyncResult.success(
      calendars: allCalendars,
      syncToken: _currentSyncToken,
    );
  }

  /// Performs incremental sync using delta tokens
  Future<CalendarSyncResult> syncCalendarChanges(
    String userId,
    String email,
  ) async {
    if (_currentSyncToken == null) {
      return await _performInitialSync(userId, email);
    }

    try {
      final delta = await _googleCalendarService.fetchCalendarChanges(
        userId: userId,
        email: email,
        syncToken: _currentSyncToken!,
      );

      _currentSyncToken = delta.newSyncToken;

      return CalendarSyncResult.delta(
        changes: delta.changes,
        deletedIds: delta.deletedCalendarIds,
        syncToken: delta.newSyncToken,
        hasMoreChanges: delta.hasMoreChanges,
      );
    } catch (e) {
      if (e.toString().contains('410')) {
        // Sync token expired, fall back to full sync
        return await _performInitialSync(userId, email);
      }
      rethrow;
    }
  }

  /// Saves selected calendars with batch support
  Future<CalendarSaveResult> saveSelectedCalendars({
    required String userId,
    required String email,
    required List<Calendar> selectedCalendars,
  }) async {
    try {
      await _googleCalendarService.saveCalendarsBatch(
        userId: userId,
        email: email,
        calendars: selectedCalendars,
      );

      // Update sync token after changes
      final syncResult = await syncCalendarChanges(userId, email);
      _currentSyncToken = syncResult.syncToken;

      return CalendarSaveResult.success();
    } catch (e) {
      return CalendarSaveResult.error(e.toString());
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

/// Result types for better type safety
class CalendarSyncResult {
  final List<Calendar> calendars;
  final List<Calendar>? changes;
  final List<String>? deletedIds;
  final String? syncToken;
  final bool hasMoreChanges;
  final String? error;

  CalendarSyncResult._({
    this.calendars = const [],
    this.changes,
    this.deletedIds,
    this.syncToken,
    this.hasMoreChanges = false,
    this.error,
  });

  factory CalendarSyncResult.success({
    required List<Calendar> calendars,
    String? syncToken,
  }) =>
      CalendarSyncResult._(calendars: calendars, syncToken: syncToken);

  factory CalendarSyncResult.delta({
    required List<Calendar> changes,
    required List<String> deletedIds,
    required String syncToken,
    bool hasMoreChanges = false,
  }) =>
      CalendarSyncResult._(
        changes: changes,
        deletedIds: deletedIds,
        syncToken: syncToken,
        hasMoreChanges: hasMoreChanges,
      );

  factory CalendarSyncResult.error(String error) =>
      CalendarSyncResult._(error: error);

  bool get isSuccess => error == null;
  bool get isDelta => changes != null;
}

class CalendarSaveResult {
  final bool success;
  final String? error;

  CalendarSaveResult._({this.success = false, this.error});

  factory CalendarSaveResult.success() => CalendarSaveResult._(success: true);
  factory CalendarSaveResult.error(String error) =>
      CalendarSaveResult._(error: error);
}

// import 'package:flutter/material.dart';

// import 'googleSignInOut.dart';
// import 'googleCalendarService.dart';

// import '../../models/calendars.dart';

// import '../../screens/common/calendarSettings.dart';

// class GoogleOrchestrator {
//   final GoogleCalendarService _googleCalendarService = GoogleCalendarService();
//   final GoogleSignInOutService _googleSingInOutService =
//       GoogleSignInOutService();

//   // Orchestrate the Google Sign-In and Calendar Fetching Process
//   Future<Map<String, dynamic>> signInAndFetchCalendars(
//     BuildContext context,
//   ) async {
//     print("Entering signInAndFetchCalendars");
//     try {
//       // Step 1: Sign in with Google
//       final signInResult = await _googleSingInOutService.googleSignIn(
//         context,
//       );
//       print("Sign-in result: $signInResult");

//       // Step 2: Fetch Google Calendars
//       final userId = signInResult['userId'];
//       final email = signInResult['email'];
//       print("userID: $userId");
//       print("email: $email");

//       final calendars =
//           await _googleCalendarService.fetchGoogleCalendars(userId, email);
//       print(
//           "Google calendars returned by the backend: ${calendars.map((calendar) => calendar.toString()).join('\n')}");

//       // Step 3: Display Calendars to the User (You can navigate to a new screen here)
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CalendarSettings(
//             userId: userId,
//             email: email,
//             calendars: calendars,
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       return {'error': e.toString()};
//     }
//     return {'status': 'success'};
//   }

//   // Orchestrate the Calendar Saving Process
//   Future<Map<String, dynamic>> saveSelectedCalendars(
//       String userId, googleAccount, List<Calendar> selectedCalendars) async {
//     print("Entering saveSelectedCalendars");
//     print("UserId: $userId");
//     print("Google Account: $googleAccount");
//     try {
//       await _googleCalendarService.saveSelectedCalendars(
//           userId, googleAccount, selectedCalendars);

//       return {'success': true, 'message': 'Calendars saved successfully!'};
//     } catch (e) {
//       return {'success': false, 'message': 'Failed to save calendars: $e'};
//     }
//   }
// }
