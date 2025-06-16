import 'package:flutter/material.dart';
import './../data/calendars.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import './../services/authService.dart';

class CalendarProvider with ChangeNotifier {
  List<Calendar> _calendars = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _totalCount;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _pageSize = 20;

  final AuthService authService;

  CalendarProvider({required this.authService});

  List<Calendar> get calendars => _calendars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get totalCount => _totalCount;
  bool get hasMore => _hasMore;

  Future<void> loadInitialCalendars() async {
    _resetState();
    await _fetchCalendars();
  }

  Future<void> loadMoreCalendars() async {
    if (!_hasMore || _isLoading) return;
    _currentOffset += _pageSize;
    await _fetchCalendars();
  }

  Future<void> refreshCalendars() async {
    _resetState();
    await _fetchCalendars();
  }

  void _resetState() {
    _calendars = [];
    _currentOffset = 0;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _fetchCalendars() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final result = await CalendarsService.fetchUserCalendars(
        authToken: authToken,
        limit: _pageSize,
        offset: _currentOffset,
      );

      _calendars.addAll(result.calendars);
      _totalCount = result.totalCount;
      _hasMore = result.hasMore;
      _errorMessage = null;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      if (e.statusCode == 401) {
        // Handle unauthorized error (e.g., trigger logout)
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch calendars: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Calendar?> fetchCalendar({
    required String calendarId,
    bool withEvents = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final calendar = await CalendarsService.fetchCalendar(
        calendarId: calendarId,
        authToken: authToken,
        withEvents: withEvents,
      );

      _updateSingleCalendar(calendar);
      _errorMessage = null;
      return calendar;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to fetch calendar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Calendar?> createCalendar(CalendarInput input) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final newCalendar = await CalendarsService.createCalendar(
        authToken: authToken,
        input: input,
      );

      _calendars.insert(0, Calendar.fromJson(newCalendar.toJson()));
      _errorMessage = null;
      return newCalendar;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to create calendar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Calendar?> updateCalendar({
    required String calendarId,
    required CalendarInput input,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final updatedCalendar = await CalendarsService.updateCalendar(
        calendarId: calendarId,
        authToken: authToken,
        input: input,
      );

      _updateSingleCalendar(updatedCalendar);
      _errorMessage = null;
      return updatedCalendar;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to update calendar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCalendar(String calendarId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final success = await CalendarsService.deleteCalendar(
        calendarId: calendarId,
        authToken: authToken,
      );

      if (success) {
        _calendars.removeWhere((calendar) => calendar.id == calendarId);
        _errorMessage = null;
      }
      return success;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete calendar: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Calendar>?> deleteMultipleCalendars(
      List<String> calendarIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authToken = await authService.getAuthToken();
      if (authToken == null) {
        throw CalendarServiceException('User not authenticated');
      }

      final deletedCalendars = await CalendarsService.deleteCalendars(
        calendarIds: calendarIds,
        authToken: authToken,
      );

      if (deletedCalendars.isNotEmpty) {
        _calendars.removeWhere((calendar) => calendarIds.contains(calendar.id));
        _errorMessage = null;
      }
      return deletedCalendars;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to delete calendars: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateSingleCalendar(Calendar updatedCalendar) {
    final index = _calendars.indexWhere((c) => c.id == updatedCalendar.id);
    if (index >= 0) {
      _calendars[index] = updatedCalendar;
    } else {
      _calendars.add(updatedCalendar);
    }
  }

  Calendar? getCalendarById(String calendarId) {
    try {
      return _calendars.firstWhere((calendar) => calendar.id == calendarId);
    } catch (e) {
      return null;
    }
  }

  List<Calendar> getSelectedCalendars() {
    return _calendars.where((calendar) => calendar.isSelected).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
// import 'package:timelyst_flutter/data/calendars.dart';
// import 'package:timelyst_flutter/models/calendars.dart';

// import '../services/authService.dart'; // Import AuthService

// class CalendarProvider with ChangeNotifier {
//   List<Calendar> _calendars = [];
//   bool _isLoading = false;
//   String _errorMessage = '';

//   final AuthService authService;

//   CalendarProvider({required this.authService});
//   List<Calendar> get calendars => _calendars;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;

//   Future<void> fetchCalendars(String userId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       String? authToken = await authService.getAuthToken();
//       if (authToken == null) {
//         throw Exception('User not authenticated');
//       }
//       // CalendarsService.fetchUserCalendars now takes the token directly
//       _calendars = await CalendarsService.fetchUserCalendars(userId, authToken);
//       _errorMessage = '';
//     } catch (e) {
//       _errorMessage = 'Failed to fetch calendars: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Fetch a single calendar by ID
//   Future<Calendar?> fetchCalendar(String calendarId, String authToken) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final calendar =
//           await CalendarsService.fetchCalendar(calendarId, authToken);
//       // Update the calendar in the local list if it exists
//       _updateSingleCalendar(calendar);
//       _errorMessage = '';
//       return calendar;
//     } catch (e) {
//       _errorMessage = 'Failed to fetch calendar: $e';
//       return null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Create a new calendar
//   Future<Calendar?> createCalendar(Calendar calendar, String authToken) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final newCalendar =
//           await CalendarsService.createCalendar(authToken, calendar);
//       _calendars.add(newCalendar);
//       _errorMessage = '';
//       return newCalendar;
//     } catch (e) {
//       _errorMessage = 'Failed to create calendar: $e';
//       return null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Update an existing calendar
//   Future<Calendar?> updateCalendar(
//       String calendarId, Calendar updatedCalendar, String authToken) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final calendar = await CalendarsService.updateCalendar(
//           calendarId, authToken, updatedCalendar);
//       _updateSingleCalendar(calendar);
//       _errorMessage = '';
//       return calendar;
//     } catch (e) {
//       _errorMessage = 'Failed to update calendar: $e';
//       return null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Delete a calendar
//   Future<bool> deleteCalendar(String calendarId, String authToken) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final success =
//           await CalendarsService.deleteCalendar(calendarId, authToken);
//       if (success) {
//         _calendars.removeWhere((calendar) => calendar.id == calendarId);
//         _errorMessage = '';
//       }
//       return success;
//     } catch (e) {
//       _errorMessage = 'Failed to delete calendar: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Helper method to update a single calendar in the list
//   void _updateSingleCalendar(Calendar updatedCalendar) {
//     final index =
//         _calendars.indexWhere((calendar) => calendar.id == updatedCalendar.id);
//     if (index >= 0) {
//       _calendars[index] = updatedCalendar;
//     } else {
//       _calendars.add(updatedCalendar);
//     }
//   }
// }
