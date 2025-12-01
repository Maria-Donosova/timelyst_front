import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';

void main() {
  group('TimeEvent Model Serialization', () {
    test('toJson converts dates to UTC', () {
      final event = TimeEvent(
        id: 'test-id',
        userId: 'user-123',
        calendarId: 'cal-123',
        providerEventId: 'prov-123',
        etag: 'etag',
        eventTitle: 'Test Event',
        start: DateTime.parse('2023-01-01T10:00:00'),
        end: DateTime.parse('2023-01-01T11:00:00'),
        startTimeZone: 'UTC',
        endTimeZone: 'UTC',
        recurrenceRule: '',
        isAllDay: false,
        category: 'Work',
        location: 'Office',
        description: 'Meeting',
        createdAt: DateTime.parse('2023-01-01T09:00:00'),
        updatedAt: DateTime.parse('2023-01-01T09:30:00'),
      );

      final json = event.toJson();

      expect(json['start'], endsWith('Z'));
      expect(json['end'], endsWith('Z'));
      expect(json['createdAt'], endsWith('Z'));
      expect(json['updatedAt'], endsWith('Z'));
    });
  });
}
