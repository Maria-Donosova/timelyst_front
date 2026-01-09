import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/utils/dateUtils.dart';

void main() {
  group('DateTimeUtils', () {
    group('parseAnyFormat', () {
      test('should parse numeric timestamp (int)', () {
        final timestamp = 1731111111000; // 2024-11-09T00:11:51.000
        final result = DateTimeUtils.parseAnyFormat(timestamp);
        expect(result.millisecondsSinceEpoch, equals(timestamp));
      });

      test('should parse numeric timestamp (string)', () {
        final timestampStr = '1731111111000';
        final result = DateTimeUtils.parseAnyFormat(timestampStr);
        expect(result.millisecondsSinceEpoch, equals(1731111111000));
      });

      test('should preserve wall clock time from ISO strings with offsets', () {
        // Backend returns "2024-11-21T14:30:00-05:00"
        // We want to see 14:30 regardless of our local timezone
        final isoWithOffset = '2024-11-21T14:30:00-05:00';
        final result = DateTimeUtils.parseAnyFormat(isoWithOffset);
        
        expect(result.year, equals(2024));
        expect(result.month, equals(11));
        expect(result.day, equals(21));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
        expect(result.second, equals(0));
      });

      test('should convert UTC (Z) strings to local', () {
        // "2024-11-21T14:30:00Z" -> parsed and then .toLocal() called
        final utcString = '2024-11-21T14:30:00Z';
        final result = DateTimeUtils.parseAnyFormat(utcString);
        
        final expected = DateTime.parse(utcString).toLocal();
        expect(result, equals(expected));
      });

      test('should parse ISO strings without timezone info as local', () {
        final localString = '2024-11-21T14:30:00';
        final result = DateTimeUtils.parseAnyFormat(localString);
        
        expect(result.year, equals(2024));
        expect(result.hour, equals(14));
        // result should be exactly what DateTime.parse(localString) gives
        expect(result, equals(DateTime.parse(localString)));
      });

      test('should return DateTime.now() on null', () {
        final start = DateTime.now();
        final result = DateTimeUtils.parseAnyFormat(null);
        final end = DateTime.now();
        
        expect(result.isAfter(start.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.isBefore(end.add(const Duration(seconds: 1))), isTrue);
      });

      test('should return DateTime.now() on invalid input', () {
        final start = DateTime.now();
        final result = DateTimeUtils.parseAnyFormat('not-a-date');
        final end = DateTime.now();
        
        expect(result.isAfter(start.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.isBefore(end.add(const Duration(seconds: 1))), isTrue);
      });
    });

    test('formatForApi should return ISO8601 string', () {
      final date = DateTime(2024, 11, 21, 14, 30);
      final result = DateTimeUtils.formatForApi(date);
      expect(result, equals(date.toIso8601String()));
    });

    group('parseTimeString', () {
      test('should parse HH:mm format', () {
        final res = DateTimeUtils.parseTimeString('14:30');
        expect(res.hour, equals(14));
        expect(res.minute, equals(30));
      });

      test('should parse "H:mm AM/PM" format', () {
        final pmRes = DateTimeUtils.parseTimeString('2:30 PM');
        expect(pmRes.hour, equals(14));
        expect(pmRes.minute, equals(30));

        final amRes = DateTimeUtils.parseTimeString('10:15 AM');
        expect(amRes.hour, equals(10));
        expect(amRes.minute, equals(15));
      });

      test('should handle 12 AM/PM correctly', () {
        final twelvePm = DateTimeUtils.parseTimeString('12:00 PM');
        expect(twelvePm.hour, equals(12));

        final twelveAm = DateTimeUtils.parseTimeString('12:00 AM');
        expect(twelveAm.hour, equals(0));
      });

      test('should parse HH format (no minutes)', () {
        final res = DateTimeUtils.parseTimeString('10 AM');
        expect(res.hour, equals(10));
        expect(res.minute, equals(0));
      });

      test('should return TimeOfDay.now() on invalid time', () {
        final result = DateTimeUtils.parseTimeString('invalid');
        // Difficult to test exactly TimeOfDay.now() without mocking clock, 
        // but we can check it doesn't throw and returns a TimeOfDay
        expect(result, isA<TimeOfDay>());
      });
    });
  });
}
