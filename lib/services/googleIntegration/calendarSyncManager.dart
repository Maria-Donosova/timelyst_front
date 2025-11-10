import 'package:timelyst_flutter/models/calendars.dart';
import './googleCalendarService.dart';
import '../microsoftIntegration/microsoftCalendarService.dart';
import '../appleIntegration/appleCalDAVManager.dart';

class CalendarSyncManager {
  final GoogleCalendarService _googleCalendarService;
  String? _currentSyncToken;

  CalendarSyncManager({GoogleCalendarService? calendarService})
      : _googleCalendarService = calendarService ?? GoogleCalendarService();

  Future<CalendarSyncResult> syncCalendars(String userId, String email) async {
    try {
      final calendarPage = await _googleCalendarService.fetchCalendarsPage(
        userId: userId,
        email: email,
      );
      return CalendarSyncResult.success(
        calendars: calendarPage.calendars,
        syncToken: calendarPage.syncToken,
      );
    } on GoogleCalendarException catch (e) {
      print('CalendarSyncManager: Google auth error syncing calendars: $e');
      return CalendarSyncResult.error(
        e.toString(),
        statusCode: e.statusCode,
      );
    } catch (e) {
      print('CalendarSyncManager: ERROR syncing calendars: $e, $userId');
      return CalendarSyncResult.error(e.toString());
    }
  }

