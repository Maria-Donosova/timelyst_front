import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/eventsService.dart';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/models/customApp.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';
import 'package:timelyst_flutter/utils/eventsMapper.dart';
import 'package:timelyst_flutter/utils/logger.dart';

class EventProvider with ChangeNotifier {
  AuthService? _authService;
  List<CustomAppointment> _events = [];
  
  // Store raw TimeEvent objects for TimelystCalendarDataSource
  List<TimeEvent> _timeEvents = [];
  
  // Track previous events for change detection
  List<CustomAppointment> _previousEvents = [];

  bool _isLoading = false;
  bool _isBackgroundRefreshing = false;
  String _errorMessage = '';
  
  // Cache management
  final Map<String, List<CustomAppointment>> _eventCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  
  // Cache metrics
  final CacheMetrics _metrics = CacheMetrics();
  CacheMetrics get metrics => _metrics;
  
  // Occurrence counts for recurring events (master event ID -> count)
  final Map<String, int> _occurrenceCounts = {};
  
  // Store masters for edit/delete operations on expanded occurrences
  Map<String, TimeEvent> _mastersMap = {};
  
  // Last logged hit rate to throttle cache metrics logging
  double _lastLoggedHitRate = -1.0;
  
  // Timeout configurations for different scenarios
  static const Duration _defaultEventTimeout = Duration(seconds: 60); // Longer timeout for CalDAV operations
  static const Duration _parallelEventTimeout = Duration(seconds: 45); // Still reasonable timeout when loading with tasks

  List<CustomAppointment> get events => _events;
  List<TimeEvent> get timeEvents => _timeEvents;
  bool get isLoading => _isLoading;
  bool get isBackgroundRefreshing => _isBackgroundRefreshing;
  String get errorMessage => _errorMessage;
  
  /// Get occurrence count for a master event (for dialog display)
  int getOccurrenceCount(String masterEventId) {
    return _occurrenceCounts[masterEventId] ?? 0;
  }
  
  /// Get masters map for edit/delete operations
  Map<String, TimeEvent> get mastersMap => _mastersMap;
  
  /// Store masters for edit/delete lookup on expanded occurrences
  void setMastersMap(List<TimeEvent> masters) {
    _mastersMap = {for (var m in masters) m.id: m};
    LogService.info('EventProvider', 'Stored ${masters.length} masters for lookup');
  }

  EventProvider({AuthService? authService}) 
    : _authService = authService;

  void setAuth(AuthService authService) {
    _authService = authService;
  }

  /// Generate cache key based on date range
  String _generateCacheKey(DateTime startDate, DateTime endDate) {
    return '${startDate.toIso8601String().substring(0, 10)}_${endDate.toIso8601String().substring(0, 10)}';
  }

  /// Parse cache key back into DateTime range
  _DateRange _parseCacheKey(String key) {
    final parts = key.split('_');
    return _DateRange(
      start: DateTime.parse(parts[0]),
      end: DateTime.parse(parts[1]),
    );
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    final isValid = now.difference(timestamp) < _cacheValidDuration;
    
    if (!isValid) {
      LogService.debug('EventProvider', 'Cache expired for key: $cacheKey');
      _eventCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    }
    
    return isValid;
  }

  /// Store events in cache
  void _cacheEvents(String cacheKey, List<CustomAppointment> events) {
    _evictOldestIfNeeded();
    _eventCache[cacheKey] = events;
    _cacheTimestamps[cacheKey] = DateTime.now();
    LogService.debug('EventProvider', 'Cached ${events.length} events for key: $cacheKey (Total ranges: ${_eventCache.length})');
  }

  /// LRU Eviction: Remove oldest entries if we exceed the limit
  void _evictOldestIfNeeded() {
    const int maxCachedRanges = 10;
    if (_eventCache.length >= maxCachedRanges) {
      // Find the oldest entry based on timestamp
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      
      _eventCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
      LogService.debug('EventProvider', 'LRU Eviction: Removed oldest cache range $oldestKey');
    }
  }

