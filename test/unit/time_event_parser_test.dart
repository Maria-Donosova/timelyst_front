import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';

void main() {
  group('TimeEvent.fromJson Null-Safety', () {
    final baseJson = {
      'id': 'test-id',
      'userId': 'user-123',
      'calendarIds': ['cal-1'],
      'provider': 'timelyst',
      'providerEventId': 'p-1',
      'etag': 'e1',
      'eventTitle': 'Test',
      'start': '2024-01-01T10:00:00Z',
      'end': '2024-01-01T11:00:00Z',
      'isAllDay': false,
      'category': 'Work',
      'location': '',
      'description': '',
      'createdAt': '2024-01-01T09:00:00Z',
      'updatedAt': '2024-01-01T09:00:00Z',
    };

    test('parses successfully when expanded fields are missing', () {
      final event = TimeEvent.fromJson(baseJson);
      
      expect(event.masterId, isNull);
      expect(event.isOccurrence, isFalse);
      expect(event.originalStart, isNull);
    });

    test('parses successfully when expanded fields are null', () {
      final jsonWithNulls = Map<String, dynamic>.from(baseJson)..addAll({
        'masterId': null,
        'isOccurrence': null,
        'originalStart': null,
      });
      
      final event = TimeEvent.fromJson(jsonWithNulls);
      
      expect(event.masterId, isNull);
      expect(event.isOccurrence, isFalse);
      expect(event.originalStart, isNull);
    });

    test('parses snake_case fields correctly', () {
      final snakeCaseJson = Map<String, dynamic>.from(baseJson)..addAll({
        'master_id': 'master-123',
        'is_occurrence': true,
        'original_start': '2024-01-01T08:00:00Z',
      });
      
      final event = TimeEvent.fromJson(snakeCaseJson);
      
      expect(event.masterId, equals('master-123'));
      expect(event.isOccurrence, isTrue);
      expect(event.originalStart, equals(DateTime.parse('2024-01-01T08:00:00Z')));
    });

    test('prefers camelCase over snake_case if both present', () {
      final mixedJson = Map<String, dynamic>.from(baseJson)..addAll({
        'masterId': 'camel-master',
        'master_id': 'snake-master',
        'originalStart': '2024-01-01T07:00:00Z',
        'original_start': '2024-01-01T06:00:00Z',
      });
      
      final event = TimeEvent.fromJson(mixedJson);
      
      expect(event.masterId, equals('camel-master'));
      expect(event.originalStart, equals(DateTime.parse('2024-01-01T07:00:00Z')));
    });
  });
}
