import './googleCalendarService.dart';
import '../../models/calendars.dart';

class GoogleOrchestrator {
  final GoogleCalendarService _googleCalendarService;
  String? _currentSyncToken;

  GoogleOrchestrator({
    GoogleCalendarService? calendarService,
  }) : _googleCalendarService = calendarService ?? GoogleCalendarService();

  Future<CalendarSyncResult> syncCalendars(String userId, String email) async {
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
