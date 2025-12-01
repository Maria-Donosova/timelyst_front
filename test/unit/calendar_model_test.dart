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
        metadata: CalendarMetadata(title: 'Test', color: const Color(0xFFA4BDFC)),
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
}
