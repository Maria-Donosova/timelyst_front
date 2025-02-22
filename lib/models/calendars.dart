import 'package:flutter/material.dart';

class Calendar {
  final String user;
  final String? sourceCalendar;
  final String? calendarId;
  final String? kind;
  final String? etag;
  final String? id;
  final String title;
  final String? description;
  final String? timeZone;
  final String? category;
  final Color? catColor;
  final List<dynamic>? defaultReminders;
  final Map<String, dynamic>? notificationSettings;
  final Map<String, dynamic>? conferenceProperties;
  final String? organizer;
  final List<String>? recipients;

  // Add fields for import settings
  bool importAll;
  bool importSubject;
  bool importBody;
  bool importConferenceInfo;
  bool importOrganizer;
  bool importRecipients;

  Calendar({
    required this.user,
    this.kind,
    this.etag,
    this.id,
    required this.title,
    this.calendarId,
    this.description,
    this.sourceCalendar = '',
    this.timeZone = '',
    this.category = '',
    this.catColor = const Color(0xFF000000),
    this.defaultReminders = const [],
    this.notificationSettings = const {},
    this.conferenceProperties = const {},
    this.organizer,
    this.recipients,
    // Initialize import settings
    this.importAll = false,
    this.importSubject = false,
    this.importBody = false,
    this.importConferenceInfo = false,
    this.importOrganizer = false,
    this.importRecipients = false,
  });

  // Convert JSON to Calendar object
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      user: json['user'] ?? '',
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      id: json['id'] ?? '',
      title: json['summary'] ?? '',
      description: json['description'] ?? '',
      sourceCalendar: json['sourceCalendar'] ?? '',
      timeZone: json['timeZone'] ?? '',
      category: json['category'] ?? '',
      catColor: _parseColor(json['catColor']),
      defaultReminders: (json['defaultReminders'] as List<dynamic>?) ?? [],
      notificationSettings:
          (json['notificationSettings'] as Map<String, dynamic>?) ?? {},
      conferenceProperties:
          (json['conferenceProperties'] as Map<String, dynamic>?) ?? {},
      organizer: json['organizer'],
      recipients: (json['recipients'] as List<dynamic>?)?.cast<String>(),
      // Add import settings from JSON (if needed)
      importAll: json['importAll'] ?? false,
      importSubject: json['importSubject'] ?? false,
      importBody: json['importBody'] ?? false,
      importConferenceInfo: json['importConferenceInfo'] ?? false,
      importOrganizer: json['importOrganizer'] ?? false,
      importRecipients: json['importRecipients'] ?? false,
    );
  }

  // Convert Calendar object to JSON
  Map<String, dynamic> toJson({required String email}) {
    return {
      'user': user,
      'kind': kind,
      'etag': etag,
      'id': id,
      'summary': title,
      'description': description,
      'sourceCalendar': _getSourceCalendarFromEmail(email),
      'timeZone': timeZone,
      'category': category,
      'catColor': _colorToHex(catColor),
      'defaultReminders': defaultReminders,
      'notificationSettings': notificationSettings,
      'conferenceProperties': conferenceProperties,

      'organizer': organizer,
      'recipients': recipients,
      // Add ImportSettings fields to JSON
// Add import settings to JSON
      'importAll': importAll,
      'importSubject': importSubject,
      'importBody': importBody,
      'importConferenceInfo': importConferenceInfo,
      'importOrganizer': importOrganizer,
      'importRecipients': importRecipients,
    };
  }

  // Helper functions (unchanged)
  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.transparent;
    }
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String _colorToHex(Color? color) {
    if (color == null) {
      return '#000000';
    }
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  String _getSourceCalendarFromEmail(String email) {
    final lowercaseEmail = email.toLowerCase();

    if (lowercaseEmail.endsWith('@gmail.com')) {
      return 'Google';
    } else if (lowercaseEmail.endsWith('@outlook.com') ||
        lowercaseEmail.endsWith('@hotmail.com') ||
        lowercaseEmail.endsWith('@live.com')) {
      return 'Outlook';
    } else if (lowercaseEmail.endsWith('@icloud.com') ||
        lowercaseEmail.endsWith('@me.com') ||
        lowercaseEmail.endsWith('@mac.com')) {
      return 'Apple';
    } else {
      throw ArgumentError('Unsupported email domain: $email');
    }
  }
}
