import 'package:flutter/material.dart';
import 'import_settings.dart';

class CalendarImportConfig {
  final String? calendarId;
  final String providerCalendarId;
  final String title;
  final ImportSettings importSettings;
  final Color color;
  final String category;
  final bool isSelected;

  CalendarImportConfig({
    this.calendarId,
    required this.providerCalendarId,
    required this.title,
    required this.importSettings,
    required this.color,
    required this.category,
    this.isSelected = false,
  });

  CalendarImportConfig copyWith({
    String? calendarId,
    String? providerCalendarId,
    String? title,
    ImportSettings? importSettings,
    Color? color,
    String? category,
    bool? isSelected,
  }) {
    return CalendarImportConfig(
      calendarId: calendarId ?? this.calendarId,
      providerCalendarId: providerCalendarId ?? this.providerCalendarId,
      title: title ?? this.title,
      importSettings: importSettings ?? this.importSettings,
      color: color ?? this.color,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calendarId': calendarId,
      'providerCalendarId': providerCalendarId,
      'importSettings': importSettings.toJson(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}', // Keep it #RRGGBB
      'category': category,
      'isSelected': isSelected,
    };
  }
}
