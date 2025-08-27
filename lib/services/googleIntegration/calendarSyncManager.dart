import 'package:timelyst_flutter/models/calendars.dart';
import './googleCalendarService.dart';

class CalendarSyncManager {
  final GoogleCalendarService _googleCalendarService;
  String? _currentSyncToken;

  CalendarSyncManager({GoogleCalendarService? calendarService})
      : _googleCalendarService = calendarService ?? GoogleCalendarService();

  Future<CalendarSyncResult> syncCalendars(
      String userId, String email) async {
    try {
      // logger.i('Syncing calendars');

      final calendars = await _googleCalendarService.fetchCalendarsPage(
        userId: userId,
        email: email,
      );
      // logger.i('Calendars: $calendars');

      return CalendarSyncResult.success(calendars: calendars);
    } catch (e) {
      return CalendarSyncResult.error(e.toString());
    }
  }

  Future<CalendarSaveResult> saveSelectedCalendars({
    required String userId,
    required String email,
    required List<Calendar> selectedCalendars,
  }) async {
    // logger.i('Saving selected calendars $userId $email in saveSelectedCalendars');
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

  Future<CalendarSyncResult> syncCalendarChanges(
    String userId,
    String email,
  ) async {
    // logger.i('Performing incremental sync $userId $email in syncCalendarChanges');
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

  Future<CalendarSyncResult> _performInitialSync(
    String userId,
    String email,
  ) async {
    final allCalendars = <Calendar>[];
    // logger.i(
    //     'Performing initial calendar sync $userId $email in _performInitialSync');
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
}

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
