import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/calendars.dart';

void main() {
  group('Calendar Model Parsing', () {
    test('fromJson handles empty list for metadata, preferences, and sync', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'LOCAL',
        'providerCalendarId': 'prov-id',
        'metadata': [], // Simulating the bug: empty list instead of map
        'preferences': [], // Simulating the bug
        'sync': [], // Simulating the bug
        'syncToken': 'token',
        'isSelected': true,
        'isPrimary': false,
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-01T00:00:00.000Z',
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.id, 'test-id');
      expect(calendar.metadata, isA<CalendarMetadata>());
      expect(calendar.preferences, isA<CalendarPreferences>());
      expect(calendar.sync, isA<CalendarSyncInfo>());
    });

    test('fromJson handles null for metadata, preferences, and sync', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'LOCAL',
        'providerCalendarId': 'prov-id',
        'metadata': null,
        'preferences': null,
        'sync': null,
        'syncToken': 'token',
        'isSelected': true,
        'isPrimary': false,
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-01T00:00:00.000Z',
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.id, 'test-id');
      expect(calendar.metadata, isA<CalendarMetadata>());
      expect(calendar.preferences, isA<CalendarPreferences>());
      expect(calendar.sync, isA<CalendarSyncInfo>());
    });
    });


  group('Calendar Model Serialization', () {
    test('toJson converts dates to UTC', () {
      final calendar = Calendar(
        id: 'test-id',
        userId: 'user-123',
        source: CalendarSource.LOCAL,
        providerCalendarId: 'prov-id',
        metadata: CalendarMetadata(title: 'Test', color: '#A4BDFC'),
        preferences: CalendarPreferences(importSettings: CalendarImportSettings()),
        sync: CalendarSyncInfo(
          lastSyncedAt: DateTime.parse('2023-01-01T12:00:00'), // Local time
          expiration: DateTime.parse('2023-01-02T12:00:00'), // Local time
        ),
        syncToken: 'token',
        isSelected: true,
        isPrimary: false,
        createdAt: DateTime.parse('2023-01-01T10:00:00'), // Local time
        updatedAt: DateTime.parse('2023-01-01T11:00:00'), // Local time
      );

      final json = calendar.toJson();

      expect(json['createdAt'], endsWith('Z'));
      expect(json['updatedAt'], endsWith('Z'));
      expect(json['sync']['lastSyncedAt'], endsWith('Z'));
      expect(json['sync']['expiration'], endsWith('Z'));
    });
  });

  group('Defensive Date Parsing', () {
    test('fromJson handles missing createdAt and updatedAt fields', () {
      final json = {
        'id': 'google-calendar-id',
        'provider': 'google',
        'name': 'Jewish Holidays',
        'color': '#9fc6e7',
        // No createdAt, no updatedAt - simulating backend response
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.id, 'google-calendar-id');
      expect(calendar.createdAt, isNull);
      expect(calendar.updatedAt, isNull);
    });

    test('fromJson handles null createdAt and updatedAt fields', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'GOOGLE',
        'createdAt': null,
        'updatedAt': null,
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.createdAt, isNull);
      expect(calendar.updatedAt, isNull);
    });

    test('fromJson handles empty string createdAt and updatedAt fields', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'MICROSOFT',
        'createdAt': '',
        'updatedAt': '',
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.createdAt, isNull);
      expect(calendar.updatedAt, isNull);
    });

    test('fromJson handles invalid date format gracefully', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'APPLE',
        'createdAt': 'not-a-date',
        'updatedAt': 'also-not-a-date',
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.createdAt, isNull);
      expect(calendar.updatedAt, isNull);
    });

    test('fromJson parses valid dates correctly', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'source': 'LOCAL',
        'createdAt': '2023-06-15T10:30:00.000Z',
        'updatedAt': '2023-06-16T14:45:00.000Z',
      };

      final calendar = Calendar.fromJson(json);

      expect(calendar.createdAt, isNotNull);
      expect(calendar.updatedAt, isNotNull);
      expect(calendar.createdAt!.year, 2023);
      expect(calendar.createdAt!.month, 6);
      expect(calendar.createdAt!.day, 15);
    });

    test('toJson handles null dates gracefully', () {
      final calendar = Calendar(
        id: 'test-id',
        userId: 'user-123',
        source: CalendarSource.GOOGLE,
        providerCalendarId: 'prov-id',
        metadata: CalendarMetadata(title: 'Test'),
        preferences: CalendarPreferences(importSettings: CalendarImportSettings()),
        sync: CalendarSyncInfo(),
        isSelected: true,
        isPrimary: false,
        createdAt: null,
        updatedAt: null,
      );

      final json = calendar.toJson();

      expect(json['createdAt'], isNull);
      expect(json['updatedAt'], isNull);
    });

    test('fromAppleJson handles missing dates same as fromJson', () {
      final json = {
        'id': 'apple-calendar-id',
        'provider': 'apple',
        'name': 'iCloud Calendar',
        // No createdAt, no updatedAt
      };

      final calendar = Calendar.fromAppleJson(json);

      expect(calendar.id, 'apple-calendar-id');
      expect(calendar.source, CalendarSource.APPLE);
      expect(calendar.createdAt, isNull);
      expect(calendar.updatedAt, isNull);
    });
  });
}
