import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/calendars.dart';
import 'package:timelyst_flutter/models/calendars.dart';

import '../services/authService.dart'; // Import AuthService

class CalendarProvider with ChangeNotifier {
  List<Calendar> _calendars = [];
  bool _isLoading = false;
  String _errorMessage = '';

  final AuthService authService;

  CalendarProvider({required this.authService});
  List<Calendar> get calendars => _calendars;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCalendars(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw Exception('User not authenticated');
      }
      // CalendarsService.fetchUserCalendars now takes the token directly
      _calendars = await CalendarsService.fetchUserCalendars(userId, authToken);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch calendars: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a single calendar by ID
  Future<Calendar?> fetchCalendar(String calendarId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final calendar =
          await CalendarsService.fetchCalendar(calendarId, authToken);
      // Update the calendar in the local list if it exists
      _updateSingleCalendar(calendar);
      _errorMessage = '';
      return calendar;
    } catch (e) {
      _errorMessage = 'Failed to fetch calendar: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new calendar
  Future<Calendar?> createCalendar(Calendar calendar, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newCalendar =
          await CalendarsService.createCalendar(authToken, calendar);
      _calendars.add(newCalendar);
      _errorMessage = '';
      return newCalendar;
    } catch (e) {
      _errorMessage = 'Failed to create calendar: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing calendar
  Future<Calendar?> updateCalendar(
      String calendarId, Calendar updatedCalendar, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final calendar = await CalendarsService.updateCalendar(
          calendarId, authToken, updatedCalendar);
      _updateSingleCalendar(calendar);
      _errorMessage = '';
      return calendar;
    } catch (e) {
      _errorMessage = 'Failed to update calendar: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a calendar
  Future<bool> deleteCalendar(String calendarId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success =
          await CalendarsService.deleteCalendar(calendarId, authToken);
      if (success) {
        _calendars.removeWhere((calendar) => calendar.id == calendarId);
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete calendar: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to update a single calendar in the list
  void _updateSingleCalendar(Calendar updatedCalendar) {
    final index =
        _calendars.indexWhere((calendar) => calendar.id == updatedCalendar.id);
    if (index >= 0) {
      _calendars[index] = updatedCalendar;
    } else {
      _calendars.add(updatedCalendar);
    }
  }
}
