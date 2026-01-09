import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/utils/eventsMapper.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';
import 'package:timelyst_flutter/models/dayEvent.dart';

void main() {
  group('EventMapper', () {
    group('mapTimeEventToCustomAppointment', () {
      test('should map regular timed event correctly', () {
        final timeEvent = TimeEvent(
          id: '123',
          userId: 'u1',
          calendarIds: ['c1'],
          provider: 'google',
          providerEventId: 'p1',
          etag: 'e1',
          eventTitle: 'Meeting',
          start: DateTime.parse('2024-11-21T10:00:00Z'),
          end: DateTime.parse('2024-11-21T11:00:00Z'),
          isAllDay: false,
          recurrenceRule: '',
          category: 'Meeting',
          location: 'Office',
          description: 'Discuss project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);

        expect(appointment.id, equals('123'));
        expect(appointment.title, equals('Meeting'));
        expect(appointment.location, equals('Office'));
        expect(appointment.startTime, equals(timeEvent.start.toLocal()));
        expect(appointment.endTime, equals(timeEvent.end.toLocal()));
        expect(appointment.isAllDay, isFalse);
        expect(appointment.catColor, equals(Colors.blue));
      });

      test('should handle all-day event wall-clock preservation', () {
        // Nov 28, 2024 at 00:00:00 UTC
        final start = DateTime.utc(2024, 11, 28);
        // Exclusive end date: Nov 29, 2024 at 00:00:00 UTC
        final end = DateTime.utc(2024, 11, 29);

        final timeEvent = TimeEvent(
          id: 'all-day-1',
          userId: 'u1',
          calendarIds: ['c1'],
          provider: 'google',
          providerEventId: 'p1',
          etag: 'e1',
          eventTitle: 'Thanksgiving',
          start: start,
          end: end,
          isAllDay: true,
          recurrenceRule: '',
          category: 'Holiday',
          location: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);

        // Should stay Nov 28 regardless of local timezone
        expect(appointment.startTime.year, equals(2024));
        expect(appointment.startTime.month, equals(11));
        expect(appointment.startTime.day, equals(28));
        expect(appointment.startTime.hour, equals(0));

        // End time should be adjusted to 23:59:59 of the last active day (Nov 28)
        expect(appointment.endTime.year, equals(2024));
        expect(appointment.endTime.month, equals(11));
        expect(appointment.endTime.day, equals(28));
        expect(appointment.endTime.hour, equals(23));
        expect(appointment.endTime.minute, equals(59));
      });

      test('should handle multi-day all-day events', () {
        final start = DateTime.utc(2024, 11, 28);
        final end = DateTime.utc(2024, 11, 30); // 2 days: 28th and 29th

        final timeEvent = TimeEvent(
          id: 'multi-day',
          userId: 'u1',
          calendarIds: ['c1'],
          provider: 'google',
          providerEventId: 'p1',
          etag: 'e1',
          eventTitle: 'Trip',
          start: start,
          end: end,
          isAllDay: true,
          recurrenceRule: '',
          category: 'Personal',
          location: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);

        expect(appointment.startTime.day, equals(28));
        // End should be Nov 29 at 23:59:59
        expect(appointment.endTime.day, equals(29));
        expect(appointment.endTime.hour, equals(23));
      });

      test('should use "Busy" for empty titles', () {
        final timeEvent = TimeEvent(
          id: 'no-title',
          userId: 'u1',
          calendarIds: ['c1'],
          provider: 'google',
          providerEventId: 'p1',
          etag: 'e1',
          eventTitle: '',
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
          recurrenceRule: '',
          category: 'Other',
          location: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);
        expect(appointment.title, equals('Busy'));
      });
    });

    group('mapDayEventToCustomAppointment', () {
      test('should map DayEvent correctly', () {
        final dayEvent = DayEvent(
          id: 'd1',
          userId: 'u1',
          createdBy: 'admin',
          userCalendars: ['c1'],
          calendarId: 'c1',
          googleEventId: 'g1',
          googleKind: 'k1',
          googleEtag: 'e1',
          creator: {},
          organizer: {},
          eventTitle: 'Testing',
          start: '2024-11-21T10:00:00Z',
          end: '2024-11-21T11:00:00Z',
          is_AllDay: true,
          recurrence: [],
          recurrenceId: '',
          recurrenceExceptionDates: [],
          dayEventInstance: 'i1',
          category: 'Personal',
          eventBody: 'Body',
          eventLocation: 'Loc',
          eventConferenceDetails: '',
          participants: '',
          reminder: false,
          holiday: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final appointment = EventMapper.mapDayEventToCustomAppointment(dayEvent);

        expect(appointment.id, equals('d1'));
        expect(appointment.title, equals('Testing'));
        expect(appointment.description, equals('Body'));
        expect(appointment.isAllDay, isTrue);
        expect(appointment.catColor, equals(Colors.green));
      });
    });
  });
}
