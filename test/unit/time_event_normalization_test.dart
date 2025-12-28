import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';

void main() {
  group('TimeEvent Category Normalization', () {
    Map<String, dynamic> createBaseJson(String? category) {
      return {
        'id': 'test-1',
        'userId': 'user-1',
        'calendarIds': ['cal-1'],
        'provider': 'google',
        'providerEventId': 'p-1',
        'etag': 'e1',
        'eventTitle': 'Test',
        'start': '2024-01-01T10:00:00Z',
        'end': '2024-01-01T11:00:00Z',
        'isAllDay': false,
        'category': category,
        'location': '',
        'description': '',
        'status': 'confirmed',
        'createdAt': '2024-01-01T09:00:00Z',
        'updatedAt': '2024-01-01T09:00:00Z',
      };
    }

    test('should normalize lowercase category to Title Case', () {
      final json = createBaseJson('personal');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Personal'));
    });

    test('should normalize uppercase category to Title Case', () {
      final json = createBaseJson('WORK');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Work'));
    });

    test('should normalize mixed case category to Title Case', () {
      final json = createBaseJson('fRiEnDs');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Friends'));
    });

    test('should default to Other for null category', () {
      final json = createBaseJson(null);
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Other'));
    });

    test('should default to Other for empty string category', () {
      final json = createBaseJson('');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Other'));
    });

    test('should default to Other for whitespace only category', () {
      final json = createBaseJson('   ');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Other'));
    });

    test('should default to Other for unknown category', () {
      final json = createBaseJson('unknown');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Other'));
    });

    test('should keep valid Title Case categories as is', () {
      final json = createBaseJson('Social');
      final event = TimeEvent.fromJson(json);
      expect(event.category, equals('Social'));
    });
  });
}
