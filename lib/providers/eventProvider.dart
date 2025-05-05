import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/events.dart';
import 'package:timelyst_flutter/models/customApp.dart';

class EventProvider with ChangeNotifier {
  List<CustomAppointment> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CustomAppointment> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch day events
  Future<void> fetchDayEvents(String userId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dayEvents = await EventService.fetchDayEvents(userId, authToken);
      // Merge with existing events, replacing any duplicates
      _updateEvents(dayEvents);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch day events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch time events
  Future<void> fetchTimeEvents(String userId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final timeEvents = await EventService.fetchTimeEvents(userId, authToken);
      // Merge with existing events, replacing any duplicates
      _updateEvents(timeEvents);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch time events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all events (both day and time events)
  Future<void> fetchAllEvents(String userId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear existing events before fetching all
      _events = [];

      // Fetch both types of events
      final dayEvents = await EventService.fetchDayEvents(userId, authToken);
      final timeEvents = await EventService.fetchTimeEvents(userId, authToken);

      // Combine all events
      _events = [...dayEvents, ...timeEvents];

      // Debug print to verify events are loaded
      print(
          'Fetched ${_events.length} total events (${dayEvents.length} day events, ${timeEvents.length} time events in eventProvider)');

      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a single event by ID
  Future<CustomAppointment?> fetchEvent(String id, String authToken,
      {bool isAllDay = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      CustomAppointment event;
      if (isAllDay) {
        // This is a day event
        event = await EventService.fetchTimeEvent(id, authToken);
      } else {
        // This is a time event
        event = await EventService.fetchTimeEvent(id, authToken);
      }

      // Update the event in the local list if it exists
      _updateSingleEvent(event);
      _errorMessage = '';
      return event;
    } catch (e) {
      _errorMessage = 'Failed to fetch event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a method to add a CustomAppointment directly
  void addSingleEvent(CustomAppointment event) {
    _updateSingleEvent(event);
    notifyListeners();
  }

  // Create a new day event
  Future<CustomAppointment?> createDayEvent(
      Map<String, dynamic> dayEventInput, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newEvent =
          await EventService.createDayEvent(dayEventInput, authToken);
      _events.add(newEvent);
      _errorMessage = '';
      notifyListeners();
      return newEvent;
    } catch (e) {
      _errorMessage = 'Failed to create day event: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new time event
  Future<CustomAppointment?> createTimeEvent(
      Map<String, dynamic> timeEventInput, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newEvent =
          await EventService.createTimeEvent(timeEventInput, authToken);
      _events.add(newEvent);
      _errorMessage = '';
      return newEvent;
    } catch (e) {
      _errorMessage = 'Failed to create time event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a day event
  Future<CustomAppointment?> updateDayEvent(
      String id, Map<String, dynamic> dayEventInput, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedEvent =
          await EventService.updateDayEvent(id, dayEventInput, authToken);
      _updateSingleEvent(updatedEvent);
      _errorMessage = '';
      return updatedEvent;
    } catch (e) {
      _errorMessage = 'Failed to update day event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a time event
  Future<CustomAppointment?> updateTimeEvent(
      String id, Map<String, dynamic> timeEventInput, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedEvent =
          await EventService.updateTimeEvent(id, timeEventInput, authToken);
      _updateSingleEvent(updatedEvent);
      _errorMessage = '';
      return updatedEvent;
    } catch (e) {
      _errorMessage = 'Failed to update time event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a day event
  Future<bool> deleteDayEvent(String id, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await EventService.deleteDayEvent(id, authToken);
      if (success) {
        _events.removeWhere((event) => event.id == id);
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete day event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a time event
  Future<bool> deleteTimeEvent(String id, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await EventService.deleteTimeEvent(id, authToken);
      if (success) {
        _events.removeWhere((event) => event.id == id);
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete time event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to update the events list with new events
  void _updateEvents(List<CustomAppointment> newEvents) {
    // Remove any events that are being replaced
    final newEventIds = newEvents.map((e) => e.id).toSet();
    _events.removeWhere((event) => newEventIds.contains(event.id));

    // Add the new events
    _events.addAll(newEvents);
  }

  // Helper method to update a single event in the list
  void _updateSingleEvent(CustomAppointment updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index >= 0) {
      _events[index] = updatedEvent;
    } else {
      _events.add(updatedEvent);
    }
  }

  // Add a single event to the list
  void addEvent(CustomAppointment event) {
    _events.add(event);
    notifyListeners();
  }
}
