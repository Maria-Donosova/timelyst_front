import 'package:flutter/material.dart';

class Calendar {
  final String user;
  final String kind;
  final String etag;
  final String id;
  final String title;
  final String? description;
  final String sourceCalendar;
  final String timeZone;
  final String category;
  final Color? catColor;
  final List<dynamic> defaultReminders; // Updated to List<dynamic>
  final Map<String, dynamic>
      notificationSettings; // Updated to Map<String, dynamic>
  final Map<String, dynamic>
      conferenceProperties; // Updated to Map<String, dynamic>

  Calendar({
    this.user = '',
    required this.kind,
    required this.etag,
    required this.id,
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
      catColor: _parseColor(json['calendarColor']) ?? Colors.grey,
      defaultReminders: (json['defaultReminders'] as List<dynamic>?) ?? [],
      notificationSettings:
          (json['notificationSettings'] as Map<String, dynamic>?) ?? {},
      conferenceProperties:
          (json['conferenceProperties'] as Map<String, dynamic>?) ?? {},
    );
  }

  // Convert Calendar object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'kind': kind,
      'etag': etag,
      'id': id,
      'summary': title,
      'description': description,
      'sourceCalendar': sourceCalendar,
      'timeZone': timeZone,
      'category': category,
      'catColor': catColor,
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
}

// import 'package:flutter/material.dart';

// class Calendar {
//   final String user;
//   final String kind;
//   final String etag;
//   final String id;
//   final String title;
//   final String? description;
//   final String sourceCalendar;
//   final String timeZone;
//   final String category;
//   final Color? catColor;
//   final String? defaultReminders;
//   final String? notificationSettings;
//   final String? conferenceProperties;

//   Calendar({
//     required this.user,
//     required this.kind,
//     required this.etag,
//     required this.id,
//     required this.title,
//     this.description,
//     this.sourceCalendar = '',
//     this.timeZone = '',
//     this.category = '',
//     this.catColor = const Color(0xFF000000),
//     this.defaultReminders = '',
//     this.notificationSettings = '',
//     this.conferenceProperties = '',
//   });

//   // Convert JSON to Calendar object
//   factory Calendar.fromJson(Map<String, dynamic> json) {
//     return Calendar(
//       user: json['user'] ?? '',
//       kind: json['kind'] ?? '',
//       etag: json['etag'] ?? '',
//       id: json['id'] ?? '',
//       title: json['summary'] ?? '',
//       description: json['description'] ?? '',
//       sourceCalendar: json['sourceCalendar'] ?? '',
//       timeZone: json['timeZone'] ?? '',
//       category: json['category'] ?? '',
//       catColor: _parseColor(json['calendarColor']) ?? Colors.grey,
//       defaultReminders: json['defaultReminders'] ?? '',
//       notificationSettings: json['notificationSettings'] ?? '',
//       conferenceProperties: json['conferenceProperties'] ?? '',
//     );
//   }

//   // Convert Calendar object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'user': user,
//       'kind': kind,
//       'etag': etag,
//       'id': id,
//       'summary': title,
//       'description': description,
//       'sourceCalendar': sourceCalendar,
//       'timeZone': timeZone,
//       'category': category,
//       'catColor': catColor,
//       'defaultReminders': defaultReminders,
//       'notificationSettings': notificationSettings,
//       'conferenceProperties': conferenceProperties,
//     };
//   }

// // Helper function to convert hex color string to Color
//   static Color _parseColor(String? hexColor) {
//     if (hexColor == null || hexColor.isEmpty) {
//       return Colors.transparent; // Default color if null or empty
//     }
//     hexColor = hexColor.replaceAll('#', ''); // Remove '#' if present
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor'; // Add opacity if missing
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }
// }
