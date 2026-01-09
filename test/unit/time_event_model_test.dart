import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';
import 'package:timelyst_flutter/models/attendee.dart';

void main() {
  group('TimeEvent Model', () {
    test('fromJson handles snake_case and camelCase keys', () {
      final json = {
        'id': 'test-1',
        'user_id': 'user-1',
        'calendar_ids': ['cal-1'],
        'provider': 'google',
        'provider_event_id': 'prov-1',
        'etag': 'etag-1',
        'event_title': 'Snake Case Title',
        'start': '2023-01-01T10:00:00.000Z',
        'end': '2023-01-01T11:00:00.000Z',
        'is_all_day': true,
        'category': 'work',
        'created_at': '2023-01-01T09:00:00.000Z',
        'updated_at': '2023-01-01T09:30:00.000Z',
      };

      final event = TimeEvent.fromJson(json);

      expect(event.userId, 'user-1');
      expect(event.calendarIds, ['cal-1']);
      expect(event.eventTitle, 'Snake Case Title');
      expect(event.isAllDay, isTrue);
      expect(event.category, 'Work'); // Normalized from 'work'
    });

    test('fromJson handles category normalization', () {
      expect(TimeEvent.fromJson(_baseJson(category: 'work')).category, 'Work');
      expect(TimeEvent.fromJson(_baseJson(category: '  PERSONAL  ')).category, 'Personal');
      expect(TimeEvent.fromJson(_baseJson(category: 'unknown')).category, 'Other');
      expect(TimeEvent.fromJson(_baseJson(category: null)).category, 'Other');
    });

    test('fromJson handles attendees', () {
      final json = _baseJson();
      json['attendees'] = [
        {'email': 'test@example.com', 'displayName': 'Test User', 'responseStatus': 'accepted'}
      ];

      final event = TimeEvent.fromJson(json);
      expect(event.attendees, isNotNull);
      expect(event.attendees!.length, 1);
      expect(event.attendees![0].email, 'test@example.com');
    });

    test('toJson converts dates to ISO strings', () {
      final event = _createTestEvent();
      final json = event.toJson();

      expect(json['start'], isA<String>());
      expect(json['end'], isA<String>());
      expect(DateTime.parse(json['start']).isAtSameMomentAs(event.start), isTrue);
    });

    test('recurrence getters work correctly', () {
      final master = _createTestEvent(recurrenceRule: 'FREQ=DAILY');
      expect(master.isMasterEvent, isTrue);
      expect(master.isRecurring, isTrue);

      final occurrence = _createTestEvent(masterId: 'master-1', isOccurrence: true);
      expect(occurrence.isExpandedOccurrence, isTrue);
      expect(occurrence.isMasterEvent, isFalse);
    });
  });
}

Map<String, dynamic> _baseJson({dynamic category = 'Work'}) {
  return {
    'id': 'id',
    'userId': 'user',
    'calendarIds': ['cal'],
    'provider': 'timelyst',
    'providerEventId': 'prov',
    'etag': 'etag',
    'eventTitle': 'Title',
    'start': '2023-01-01T10:00:00.000Z',
    'end': '2023-01-01T11:00:00.000Z',
    'category': category,
    'createdAt': '2023-01-01T09:00:00.000Z',
    'updatedAt': '2023-01-01T09:00:00.000Z',
  };
}

TimeEvent _createTestEvent({String recurrenceRule = '', String? masterId, bool isOccurrence = false}) {
  final now = DateTime.now();
  return TimeEvent(
    id: 'id',
    userId: 'user',
    calendarIds: ['cal'],
    provider: 'timelyst',
    providerEventId: 'prov',
    etag: 'etag',
    eventTitle: 'Title',
    start: now,
    end: now.add(const Duration(hours: 1)),
    recurrenceRule: recurrenceRule,
    isAllDay: false,
    category: 'Work',
    location: '',
    description: '',
    createdAt: now,
    updatedAt: now,
    masterId: masterId,
    isOccurrence: isOccurrence,
  );
}
