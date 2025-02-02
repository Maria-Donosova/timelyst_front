import 'package:flutter/material.dart';

class ImportSettings {
  bool all;
  bool subject;
  bool body;
  bool attachments;
  bool conferenceInfo;
  bool organizer;
  bool recipients;

  ImportSettings({
    this.all = false,
    this.subject = false,
    this.body = false,
    this.attachments = false,
    this.conferenceInfo = false,
    this.organizer = false,
    this.recipients = false,
  });
}

class Calendar {
  final String user;
  final String? kind;
  final String? etag;
  final String? id;
  final String title;
  final String? description;
  final String? sourceCalendar;
  final String? timeZone;
  final String? category;
  final Color? catColor;
  final List<dynamic>? defaultReminders; // Updated to List<dynamic>
  final Map<String, dynamic>?
      notificationSettings; // Updated to Map<String, dynamic>
  final Map<String, dynamic>?
      conferenceProperties; // Updated to Map<String, dynamic>

  Calendar({
    required this.user,
    this.kind,
    this.etag,
    this.id,
    required this.title,
    this.description,
    this.sourceCalendar = '',
    this.timeZone = '',
    this.category = '',
    this.catColor = const Color(0xFF000000),
    this.defaultReminders = const [], // Default empty list
    this.notificationSettings = const {}, // Default empty map
    this.conferenceProperties = const {}, // Default empty map
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
    };
  }

  // Helper function to convert hex color string to Color
  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.transparent; // Default color if null or empty
    }
    hexColor = hexColor.replaceAll('#', ''); // Remove '#' if present
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if missing
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Helper function to convert Color to hex string
  static String _colorToHex(Color? color) {
    if (color == null) {
      return '#000000'; // Default color if null
    }
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  // Helper function to identify the source calendar
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
