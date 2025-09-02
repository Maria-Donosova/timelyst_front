import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:timelyst_flutter/services/googleIntegration/calendarSyncManager.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleCalendarService.dart';

import 'calendar_sync_manager_test.mocks.dart';

@GenerateMocks([GoogleCalendarService])
void main() {
  group('CalendarSyncManager', () {
    late MockGoogleCalendarService mockGoogleCalendarService;
    late CalendarSyncManager calendarSyncManager;

    setUp(() {
      mockGoogleCalendarService = MockGoogleCalendarService();
      calendarSyncManager = CalendarSyncManager(calendarService: mockGoogleCalendarService);
    });

    group('syncCalendars', () {
      test('should return a successful result with calendars', () async {
        // Arrange
        final calendarPage = CalendarPage(calendars: [Calendar.fromLegacyJson({'id': 'cal1'})], syncToken: 'sync_token');
        when(mockGoogleCalendarService.fetchCalendarsPage(userId: anyNamed('userId'), email: anyNamed('email')))
            .thenAnswer((_) async => calendarPage);

        // Act
        final result = await calendarSyncManager.syncCalendars('user1', 'test@example.com');

        // Assert
        expect(result.isSuccess, true);
        expect(result.calendars.length, 1);
        expect(result.syncToken, 'sync_token');
      });

      test('should return an error result on exception', () async {
        // Arrange
        when(mockGoogleCalendarService.fetchCalendarsPage(userId: anyNamed('userId'), email: anyNamed('email')))
            .thenThrow(Exception('Failed to fetch'));

        // Act
        final result = await calendarSyncManager.syncCalendars('user1', 'test@example.com');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });
    });

    group('saveSelectedCalendars', () {
      test('should return a successful result on successful save', () async {
        // Arrange
        final calendars = [Calendar.fromLegacyJson({'id': 'cal1'})];
        when(mockGoogleCalendarService.saveCalendarsBatch(userId: anyNamed('userId'), email: anyNamed('email'), calendars: anyNamed('calendars')))
            .thenAnswer((_) async => Future.value());
        when(mockGoogleCalendarService.fetchCalendarsPage(userId: anyNamed('userId'), email: anyNamed('email')))
            .thenAnswer((_) async => CalendarPage(calendars: [], syncToken: 'new_sync_token'));

        // Act
        final result = await calendarSyncManager.saveSelectedCalendars(userId: 'user1', email: 'test@example.com', selectedCalendars: calendars);

        // Assert
        expect(result.success, true);
      });
    });
  });
}
