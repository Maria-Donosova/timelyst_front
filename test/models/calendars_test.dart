import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:flutter/material.dart';

void main() {
  group('CalendarMetadata', () {
    test('should include category in json serialization', () {
      final metadata = CalendarMetadata(
        title: 'Test Calendar',
        category: 'Work',
      );

      final json = metadata.toJson();

      expect(json['title'], 'Test Calendar');
      expect(json['category'], 'Work');
    });

    test('should parse category from json', () {
      final json = {
        'title': 'Test Calendar',
        'category': 'Work',
      };

      final metadata = CalendarMetadata.fromJson(json);

      expect(metadata.title, 'Test Calendar');
      expect(metadata.category, 'Work');
    });

    test('copyWith should update category', () {
      final metadata = CalendarMetadata(category: 'Work');
      final updated = metadata.copyWith(category: 'Personal');

      expect(updated.category, 'Personal');
    });
  });

  group('CalendarPreferences', () {
    test('copyWith should update category', () {
      final prefs = CalendarPreferences(
        importSettings: CalendarImportSettings(),
        category: 'Work',
      );

      final updated = prefs.copyWith(category: 'Personal');

      expect(updated.category, 'Personal');
    });

    test('copyWith should clear category when clearCategory is true', () {
      final prefs = CalendarPreferences(
        importSettings: CalendarImportSettings(),
        category: 'Work',
      );

      final updated = prefs.copyWith(clearCategory: true);

      expect(updated.category, null);
    });

    test('copyWith should NOT clear category when passing null without clearCategory', () {
      final prefs = CalendarPreferences(
        importSettings: CalendarImportSettings(),
        category: 'Work',
      );

      final updated = prefs.copyWith(category: null);

      expect(updated.category, 'Work');
    });
  });
}
