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
      print('Signing in and syncing calendars in signInAndSyncCalendars');
      // Step 1: Sign in with Google
      final signInResult = await _googleSignInOutService.googleSignIn(context);
      print('Sign in result: $signInResult');
      final userId = signInResult['userId'];
      final email = signInResult['email'];
      print('User ID: $userId signed in with email: $email');

      // Step 2: Sync google calendars
      final calendars = await _googleCalendarService.fetchCalendarsPage(
        userId: userId,
        email: email,
      );
      print('Calendars: $calendars');
      // Step 2: Perform initial calendar sync
      // final initialSyncResult = await _performInitialSync(userId, email);
      // print('Initial sync result: $initialSyncResult');

      // Step 3: Navigate to calendar settings
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarSettings(
              userId: userId,
              email: email,
              calendars:
                  CalendarSyncResult.success(calendars: calendars).calendars,
            ),
          ),
        );

        // After returning from CalendarSettings, perform a sync to get any changes
        return CalendarSyncResult.success(calendars: calendars);
      }

      return CalendarSyncResult.success(calendars: calendars);
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
    print(
        'Performing initial calendar sync $userId $email in _performInitialSync');
    bool hasMore = true;

    while (hasMore) {
      final page = await _googleCalendarService.fetchCalendarsPage(
        userId: userId,
        email: email,
      );

      allCalendars.addAll(page.calendars);
      hasMore = page.hasMore;
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
    print('Performing incremental sync $userId $email in syncCalendarChanges');
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
    print('Saving selected calendars $userId $email in saveSelectedCalendars');
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
