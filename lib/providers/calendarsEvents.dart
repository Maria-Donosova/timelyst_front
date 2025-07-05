import 'package:flutter/material.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';

import './../services/calendarsEventsService.dart';
import './../services/authService.dart';

class EventCalendarAssociationProvider with ChangeNotifier {
  final CalendarProvider _calendarProvider;
  final AuthService _authService;
  Map<String, List<String>> _associations = {}; // eventId -> calendarIds
  bool _isSyncing = false;

  EventCalendarAssociationProvider(this._calendarProvider, this._authService);

  // Fetch from CalendarsEventsService (call this on app startup)
  Future<void> loadAssociations() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('Auth token is required');
      final data =
          await CalendarsEventsService.fetchEventCalendarAssociations(token);
      _associations = data;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // UI-facing methods
  List<Calendar> getAssociatedCalendars(String eventId) {
    return _associations[eventId]
            ?.map((id) => _calendarProvider.getCalendarById(id))
            .whereType<Calendar>()
            .toList() ??
        [];
  }

  Future<void> updateAssociations(
      String eventId, List<String> calendarIds) async {
    _isSyncing = true;
    notifyListeners();

    try {
      // Optimistic UI update
      _associations[eventId] = calendarIds;

      // Sync with CalendarsEventsService
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('Auth token is required');
      await CalendarsEventsService.updateEventCalendarAssociations(
          token, eventId, calendarIds);
    } catch (e) {
      // Revert on error
      _associations.remove(eventId);
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