  Future<CalendarSaveResult> saveSelectedCalendars({
    required String userId,
    required String email,
    required List<Calendar> selectedCalendars,
  }) async {
    // Enhanced logging: Show all input calendars
    for (int i = 0; i < selectedCalendars.length; i++) {
      final calendar = selectedCalendars[i];
      print('  📅 Title: "${calendar.metadata.title}"');
      print('  📅 Source: ${calendar.source}');
      print('  📅 Provider ID: ${calendar.providerCalendarId}');
    }

    try {
      // Group calendars by provider
      final googleCalendars = selectedCalendars
          .where((cal) => cal.source == CalendarSource.google)
          .toList();
      final microsoftCalendars = selectedCalendars
          .where((cal) => cal.source == CalendarSource.outlook)
          .toList();
      final appleCalendars = selectedCalendars
          .where((cal) => cal.source == CalendarSource.apple)
          .toList();

      print('  📱 Google calendars: ${googleCalendars.length}');
      print('  📱 Microsoft calendars: ${microsoftCalendars.length}');
      print('  📱 Apple calendars: ${appleCalendars.length}');

      // Save Google calendars if any
      if (googleCalendars.isNotEmpty) {
        await _googleCalendarService.saveCalendarsBatch(
          userId: userId,
          email: email,
          calendars: googleCalendars,
        );
      }

      // Save Microsoft calendars if any
      if (microsoftCalendars.isNotEmpty) {
        final microsoftService = MicrosoftCalendarService();
        await microsoftService.saveCalendarsBatch(
          userId: userId,
          email: email,
          calendars: microsoftCalendars,
        );
      }

      // Save Apple calendars if any
      if (appleCalendars.isNotEmpty) {
        print(
            '📤 [CalendarSyncManager] Preparing to save ${appleCalendars.length} Apple calendars');

        // Log each Apple calendar before conversion
        for (int i = 0; i < appleCalendars.length; i++) {
          final calendar = appleCalendars[i];
          print(
              '📋 [APPLE] Calendar $i BEFORE flattening: "${calendar.metadata.title}"');
          print('  📊 Source: ${calendar.source}');
          print('  🔗 Provider ID: ${calendar.providerCalendarId}');
          print('  🏷️ Original Category: "${calendar.preferences.category}"');
          print(
              '  ✅ Import All: ${calendar.preferences.importSettings.importAll}');
          print(
              '  📝 Import Subject: ${calendar.preferences.importSettings.importSubject}');
        }

        final appleManager = AppleCalDAVManager();

        // Convert Calendar objects to format expected by Apple service
        // Use the same pattern as Microsoft calendars for backend compatibility
        final appleCalendarData = appleCalendars.map((calendar) {
          final json = calendar.toJson(email: email);

          // Log the original JSON structure before flattening
          print(
              '📋 [APPLE] Original toJson() structure for "${calendar.metadata.title}":');
          print('  📁 preferences exists: ${json.containsKey('preferences')}');
          if (json.containsKey('preferences')) {
            final prefs = json['preferences'];
            print('  📁 preferences.category: "${prefs['category']}"');
            print(
                '  📁 preferences.importSettings exists: ${prefs.containsKey('importSettings')}');
          }

          // Flatten all preferences for consistent backend structure
          final importSettings = json['preferences']['importSettings'];
          final preferences = json['preferences'];
          json.addAll({
            'importAll': importSettings['importAll'],
            'importSubject': importSettings['importSubject'],
            'importBody': importSettings['importBody'],
            'importConferenceInfo': importSettings['importConferenceInfo'],
            'importOrganizer': importSettings['importOrganizer'],
            'importRecipients': importSettings['importRecipients'],
            'category': preferences['category'],
            'color': preferences['color'],
          });
          // Remove nested preferences object to avoid duplication
          json.remove('preferences');
          return json;
        }).toList();

        // Log each Apple calendar being sent (FLATTENED structure)
        for (int i = 0; i < appleCalendarData.length; i++) {
          final cal = appleCalendarData[i];
          print('📋 [APPLE] Calendar $i AFTER flattening: "${cal['summary']}"');
          print('  🆔 ID: ${cal['id']}');
          print('  🔗 Provider ID: ${cal['providerCalendarId']}');
          print('  📊 Source: ${cal['source']}');
          print('  👤 User: ${cal['user']}');
          print('  📧 Email: ${cal['email']}');
          print(
              '  🔄 Structure: FLATTENED (preferences removed, fields moved to root)');
          print('  ✅ importAll: ${cal['importAll']}');
          print('  📝 importSubject: ${cal['importSubject']}');
          print('  📄 importBody: ${cal['importBody']}');
          print('  📞 importConferenceInfo: ${cal['importConferenceInfo']}');
          print('  👥 importOrganizer: ${cal['importOrganizer']}');
          print('  📮 importRecipients: ${cal['importRecipients']}');
          print('  🏷️ category: "${cal['category']}"');
          print('  🎨 color: "${cal['color']}"');
          print(
              '  ❌ preferences: ${cal.containsKey('preferences') ? 'EXISTS (ERROR!)' : 'REMOVED (correct)'}');
          print('  ─────────────────────────────────');
        }

        await appleManager.saveSelectedCalendars(
          email: email,
          selectedCalendars: appleCalendarData,
        );
      } else {}

      // Update sync token after changes (only for Google for now)
      if (googleCalendars.isNotEmpty) {
        final syncResult = await syncCalendarChanges(userId, email);
        _currentSyncToken = syncResult.syncToken;
      }

      return CalendarSaveResult.success();
    } catch (e) {
      return CalendarSaveResult.error(e.toString());
    }
  }

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
    } on GoogleCalendarException catch (e) {
      if (e.statusCode == 410 || e.toString().contains('410')) {
        // Sync token expired, fall back to full sync
        return await _performInitialSync(userId, email);
      }
      // Propagate auth errors
      return CalendarSyncResult.error(
        e.toString(),
        statusCode: e.statusCode,
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
  final int? statusCode;

  CalendarSyncResult._({
    this.calendars = const [],
    this.changes,
    this.deletedIds,
    this.syncToken,
    this.hasMoreChanges = false,
    this.error,
    this.statusCode,
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

  factory CalendarSyncResult.error(String error, {int? statusCode}) =>
      CalendarSyncResult._(error: error, statusCode: statusCode);

  bool get isSuccess => error == null;
  bool get isDelta => changes != null;
  bool get isAuthError => statusCode == 401 || statusCode == 403;
}

class CalendarSaveResult {
  final bool success;
  final String? error;

  CalendarSaveResult._({this.success = false, this.error});

  factory CalendarSaveResult.success() => CalendarSaveResult._(success: true);
  factory CalendarSaveResult.error(String error) =>
      CalendarSaveResult._(error: error);
}
