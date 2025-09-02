import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleCalendarService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:http/http.dart' as http;

import 'google_calendar_service_test.mocks.dart';

@GenerateMocks([ApiClient, AuthService])
void main() {
  group('GoogleCalendarService', () {
    late MockApiClient mockApiClient;
    late MockAuthService mockAuthService;
    late GoogleCalendarService googleCalendarService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuthService = MockAuthService();
      googleCalendarService = GoogleCalendarService(authService: mockAuthService, apiClient: mockApiClient);
    });

    group('firstCalendarFetch', () {
      test('should return a list of calendars on successful fetch', () async {
        // Arrange
        final authCode = 'test_auth_code';
        final token = 'test_token';
        final responsePayload = {
          'success': true,
          'data': {
            'calendars': [
              {
                'id': 'cal1',
                'summary': 'Calendar 1',
                'backgroundColor': '#ffffff',
                'foregroundColor': '#000000',
                'primary': true,
                'selected': true,
                'timeZone': 'America/New_York'
              }
            ]
          }
        };
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(mockApiClient.post(any, body: anyNamed('body'), token: token))
            .thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        // Act
        final result = await googleCalendarService.firstCalendarFetch(authCode: authCode);

        // Assert
        expect(result, isA<List<Calendar>>());
        expect(result.length, 1);
        expect(result[0].id, 'cal1');
      });

      test('should throw an exception on failed fetch', () async {
        // Arrange
        final authCode = 'test_auth_code';
        final token = 'test_token';
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(mockApiClient.post(any, body: anyNamed('body'), token: token))
            .thenAnswer((_) async => http.Response('{"success": false, "message": "Failed to fetch"}', 200));

        // Act & Assert
        expect(() => googleCalendarService.firstCalendarFetch(authCode: authCode), throwsException);
      });
    });

    group('fetchCalendarChanges', () {
      test('should return calendar delta on successful fetch', () async {
        // Arrange
        final token = 'test_token';
        final responsePayload = {
          'success': true,
          'data': {
            'changes': [],
            'deletedCalendarIds': [],
            'newSyncToken': 'new_sync_token',
            'hasMoreChanges': false
          }
        };
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(mockApiClient.post(any, body: anyNamed('body'), token: token))
            .thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        // Act
        final result = await googleCalendarService.fetchCalendarChanges(
            userId: 'user1', email: 'test@example.com', syncToken: 'old_sync_token');

        // Assert
        expect(result, isA<CalendarDelta>());
        expect(result.newSyncToken, 'new_sync_token');
      });
    });

    group('saveCalendarsBatch', () {
      test('should complete successfully on successful save', () async {
        // Arrange
        final token = 'test_token';
        final calendars = [
          Calendar.fromLegacyJson({'id': 'cal1', 'summary': 'Calendar 1', 'email': 'test@example.com'})
        ];
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(mockApiClient.post(any, body: anyNamed('body'), token: token))
            .thenAnswer((_) async => http.Response('{"success": true}', 200));

        // Act & Assert
        expect(
            () async => await googleCalendarService.saveCalendarsBatch(
                userId: 'user1', email: 'test@example.com', calendars: calendars),
            returnsNormally);
      });
    });

    group('fetchCalendarsPage', () {
      test('should return calendar page on successful fetch', () async {
        // Arrange
        final token = 'test_token';
        final responsePayload = {
          'success': true,
          'data': {
            'calendars': [],
            'nextPageToken': 'next_page_token',
            'hasMore': true,
            'totalItems': 1
          }
        };
        when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
        when(mockApiClient.post(any, body: anyNamed('body'), token: token))
            .thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

        // Act
        final result = await googleCalendarService.fetchCalendarsPage(
            userId: 'user1', email: 'test@example.com');

        // Assert
        expect(result, isA<CalendarPage>());
        expect(result.nextPageToken, 'next_page_token');
      });
    });
  });
}