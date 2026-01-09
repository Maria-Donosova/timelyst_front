import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/utils/dateUtils.dart';

void main() {
  group('DateTimeUtils.parseAnyFormat', () {
    test('should return current time when value is null', () {
      final now = DateTime.now();
      final result = DateTimeUtils.parseAnyFormat(null);
      expect(result.year, now.year);
      expect(result.month, now.month);
      expect(result.day, now.day);
    });

    test('should parse numeric timestamp (milliseconds)', () {
      const timestamp = 1731513600000; // 2024-11-13 16:00:00 UTC
      final result = DateTimeUtils.parseAnyFormat(timestamp);
      final expected = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      expect(result, expected);
    });

    test('should parse string timestamp', () {
      const timestampStr = '1731513600000';
      final result = DateTimeUtils.parseAnyFormat(timestampStr);
      final expected = DateTime.fromMillisecondsSinceEpoch(1731513600000).toLocal();
      expect(result, expected);
    });

    test('should preserve wall clock time for ISO strings with offsets', () {
      const isoWithOffset = '2024-11-21T14:30:00-05:00';
      final result = DateTimeUtils.parseAnyFormat(isoWithOffset);
      
      expect(result.year, 2024);
      expect(result.month, 11);
      expect(result.day, 21);
      expect(result.hour, 14);
      expect(result.minute, 30);
      expect(result.second, 0);
    });

    test('should preserve wall clock time for ISO strings with + offsets', () {
      const isoWithOffset = '2024-11-21T14:30:00+02:00';
      final result = DateTimeUtils.parseAnyFormat(isoWithOffset);
      
      expect(result.year, 2024);
      expect(result.month, 11);
      expect(result.day, 21);
      expect(result.hour, 14);
      expect(result.minute, 30);
      expect(result.second, 0);
    });

    test('should convert UTC (Z) to local time', () {
      const utcString = '2024-11-21T14:30:00Z';
      final result = DateTimeUtils.parseAnyFormat(utcString);
      final expected = DateTime.parse(utcString).toLocal();
      expect(result, expected);
    });

    test('should treat local ISO strings as local time', () {
      const localString = '2024-11-21T14:30:00';
      final result = DateTimeUtils.parseAnyFormat(localString);
      expect(result.year, 2024);
      expect(result.month, 11);
      expect(result.day, 21);
      expect(result.hour, 14);
    });

    test('should handle invalid formats by returning current time', () {
      final result = DateTimeUtils.parseAnyFormat('invalid-date');
      final now = DateTime.now();
      expect(result.year, now.year);
    });
  });

  group('DateTimeUtils.formatForApi', () {
    test('should return ISO8601 string', () {
      final date = DateTime(2024, 11, 21, 14, 30);
      final result = DateTimeUtils.formatForApi(date);
      expect(result, date.toIso8601String());
    });
  });

  group('DateTimeUtils.parseTimeString', () {
    test('should parse HH:mm', () {
      final result = DateTimeUtils.parseTimeString('14:30');
      expect(result.hour, 14);
      expect(result.minute, 30);
    });

    test('should parse H:mm AM', () {
      final result = DateTimeUtils.parseTimeString('9:45 AM');
      expect(result.hour, 9);
      expect(result.minute, 45);
    });

    test('should parse H:mm PM', () {
      final result = DateTimeUtils.parseTimeString('2:30 PM');
      expect(result.hour, 14);
      expect(result.minute, 30);
    });

    test('should parse 12 AM as 00:00', () {
      final result = DateTimeUtils.parseTimeString('12:00 AM');
      expect(result.hour, 0);
      expect(result.minute, 0);
    });

    test('should parse 12 PM as 12:00', () {
      final result = DateTimeUtils.parseTimeString('12:00 PM');
      expect(result.hour, 12);
      expect(result.minute, 0);
    });

    test('should handle invalid time by returning current time', () {
      final result = DateTimeUtils.parseTimeString('invalid');
      final now = TimeOfDay.now();
      expect(result.hour, now.hour);
      expect(result.minute, now.minute);
    });
  });
}
