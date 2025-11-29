import 'package:timelyst_flutter/models/calendars.dart';
import './googleCalendarService.dart';
import '../microsoftIntegration/microsoftCalendarService.dart';
import '../appleIntegration/appleCalendarService.dart';

class CalendarSyncManager {
  final GoogleCalendarService _googleCalendarService;
  final MicrosoftCalendarService _microsoftCalendarService;
  final AppleCalendarService _appleCalendarService;

  CalendarSyncManager({
    GoogleCalendarService? googleCalendarService,
    MicrosoftCalendarService? microsoftCalendarService,
    AppleCalendarService? appleCalendarService,
  })  : _googleCalendarService = googleCalendarService ?? GoogleCalendarService(),
        _microsoftCalendarService = microsoftCalendarService ?? MicrosoftCalendarService(),
        _appleCalendarService = appleCalendarService ?? AppleCalendarService();

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
          .where((cal) => cal.source == CalendarSource.GOOGLE)
          .toList();
      final microsoftCalendars = selectedCalendars
          .where((cal) => cal.source == CalendarSource.MICROSOFT)
          .toList();
      final appleCalendars = selectedCalendars
          .where((cal) => cal.source == CalendarSource.APPLE)
          .toList();

      print('  📱 Google calendars: ${googleCalendars.length}');
      print('  📱 Microsoft calendars: ${microsoftCalendars.length}');
      print('  📱 Apple calendars: ${appleCalendars.length}');

      // Save Google calendars if any
      if (googleCalendars.isNotEmpty) {
        await _googleCalendarService.syncGoogleCalendars(
          userId: userId,
          email: email,
          calendars: googleCalendars,
        );
      }

      // Save Microsoft calendars if any
      if (microsoftCalendars.isNotEmpty) {
        await _microsoftCalendarService.syncMicrosoftCalendars(
          userId: userId,
          email: email,
          calendars: microsoftCalendars,
        );
      }

      // Save Apple calendars if any
      if (appleCalendars.isNotEmpty) {
        await _appleCalendarService.syncAppleCalendars(
          userId: userId,
          email: email,
          calendars: appleCalendars,
        );
      }

      return CalendarSaveResult.success();
    } catch (e) {
      return CalendarSaveResult.error(e.toString());
    }
  }
}

class CalendarSaveResult {
  final bool success;
  final String? error;

  CalendarSaveResult._({this.success = false, this.error});

  factory CalendarSaveResult.success() => CalendarSaveResult._(success: true);
  factory CalendarSaveResult.error(String error) =>
      CalendarSaveResult._(error: error);
}
