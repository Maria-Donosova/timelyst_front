import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/services/eventsService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/models/customApp.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';
import '../../mocks/mockAuthService.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    });
  });

  group('EventProvider', () {
    late MockAuthService mockAuthService;
    late EventProvider eventProvider;

    setUp(() {
      mockAuthService = MockAuthService();
      eventProvider = EventProvider(authService: mockAuthService);
    });

    test('initial state is correct', () {
      expect(eventProvider.events, isEmpty);
      expect(eventProvider.isLoading, isFalse);
      expect(eventProvider.errorMessage, isEmpty);
    });

    test('fetchCalendarView updates events on success', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');
      
      final mockResponse = {
        'events': [
          _createTimeEventJson(id: 'event-1', title: 'Test Event')
        ],
        'masters': [],
        'occurrenceCounts': {}
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      EventService.apiClient = ApiClient(client: mockClient);

      await eventProvider.fetchCalendarView(
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 2),
      );

      expect(eventProvider.events.length, 1);
      expect(eventProvider.events[0].title, 'Test Event');
      expect(eventProvider.isLoading, isFalse);
    });

    test('cache management works correctly', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');
      
      int apiCallCount = 0;
      final mockResponse = {
        'events': [_createTimeEventJson(id: 'event-1', title: 'Cached Event')],
        'masters': [],
        'occurrenceCounts': {}
      };

      final mockClient = MockClient((request) async {
        apiCallCount++;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      EventService.apiClient = ApiClient(client: mockClient);

      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 1, 2);

      await eventProvider.fetchCalendarView(startDate: start, endDate: end);
      expect(apiCallCount, 1);

      await eventProvider.fetchCalendarView(startDate: start, endDate: end);
      expect(apiCallCount, 1);

      await eventProvider.fetchCalendarView(startDate: start, endDate: end, forceRefresh: true);
      expect(apiCallCount, 2);
    });

    test('incremental synchronization works via fetchAllEvents', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');
      
      final initialEvents = [
        _createTimeEventJson(id: 'event-1', title: 'Event 1'),
        _createTimeEventJson(id: 'event-2', title: 'Event 2'),
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(initialEvents), 200);
      });
      EventService.apiClient = ApiClient(client: mockClient);

      await eventProvider.fetchAllEvents();
      expect(eventProvider.events.length, 2);

      final updatedEvents = [
        _createTimeEventJson(id: 'event-1', title: 'Event 1 Updated'),
        _createTimeEventJson(id: 'event-3', title: 'Event 3'),
      ];

      final secondClient = MockClient((request) async {
        return http.Response(jsonEncode(updatedEvents), 200);
      });
      EventService.apiClient = ApiClient(client: secondClient);

      await eventProvider.fetchAllEvents();
      
      expect(eventProvider.events.length, 2);
      expect(eventProvider.events.firstWhere((e) => e.id == 'event-1').title, 'Event 1 Updated');
      expect(eventProvider.events.any((e) => e.id == 'event-2'), isFalse);
      expect(eventProvider.events.any((e) => e.id == 'event-3'), isTrue);
    });

    test('date range synchronization preserves events outside range', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');
      
      // 1. Initial event in week 1
      final initialEvents = [
        _createTimeEventJson(id: 'week1-event', title: 'Week 1', start: '2023-01-01T10:00:00.000Z')
      ];

      EventService.apiClient = ApiClient(client: MockClient((request) async {
        return http.Response(jsonEncode({'events': initialEvents, 'masters': [], 'occurrenceCounts': {}}), 200);
      }));

      await eventProvider.fetchCalendarView(
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 7),
      );
      expect(eventProvider.events.length, 1);

      // 2. Fetch week 2 - should preserve week 1
      final week2Events = [
        _createTimeEventJson(id: 'week2-event', title: 'Week 2', start: '2023-01-08T10:00:00.000Z')
      ];

      EventService.apiClient = ApiClient(client: MockClient((request) async {
        return http.Response(jsonEncode({'events': week2Events, 'masters': [], 'occurrenceCounts': {}}), 200);
      }));

      await eventProvider.fetchCalendarView(
        startDate: DateTime(2023, 1, 8),
        endDate: DateTime(2023, 1, 14),
      );
      
      expect(eventProvider.events.length, 2, reason: 'Should have both Week 1 and Week 2 events');
      expect(eventProvider.events.any((e) => e.id == 'week1-event'), isTrue);
      expect(eventProvider.events.any((e) => e.id == 'week2-event'), isTrue);
    });

    test('optimisticUpdateEvent updates state and provides rollback', () async {
      final initialEvent = _createTestAppointment(id: 'event-1', title: 'Old Title');
      eventProvider.addSingleEvent(initialEvent);
      
      final updatedEvent = initialEvent.copyWith(title: 'New Title');
      
      final rollback = eventProvider.optimisticUpdateEvent('event-1', updatedEvent);
      
      expect(eventProvider.events[0].title, 'New Title');
      
      rollback();
      
      expect(eventProvider.events[0].title, 'Old Title');
    });
  });
}

Map<String, dynamic> _createTimeEventJson({
  required String id, 
  required String title,
  String start = '2023-01-01T10:00:00.000Z',
  String end = '2023-01-01T11:00:00.000Z'
}) {
  return {
    'id': id,
    'userId': 'user-1',
    'calendarIds': ['cal-1'],
    'provider': 'timelyst',
    'providerEventId': 'prov-$id',
    'etag': 'etag-$id',
    'eventTitle': title,
    'start': start,
    'end': end,
    'category': 'Work',
    'isAllDay': false,
    'recurrenceRule': '',
    'location': '',
    'description': '',
    'createdAt': '2023-01-01T09:00:00.000Z',
    'updatedAt': '2023-01-01T09:00:00.000Z',
  };
}

CustomAppointment _createTestAppointment({required String id, required String title}) {
  return CustomAppointment(
    id: id,
    title: title,
    startTime: DateTime(2023, 1, 1, 10),
    endTime: DateTime(2023, 1, 1, 11),
    isAllDay: false,
    catColor: Colors.blue,
  );
}
