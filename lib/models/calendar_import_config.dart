import 'package:flutter/material.dart';
import 'import_settings.dart';

class CalendarImportConfig {
  final String? calendarId;
  final String providerCalendarId;
  final String title;
  final ImportSettings importSettings;
  final Color color;
  final String category;

  CalendarImportConfig({
    this.calendarId,
    required this.providerCalendarId,
    required this.title,
    required this.importSettings,
    required this.color,
    required this.category,
  });

  CalendarImportConfig copyWith({
    String? calendarId,
    String? providerCalendarId,
    String? title,
    ImportSettings? importSettings,
    Color? color,
    String? category,
  }) {
    return CalendarImportConfig(
      calendarId: calendarId ?? this.calendarId,
      providerCalendarId: providerCalendarId ?? this.providerCalendarId,
      title: title ?? this.title,
      importSettings: importSettings ?? this.importSettings,
      color: color ?? this.color,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calendarId': calendarId,
      'providerCalendarId': providerCalendarId,
      'importSettings': importSettings.toJson(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}', // Keep it #RRGGBB
      'category': category,
    };
  }
}
