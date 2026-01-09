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
          {
            'id': 'event-1',
            'userId': 'user-1',
            'calendarIds': ['cal-1'],
            'provider': 'timelyst',
            'providerEventId': 'prov-1',
            'etag': 'etag-1',
            'eventTitle': 'Test Event',
            'start': '2023-01-01T10:00:00.000Z',
            'end': '2023-01-01T11:00:00.000Z',
            'category': 'Work',
            'createdAt': '2023-01-01T09:00:00.000Z',
            'updatedAt': '2023-01-01T09:00:00.000Z',
          }
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
      expect(eventProvider.errorMessage, isEmpty);
    });

    test('fetchCalendarView sets error message on failure', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');
      
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      EventService.apiClient = ApiClient(client: mockClient);

      await eventProvider.fetchCalendarView();

      expect(eventProvider.isLoading, isFalse);
      expect(eventProvider.errorMessage, contains('Failed to fetch calendar view'));
      expect(eventProvider.events, isEmpty);
    });

    test('fetchAllEvents handles auth failure', () async {
      mockAuthService.setLoginState(false); // Not logged in

      await eventProvider.fetchAllEvents();

      expect(eventProvider.isLoading, isFalse);
      expect(eventProvider.errorMessage, contains('Authentication required'));
    });

    test('optimisticUpdateEvent updates state and provides rollback', () async {
      // Manual setup of an event
      final initialEvent = _createTestAppointment(id: 'event-1', title: 'Old Title');
      eventProvider.addSingleEvent(initialEvent);
      
      final updatedEvent = initialEvent.copyWith(title: 'New Title');
      
      final rollback = eventProvider.optimisticUpdateEvent('event-1', updatedEvent);
      
      expect(eventProvider.events[0].title, 'New Title');
      
      // Act: Rollback
      rollback();
      
      expect(eventProvider.events[0].title, 'Old Title');
    });
  });
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