  /// Surgical update: update an event in all cached ranges
  void _updateEventInCache(CustomAppointment updatedEvent) {
    if (!Config.useSmartCache) {
      invalidateCache();
      return;
    }
    int updateCount = 0;
    for (final key in _eventCache.keys) {
      final events = _eventCache[key]!;
      
      // 1. Update the exact event if found
      final index = events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        events[index] = updatedEvent;
        updateCount++;
      } else {
        // If it's not there, maybe it SHOULD be there now if its time changed?
        final range = _parseCacheKey(key);
        if (_eventFallsInRange(updatedEvent, range)) {
          events.add(updatedEvent);
          updateCount++;
        }
      }

      // 2. RECURRENCE SURGERY: If this is a master event update, update its occurrences
      // We assume if developer passes a master event to update, we should sync common properties
      final timeEvent = updatedEvent.timeEventInstance;
      if (timeEvent != null && timeEvent.masterId == null && !timeEvent.isOccurrence) {
        for (int i = 0; i < events.length; i++) {
          final e = events[i];
          final te = e.timeEventInstance;
          if (te != null && te.masterId == updatedEvent.id) {
            // Apply master changes (title, category, etc.) to the occurrence
            events[i] = _applyMasterChangesToOccurrence(e, updatedEvent);
            updateCount++;
          }
        }
      }
    }
    if (updateCount > 0) {
      _metrics.partialUpdates += updateCount;
      LogService.debug('EventProvider', 'Surgically updated event hierarchy ${updatedEvent.id} in cache');
    }
  }

  /// Helper to apply master event changes to an occurrence
  CustomAppointment _applyMasterChangesToOccurrence(CustomAppointment occurrence, CustomAppointment master) {
    return occurrence.copyWith(
      title: master.title,
      catColor: master.catColor,
      location: master.location,
      description: master.description,
      // Note: times are NOT copied as they are occurrence-specific
    );
  }

  /// Surgical update: remove an event from all cached ranges
  void _removeEventFromCache(String eventId) {
    int removeCount = 0;
    for (final key in _eventCache.keys) {
      final events = _eventCache[key]!;
      final initialLength = events.length;
      events.removeWhere((e) => e.id == eventId);
      if (events.length < initialLength) {
        removeCount++;
      }
    }
    if (removeCount > 0) {
      _metrics.partialUpdates += removeCount;
      LogService.debug('EventProvider', 'Surgically removed event $eventId from $removeCount cache ranges');
    }
  }

  /// Surgical update: add an event to relevant cached ranges
  void _addEventToCache(CustomAppointment newEvent) {
    if (!Config.useSmartCache) return;
    int addCount = 0;
    for (final key in _eventCache.keys) {
      final range = _parseCacheKey(key);
      if (_eventFallsInRange(newEvent, range)) {
        final events = _eventCache[key]!;
        if (!events.any((e) => e.id == newEvent.id)) {
          events.add(newEvent);
          addCount++;
        }
      }
    }
    if (addCount > 0) {
      _metrics.partialUpdates += addCount;
      LogService.debug('EventProvider', 'Surgically added event ${newEvent.id} to $addCount cache ranges');
    }
  }

  bool _eventFallsInRange(CustomAppointment event, _DateRange range) {
    return event.startTime.toUtc().isBefore(range.end.toUtc()) && 
           event.endTime.toUtc().isAfter(range.start.toUtc());
  }

  /// Get events from cache
  List<CustomAppointment>? _getCachedEvents(String cacheKey) {
    return _getCachedEventsForRange(_parseCacheKey(cacheKey).start, _parseCacheKey(cacheKey).end);
  }

  /// Get events from cache, supporting overlapping ranges
  List<CustomAppointment>? _getCachedEventsForRange(DateTime start, DateTime end) {
    if (!Config.useSmartCache) return null;
    for (final key in _eventCache.keys) {
      if (!_isCacheValid(key)) continue;
      
      final range = _parseCacheKey(key);
      // If cached range fully contains requested range
      if ((range.start.toUtc().isBefore(start.toUtc()) || range.start.toUtc().isAtSameMomentAs(start.toUtc())) && 
          (range.end.toUtc().isAfter(end.toUtc()) || range.end.toUtc().isAtSameMomentAs(end.toUtc()))) {
        
        _metrics.cacheHits++;
        final allEvents = _eventCache[key]!;
        // Filter events to requested range
        final filtered = allEvents.where((e) => 
          e.startTime.toUtc().isBefore(end.toUtc()) && e.endTime.toUtc().isAfter(start.toUtc())
        ).toList();
        
        LogService.debug('EventProvider', 'Cache hit (overlap) for ${start.toIso8601String().substring(0,10)}: ${filtered.length} events');
        return filtered;
      }
    }
    _metrics.cacheMisses++;
    return null;
  }

  /// Clear all cached events and force fresh fetch on next request
  void invalidateCache() {
    _eventCache.clear();
    _cacheTimestamps.clear();
    _occurrenceCounts.clear();
    _metrics.fullInvalidations++;
    LogService.info('EventProvider', 'Cache invalidated - forcing fresh fetch on next request');
  }

  /// Clear expired cache entries (for cleanup)
  void _clearExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheValidDuration) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _eventCache.remove(key);
      _cacheTimestamps.remove(key);
      LogService.debug('EventProvider', 'Removed expired cache entry: $key');
    }
  }

  // Emergency reset for stuck loading state
  void forceResetLoadingState() {
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch events for day view (current day only)
  Future<void> fetchDayViewEvents({DateTime? date, bool isParallelLoad = false}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return fetchAllEvents(
      startDate: startOfDay,
      endDate: endOfDay,
      viewType: isParallelLoad ? 'parallel' : 'day',
      forceFullRefresh: false, // Don't replace all events, sync instead
    );
  }

  /// Fetch events for week view (current week)
  Future<void> fetchWeekViewEvents({DateTime? weekStart}) async {
    final startOfWeek = weekStart ?? DateTime.now();
    // weekStart is already the start of the visible week from the calendar
    // Just add 7 days to get the end of the week
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    
    return fetchAllEvents(
      startDate: startOfWeek,
      endDate: endOfWeek,
      viewType: 'week',
      forceFullRefresh: false, // Don't replace all events, sync instead
    );
  }

  /// Fetch events for month view (current month)
  Future<void> fetchMonthViewEvents({DateTime? month}) async {
    final targetDate = month ?? DateTime.now();
    final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
    final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 0).add(Duration(days: 1));
    
    return fetchAllEvents(
      startDate: startOfMonth,
      endDate: endOfMonth,
      viewType: 'month',
      forceFullRefresh: false, // Don't replace all events, sync instead
    );
  }

  Future<void> fetchAllEvents({
    bool forceFullRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
    String? viewType,
    Duration? customTimeout,
  }) async {
    if (startDate != null && endDate != null && !forceFullRefresh) {
      final cachedEvents = _getCachedEventsForRange(startDate, endDate);
      if (cachedEvents != null) {
        _events = cachedEvents;
        _timeEvents = cachedEvents
            .map((e) => e.timeEventInstance)
            .whereType<TimeEvent>()
            .toList();
        _previousEvents = List.from(_events);
        notifyListeners();
        
        final cacheKey = _generateCacheKey(startDate, endDate);
        final timestamp = _cacheTimestamps[cacheKey];
        final isStale = timestamp == null || DateTime.now().difference(timestamp) > Duration(minutes: 2);
        
        if (isStale) {
          LogService.debug('EventProvider', 'Cache hit but stale (fetchAllEvents), refreshing in background');
          _refreshAllEventsInBackground(startDate, endDate, viewType, customTimeout);
        } else {
          LogService.debug('EventProvider', 'Fresh cache hit (fetchAllEvents)');
        }
        return;
      }
    }
    
    return _fetchAllEventsFromApi(
      forceFullRefresh: forceFullRefresh,
      startDate: startDate,
      endDate: endDate,
      viewType: viewType,
      customTimeout: customTimeout,
    );
  }

  Future<void> _fetchAllEventsFromApi({
    bool forceFullRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
    String? viewType,
    Duration? customTimeout,
  }) async {
    final startTime = DateTime.now();
    final viewTypeStr = viewType ?? 'default';
    LogService.debug('EventProvider', 'Starting _fetchAllEventsFromApi at $startTime for view: $viewTypeStr');
    
    // Prevent concurrent fetches (but allow forced refresh)
    if (_isLoading && !forceFullRefresh) {
      LogService.warn('EventProvider', 'Already loading, skipping fetch');
      return;
    }
    
    if (_authService == null) {
      LogService.warn('EventProvider', 'AuthService is null in EventProvider');
      _isLoading = false;
      notifyListeners();
      return;
    }
    final authToken = await _authService!.getAuthToken();
    final userId = await _authService!.getUserId();
    if (authToken == null || userId == null) {
      _errorMessage = 'Authentication required. Please log in again.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_events.isEmpty || forceFullRefresh) {
        _events = [];
      }
      
      final timeout = customTimeout ?? 
                     (viewType == 'parallel' ? _parallelEventTimeout : _defaultEventTimeout);
      
      final fetchedEvents = await EventService.fetchEvents(
        userId, 
        authToken, 
        startDate: startDate, 
        endDate: endDate
      ).timeout(
        timeout,
        onTimeout: () {
          LogService.error('EventProvider', 'API calls timed out');
          throw TimeoutException('Event fetching timed out', timeout);
        }
      );
      
      if (startDate != null && endDate != null) {
        _syncEventsForDateRange(fetchedEvents, startDate, endDate);
        _timeEvents = _events.map((e) => e.timeEventInstance).whereType<TimeEvent>().toList();
      } else {
        _syncEventsIncremental(fetchedEvents);
        _timeEvents = _events.map((e) => e.timeEventInstance).whereType<TimeEvent>().toList();
      }

      _previousEvents = List.from(_events);

      if (startDate != null && endDate != null) {
        final cacheKey = _generateCacheKey(startDate, endDate);
        _cacheEvents(cacheKey, fetchedEvents);
      }

      _errorMessage = '';
      logCacheMetrics();
    } catch (e) {
      _errorMessage = 'Failed to fetch events: $e';
      LogService.error('EventProvider', _errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _refreshAllEventsInBackground(DateTime start, DateTime end, String? viewType, Duration? customTimeout) async {
    try {
      _metrics.backgroundRefreshes++;
      final authToken = await _authService?.getAuthToken();
      final userId = await _authService?.getUserId();
      if (authToken == null || userId == null) return;

      final fetchedEvents = await EventService.fetchEvents(
        userId, authToken, startDate: start, endDate: end
      );
      
      _syncEventsForDateRange(fetchedEvents, start, end);
      _timeEvents = _events.map((e) => e.timeEventInstance).whereType<TimeEvent>().toList();
      _previousEvents = List.from(_events);
      
      final cacheKey = _generateCacheKey(start, end);
      _cacheEvents(cacheKey, fetchedEvents);
      
      notifyListeners();
      LogService.info('EventProvider', 'Background refresh (fetchAllEvents) completed');
    } catch (e) {
      LogService.warn('EventProvider', 'Background refresh failed: $e');
    }
  }

  /// Fetch calendar view with master events, exceptions, and occurrence counts
  /// This is the new method that uses the structured calendar view API
  Future<void> fetchCalendarView({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    final start = startDate ?? DateTime.now().subtract(Duration(days: 90));
    final end = endDate ?? DateTime.now().add(Duration(days: 120));
    
    if (!forceRefresh) {
      final cachedEvents = _getCachedEventsForRange(start, end);
      if (cachedEvents != null) {
        _events = cachedEvents;
        _timeEvents = cachedEvents
            .map((e) => e.timeEventInstance)
            .whereType<TimeEvent>()
            .toList();
        _previousEvents = List.from(_events);
        notifyListeners();
        
        final cacheKey = _generateCacheKey(start, end);
        final timestamp = _cacheTimestamps[cacheKey];
        final isStale = timestamp == null || DateTime.now().difference(timestamp) > Duration(minutes: 2);
        
        if (isStale) {
          LogService.debug('EventProvider', 'Cache hit but stale (fetchCalendarView), refreshing in background');
          _refreshCalendarViewInBackground(start, end);
        } else {
          LogService.debug('EventProvider', 'Fresh cache hit (fetchCalendarView)');
        }
        return;
      }
    }
    
    return _fetchCalendarViewFromApi(start, end);
  }

  Future<void> _fetchCalendarViewFromApi(DateTime start, DateTime end) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await EventService.getCalendarView(
        authToken: authToken,
        start: start,
        end: end,
        expand: true,
      );
      
      _processCalendarViewResponse(response, start, end);
      _errorMessage = '';
      logCacheMetrics();
    } catch (e) {
      _errorMessage = 'Failed to fetch calendar view: $e';
      LogService.error('EventProvider', _errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _refreshCalendarViewInBackground(DateTime start, DateTime end) async {
    try {
      _metrics.backgroundRefreshes++;
      _isBackgroundRefreshing = true;
      notifyListeners();
      
      final authToken = await _authService?.getAuthToken();
      if (authToken == null) return;

      final response = await EventService.getCalendarView(
        authToken: authToken,
        start: start,
        end: end,
        expand: true,
      );
      
      _processCalendarViewResponse(response, start, end);
      notifyListeners();
      LogService.info('EventProvider', 'Background refresh (fetchCalendarView) completed');
    } catch (e) {
      LogService.warn('EventProvider', 'Background refresh failed: $e');
    } finally {
      _isBackgroundRefreshing = false;
      notifyListeners();
    }
  }

  void _processCalendarViewResponse(Map<String, dynamic> response, DateTime start, DateTime end) {
    final events = (response['events'] as List<dynamic>?)
        ?.map((e) => TimeEvent.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
        
    final masters = (response['masters'] as List<dynamic>?)
        ?.map((e) => TimeEvent.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
        
    final occurrenceCounts = response['occurrenceCounts'] != null
        ? Map<String, int>.from(response['occurrenceCounts'] as Map)
        : <String, int>{};
    
    _occurrenceCounts.clear();
    _occurrenceCounts.addAll(occurrenceCounts);
    setMastersMap(masters);
    
    _timeEvents = events;
    final appointments = events
        .map((event) {
          try {
            return EventMapper.mapTimeEventToCustomAppointment(event);
          } catch (e) {
            return null;
          }
        })
        .where((event) => event != null)
        .cast<CustomAppointment>()
        .toList();
    
    _syncEventsForDateRange(appointments, start, end);
    _previousEvents = List.from(_events);
    
    final cacheKey = _generateCacheKey(start, end);
    _cacheEvents(cacheKey, appointments);
  }

  void addSingleEvent(CustomAppointment event) {
    _updateSingleEvent(event);
    notifyListeners();
  }

  Future<CustomAppointment?> createEvent(
      Map<String, dynamic> eventInput) async {
    LogService.info('EventProvider', 'createEvent called');
    LogService.verbose('EventProvider', 'Payload: $eventInput');
    if (_authService == null) {
      LogService.warn('EventProvider', 'createEvent failure: authService is null');
      return null;
    }
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) {
      LogService.warn('EventProvider', 'createEvent failure: authToken is null');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      LogService.info('EventProvider', 'Calling EventService.createEvent...');
      final newEvent =
          await EventService.createEvent(eventInput, authToken);
      _events.add(newEvent);
      _errorMessage = '';
      _addEventToCache(newEvent);
      notifyListeners();
      return newEvent;
    } catch (e) {
      _errorMessage = 'Failed to create event: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomAppointment?> updateEvent(
      String id, Map<String, dynamic> eventInput) async {
    LogService.info('EventProvider', 'updateEvent called for ID: $id');
    if (_authService == null) {
      LogService.warn('EventProvider', 'updateEvent failure: no authService');
      return null;
    }
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) {
      LogService.warn('EventProvider', 'updateEvent failure: no authToken');
      return null;
    }

    if (id.isEmpty) {
      LogService.warn('EventProvider', 'updateEvent failure: empty ID');
      _errorMessage = 'Event ID cannot be empty';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      LogService.info('EventProvider', 'Calling EventService.updateEvent...');
      final updatedEvent =
          await EventService.updateEvent(id, eventInput, authToken);
      LogService.info('EventProvider', 'API call succeeded');
      _updateSingleEvent(updatedEvent);
      _errorMessage = '';
      _updateEventInCache(updatedEvent);
      return updatedEvent;
    } catch (e) {
      LogService.error('EventProvider', 'Error in updateEvent', e);
      _errorMessage = 'Failed to update event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEvent(String id, {String? deleteScope}) async {
    if (_authService == null) return false;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      LogService.info('EventProvider', 'Deleting event $id with scope: ${deleteScope ?? "default"}');
      
      await EventService.deleteEvent(id, authToken, deleteScope: deleteScope);
      
      // Remove the event from local state
      _events.removeWhere((event) => event.id == id);
      _removeEventFromCache(id);
      
      // If deleting a series, invalidate cache to force refresh
      // This ensures all occurrences are removed from the UI
      if (deleteScope == 'series') {
        LogService.info('EventProvider', 'Series deleted, invalidating cache');
        invalidateCache();
      }
      
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete event: $e';
      LogService.error('EventProvider', 'Delete failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateEvents(List<CustomAppointment> newEvents) {
    final newEventIds = newEvents.map((e) => e.id).toSet();
    _events.removeWhere((event) => newEventIds.contains(event.id));
    _events.addAll(newEvents);
  }

  /// Syncs events for a specific date range without affecting events outside that range
  bool _syncEventsForDateRange(List<CustomAppointment> fetchedEvents, DateTime startDate, DateTime endDate) {
    final syncStartTime = DateTime.now();
    
    // Create a buffer to prevent boundary issues - extend range by 1 day on each side
    final bufferStart = startDate.subtract(Duration(days: 1));
    final bufferEnd = endDate.add(Duration(days: 1));
    
    // Only remove events that are completely outside the buffered range AND being replaced
    final fetchedEventIds = fetchedEvents.map((e) => e.id).toSet();
    int removedCount = 0;

    final eventsToKeep = _events.where((event) {
      // Keep events outside the core range (not the buffer)
      final outsideCoreRange = event.startTime.toUtc().isBefore(startDate.toUtc()) || 
                              event.startTime.toUtc().isAfter(endDate.toUtc()) ||
                              event.startTime.toUtc().isAtSameMomentAs(endDate.toUtc());
      
      // For all-day events, be more lenient with date boundaries
      final isAllDayWithinBuffer = event.isAllDay && 
                                  event.startTime.toUtc().isAfter(bufferStart.toUtc()) && 
                                  event.startTime.toUtc().isBefore(bufferEnd.toUtc());
      
      final shouldKeep = outsideCoreRange || isAllDayWithinBuffer;
      
      if (!shouldKeep) {
        removedCount++;
        LogService.verbose('EventProvider', 'Removing/replacing: "${event.title}" (${event.startTime.toIso8601String().substring(0, 10)})');
      }
      
      return shouldKeep;
    }).toList();
    
    // Remove exact duplicates by ID (keep the fetched version)
    final finalEvents = <CustomAppointment>[];
    final seenIds = <String>{};
    
    // Add fetched events first (priority)
    for (final event in fetchedEvents) {
      if (!seenIds.contains(event.id)) {
        finalEvents.add(event);
        seenIds.add(event.id);
      }
    }
    
    // Add kept events (if not already seen)
    for (final event in eventsToKeep) {
      if (!seenIds.contains(event.id)) {
        finalEvents.add(event);
        seenIds.add(event.id);
      }
    }
    
    final oldCount = _events.length;
    _events = finalEvents;
    
    final syncEndTime = DateTime.now();
    final syncDuration = syncEndTime.difference(syncStartTime);
    final newCount = _events.length;
    
    LogService.info('EventProvider', 'Synced $newCount events ($removedCount removed, ${fetchedEvents.length} added) in ${syncDuration.inMilliseconds}ms');
    
    return removedCount > 0 || fetchedEvents.isNotEmpty;
  }

  /// Handle calendar visibility toggle surgically
  void onCalendarVisibilityChanged(String calendarId, bool isVisible) {
    if (!isVisible) {
      // Remove events from this calendar from current state and cache
      _events.removeWhere((e) => e.calendarId == calendarId);
      _timeEvents.removeWhere((e) => e.calendarIds.contains(calendarId));
      
      for (final key in _eventCache.keys) {
        _eventCache[key]!.removeWhere((e) => e.calendarId == calendarId);
      }
      
      if (LogService.currentLevel.index >= LogLevel.debug.index) {
        LogService.debug('EventProvider', 'Locally removed events for calendar $calendarId');
      }
      _metrics.partialUpdates++;
      notifyListeners();
    } else {
      // If toggled ON, we need to fetch. 
      // For now, let's force a refresh of the current view to get the events.
      if (LogService.currentLevel.index >= LogLevel.debug.index) {
        LogService.debug('EventProvider', 'Calendar $calendarId toggled ON, refreshing view');
      }
      // Use short delay to allow provider state to propagate if needed
      Future.delayed(const Duration(milliseconds: 100), () {
        fetchCalendarView(forceRefresh: true);
      });
    }
  }

  /// Log current cache metrics
  void logCacheMetrics() {
    final currentHitRate = _metrics.hitRate;
    if (_lastLoggedHitRate == -1.0 || (currentHitRate - _lastLoggedHitRate).abs() > 0.10) {
      _lastLoggedHitRate = currentHitRate;
      LogService.debug('EventProvider', 'Cache Metrics: ${_metrics.toString()}');
    }
  }

  /// Performs incremental synchronization of events
  /// Only adds new events, updates changed events, and removes deleted events
  bool _syncEventsIncremental(List<CustomAppointment> fetchedEvents) {
    final syncStartTime = DateTime.now();
    LogService.verbose('EventProvider', 'Starting incremental sync of ${fetchedEvents.length} fetched events with ${_events.length} existing events');
    
    try {
      final fetchedEventMap = Map<String, CustomAppointment>.fromIterable(
        fetchedEvents,
        key: (e) => e.id,
        value: (e) => e,
      );
      
      final currentEventMap = Map<String, CustomAppointment>.fromIterable(
        _events,
        key: (e) => e.id,
        value: (e) => e,
      );

      final fetchedIds = fetchedEventMap.keys.toSet();
      final currentIds = currentEventMap.keys.toSet();

      // Find new events (in fetched but not in current)
      final newEventIds = fetchedIds.difference(currentIds);
      print('🔄 [EventProvider] Found ${newEventIds.length} new events');
      
      final newEvents = newEventIds.map((id) {
        final event = fetchedEventMap[id];
        if (event == null) {
          LogService.error('EventProvider', 'Event with ID $id is null in fetchedEventMap!');
        }
        return event!;
      }).toList();

    // Find removed events (in current but not in fetched)
    final removedEventIds = currentIds.difference(fetchedIds);

    // Find potentially updated events (in both)
    final commonEventIds = fetchedIds.intersection(currentIds);
    final updatedEvents = <CustomAppointment>[];
    
    for (final id in commonEventIds) {
      final currentEvent = currentEventMap[id]!;
      final fetchedEvent = fetchedEventMap[id]!;
      
      // Simple comparison - in a real app you might want to compare specific fields
      // or use a more sophisticated change detection mechanism
      if (_hasEventChanged(currentEvent, fetchedEvent)) {
        updatedEvents.add(fetchedEvent);
      }
    }

    // Apply changes
    int changes = 0;
    
    if (newEvents.isNotEmpty) {
      for (final event in newEvents) {
        _events.add(event);
        changes++;
      }
    }

    if (removedEventIds.isNotEmpty) {
      for (final id in removedEventIds) {
        _events.removeWhere((event) => event.id == id);
        changes++;
      }
    }

    if (updatedEvents.isNotEmpty) {
      for (final updatedEvent in updatedEvents) {
        final index = _events.indexWhere((event) => event.id == updatedEvent.id);
        if (index >= 0) {
          _events[index] = updatedEvent;
          changes++;
        }
      }
    }

    final syncEndTime = DateTime.now();
    final syncDuration = syncEndTime.difference(syncStartTime);
    LogService.info('EventProvider', 'Incremental sync completed: $changes changes made in ${syncDuration.inMilliseconds}ms');
    
    return changes > 0;
    } catch (e, stackTrace) {
      LogService.error('EventProvider', 'Error in _syncEventsIncremental', e, stackTrace);
      return false;
    }
  }

  /// Simple event change detection
  /// In a real app, you might want to compare timestamps, content hashes, or specific fields
  bool _hasEventChanged(CustomAppointment current, CustomAppointment fetched) {
    return current.title != fetched.title ||
           current.startTime != fetched.startTime ||
           current.endTime != fetched.endTime ||
           current.recurrenceRule != fetched.recurrenceRule ||
           current.description != fetched.description ||
           current.location != fetched.location ||
           current.isAllDay != fetched.isAllDay;
  }

  void _updateSingleEvent(CustomAppointment updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index >= 0) {
      _events[index] = updatedEvent;
    } else {
      _events.add(updatedEvent);
    }
  }

  void addEvent(CustomAppointment event) {
    _events.add(event);
    notifyListeners();
  }

  /// Updates an existing event in the local state (for immediate UI response)
  /// This method is used for drag-and-drop operations and other local updates
  void updateEventLocal(CustomAppointment oldEvent, CustomAppointment newEvent) {
    final index = _events.indexWhere((event) => event.id == oldEvent.id);
    if (index >= 0) {
      _events[index] = newEvent;
      _updateEventInCache(newEvent);
      notifyListeners();
    }
  }

  // ============ OPTIMISTIC UPDATE WITH ROLLBACK ============

  /// Clones current events list for potential rollback
  List<CustomAppointment> _cloneEvents() => List<CustomAppointment>.from(_events);

  /// Restores events from a snapshot (for rollback on backend failure)
  void restoreEventsSnapshot(List<CustomAppointment> snapshot) {
    _events = snapshot;
    LogService.info('EventProvider', 'Rolled back to previous state');
    notifyListeners();
  }

  /// Performs an optimistic update and returns a rollback function
  /// 
  /// Usage:
  /// ```dart
  /// final rollback = eventProvider.optimisticUpdateEvent(eventId, updatedEvent);
  /// try {
  ///   await backendCall();
  /// } catch (e) {
  ///   rollback(); // Reverts to previous state
  /// }
  /// ```
  Function optimisticUpdateEvent(String eventId, CustomAppointment updated) {
    final snapshot = _cloneEvents();
    final timeEventsSnapshot = List<TimeEvent>.from(_timeEvents);
    
    final index = _events.indexWhere((e) => e.id == eventId);
    
    if (index >= 0) {
      _events[index] = updated;
      _updateEventInCache(updated);
      
      // Also update _timeEvents to keep them in sync
      final timeEventIndex = _timeEvents.indexWhere((e) => e.id == eventId);
      if (timeEventIndex >= 0) {
        final oldTimeEvent = _timeEvents[timeEventIndex];
        // Update the TimeEvent with new times from the updated CustomAppointment
        _timeEvents[timeEventIndex] = TimeEvent(
          id: oldTimeEvent.id,
          userId: oldTimeEvent.userId,
          calendarIds: oldTimeEvent.calendarIds,
          provider: oldTimeEvent.provider,
          providerEventId: oldTimeEvent.providerEventId,
          providerCalendarId: oldTimeEvent.providerCalendarId,
          etag: oldTimeEvent.etag,
          eventTitle: updated.title,
          start: updated.startTime.toUtc(),
          end: updated.endTime.toUtc(),
          startTimeZone: oldTimeEvent.startTimeZone,
          endTimeZone: oldTimeEvent.endTimeZone,
          recurrenceRule: oldTimeEvent.recurrenceRule,
          exDates: oldTimeEvent.exDates,
          isAllDay: updated.isAllDay,
          category: oldTimeEvent.category,
          location: updated.location,
          description: updated.description,
          status: oldTimeEvent.status,
          sequence: oldTimeEvent.sequence,
          busyStatus: oldTimeEvent.busyStatus,
          visibility: oldTimeEvent.visibility,
          attendees: oldTimeEvent.attendees,
          organizerEmail: oldTimeEvent.organizerEmail,
          organizerName: oldTimeEvent.organizerName,
          masterId: oldTimeEvent.masterId,
          originalStart: oldTimeEvent.originalStart,
          isOccurrence: oldTimeEvent.isOccurrence,
          createdAt: oldTimeEvent.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      LogService.info('EventProvider', 'Optimistic update for event: ${updated.title}');
      notifyListeners();
    } else {
      // Event not found - add it
      _events.add(updated);
      LogService.info('EventProvider', 'Optimistic add for event: ${updated.title}');
      notifyListeners();
    }
    
  // Return rollback function
    return () {
      _events.clear();
      _events.addAll(snapshot);
      _timeEvents.clear();
      _timeEvents.addAll(timeEventsSnapshot);
      notifyListeners();
    };
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;
  _DateRange({required this.start, required this.end});
}

class CacheMetrics {
  int cacheHits = 0;
  int cacheMisses = 0;
  int partialUpdates = 0;
  int fullInvalidations = 0;
  int backgroundRefreshes = 0;
  
  double get hitRate => (cacheHits + cacheMisses) == 0 ? 0 : cacheHits / (cacheHits + cacheMisses);
  
  @override
  String toString() => 'Hits: $cacheHits, Misses: $cacheMisses, Hit Rate: ${hitRate.toStringAsFixed(2)}, Surgical Updates: $partialUpdates, Full Invalidations: $fullInvalidations, BG Refreshes: $backgroundRefreshes';
}
