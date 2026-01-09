import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/utils/rruleParser.dart';

void main() {
  group('RRuleParser', () {
    group('parseRRule', () {
      test('should parse simple DAILY rule', () {
        final rrule = 'FREQ=DAILY;INTERVAL=2';
        final info = RRuleParser.parseRRule(rrule);
        
        expect(info, isNotNull);
        expect(info!.frequency, equals('DAILY'));
        expect(info.interval, equals(2));
      });

      test('should parse rule with RRULE: prefix', () {
        final rrule = 'RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR';
        final info = RRuleParser.parseRRule(rrule);
        
        expect(info, isNotNull);
        expect(info!.frequency, equals('WEEKLY'));
        expect(info.byDay, equals(['MO', 'WE', 'FR']));
      });

      test('should parse rule with COUNT', () {
        final rrule = 'FREQ=MONTHLY;COUNT=12';
        final info = RRuleParser.parseRRule(rrule);
        
        expect(info!.count, equals(12));
      });

      test('should parse rule with UNTIL', () {
        // UNTIL format: 20251231T235959Z
        final rrule = 'FREQ=YEARLY;UNTIL=20251231T235959Z';
        final info = RRuleParser.parseRRule(rrule);
        
        expect(info!.until, isNotNull);
        expect(info.until!.year, equals(2025));
        expect(info.until!.month, equals(12));
        expect(info.until!.day, equals(31));
      });

      test('should return null for empty or invalid rule', () {
        expect(RRuleParser.parseRRule(null), isNull);
        expect(RRuleParser.parseRRule(''), isNull);
        expect(RRuleParser.parseRRule('INVALID'), isNull);
      });
    });

    group('calculateOccurrenceNumber', () {
      final baseDate = DateTime(2024, 1, 1); // Monday

      test('DAILY with interval 1', () {
        final rrule = 'FREQ=DAILY';
        final target = baseDate.add(const Duration(days: 5));
        
        final occurrence = RRuleParser.calculateOccurrenceNumber(
          eventStart: target,
          seriesStart: baseDate,
          rrule: rrule,
        );
        
        expect(occurrence, equals(6)); // 1, 2, 3, 4, 5, 6
      });

      test('DAILY with interval 2', () {
        final rrule = 'FREQ=DAILY;INTERVAL=2';
        final target = baseDate.add(const Duration(days: 4));
        
        final occurrence = RRuleParser.calculateOccurrenceNumber(
          eventStart: target,
          seriesStart: baseDate,
          rrule: rrule,
        );
        
        expect(occurrence, equals(3)); // day 0 (1st), day 2 (2nd), day 4 (3rd)
      });

      test('WEEKLY with BYDAY', () {
        // Monday, Wednesday, Friday
        final rrule = 'FREQ=WEEKLY;BYDAY=MO,WE,FR';
        
        // baseDate is Monday (1st occurrence)
        // Wednesday (2nd)
        // Friday (3rd)
        // Next Monday (4th)
        
        final nextMon = baseDate.add(const Duration(days: 7));
        final occurrence = RRuleParser.calculateOccurrenceNumber(
          eventStart: nextMon,
          seriesStart: baseDate,
          rrule: rrule,
        );
        
        expect(occurrence, equals(4));
      });

      test('MONTHLY', () {
        final rrule = 'FREQ=MONTHLY';
        final target = DateTime(2024, 4, 1);
        
        final occurrence = RRuleParser.calculateOccurrenceNumber(
          eventStart: target,
          seriesStart: baseDate,
          rrule: rrule,
        );
        
        expect(occurrence, equals(4)); // Jan, Feb, Mar, Apr
      });

      test('YEARLY', () {
        final rrule = 'FREQ=YEARLY';
        final target = DateTime(2026, 1, 1);
        
        final occurrence = RRuleParser.calculateOccurrenceNumber(
          eventStart: target,
          seriesStart: baseDate,
          rrule: rrule,
        );
        
        expect(occurrence, equals(3)); // 2024, 2025, 2026
      });
    });

    group('getTotalOccurrences', () {
      final startDate = DateTime(2024, 1, 1);

      test('should return COUNT if present', () {
        final rrule = 'FREQ=DAILY;COUNT=10';
        expect(RRuleParser.getTotalOccurrences(rrule, startDate), equals(10));
      });

      test('should calculate occurrences until UNTIL date', () {
        // Daily for 5 days
        final rrule = 'FREQ=DAILY;UNTIL=20240105T235959Z';
        
        expect(RRuleParser.getTotalOccurrences(rrule, startDate), equals(5));
      });

      test('should return null for infinite recurrence', () {
        final rrule = 'FREQ=DAILY';
        expect(RRuleParser.getTotalOccurrences(rrule, startDate), isNull);
      });
    });

    group('RecurrenceInfo Description', () {
      test('DAILY description', () {
        final info = RecurrenceInfo(frequency: 'DAILY', interval: 1);
        expect(info.getHumanReadableDescription(), equals('Daily'));
        
        final intervalInfo = RecurrenceInfo(frequency: 'DAILY', interval: 3);
        expect(intervalInfo.getHumanReadableDescription(), equals('Every 3 days'));
      });

      test('WEEKLY description with days', () {
        final info = RecurrenceInfo(
          frequency: 'WEEKLY', 
          interval: 1, 
          byDay: ['MO', 'WE']
        );
        // Note: Implementation uses "Mon and Wed" for two items
        expect(info.getHumanReadableDescription(), contains('Weekly on Mon and Wed'));
      });
    });
  });
}
