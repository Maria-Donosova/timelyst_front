import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';

import './../data/calendars.dart';
import './../services/authService.dart';

class EventCalendarAssociationProvider with ChangeNotifier {
  final CalendarProvider _calendarProvider;
  final Map<String, List<String>> _associations = {}; // eventId -> calendarIds
  bool _isSyncing = false;

  EventCalendarAssociationProvider(this._calendarProvider);

  // Fetch from DB (call this on app startup)
  Future<void> loadAssociations() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final data = await ApiService.get('/event-calendars');
      _associations =
          Map.from(data); // Assume data is {eventId: [calendarId1, ...]}
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

      // Sync with DB
      await ApiService.post(
          '/event-calendars', {'eventId': eventId, 'calendarIds': calendarIds});
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
