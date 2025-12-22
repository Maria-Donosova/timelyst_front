import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/import_settings.dart';

void main() {
  group('ImportSettings Model Tests', () {
    test('fromJson - handles all level', () {
      final json = {'level': 'all', 'fields': []};
      final settings = ImportSettings.fromJson(json);
      expect(settings.level, ImportLevel.all);
      expect(settings.hasField('subject'), isTrue);
      expect(settings.hasField('location'), isTrue);
    });

    test('fromJson - handles none level', () {
      final json = {'level': 'none', 'fields': ['subject']};
      final settings = ImportSettings.fromJson(json);
      expect(settings.level, ImportLevel.none);
      expect(settings.hasField('subject'), isFalse);
    });

    test('fromJson - handles custom level', () {
      final json = {'level': 'custom', 'fields': ['subject', 'location']};
      final settings = ImportSettings.fromJson(json);
      expect(settings.level, ImportLevel.custom);
      expect(settings.hasField('subject'), isTrue);
      expect(settings.hasField('location'), isTrue);
      expect(settings.hasField('organizer'), isFalse);
    });

    test('toJson - serializes correctly', () {
      final settings = ImportSettings(level: ImportLevel.custom, fields: ['subject']);
      final json = settings.toJson();
      expect(json['level'], 'custom');
      expect(json['fields'], ['subject']);
    });

    test('copyWith - works correctly', () {
      final settings = ImportSettings(level: ImportLevel.all);
      final updated = settings.copyWith(level: ImportLevel.none);
      expect(updated.level, ImportLevel.none);
    });
  });
}
