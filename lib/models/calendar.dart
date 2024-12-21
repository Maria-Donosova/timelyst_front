import 'dart:ui';

class Calendar {
  final String etag;
  final String id;
  final String title;
  final String description;
  final String timeZone;
  final String category;
  final Color catColor;
  final String defaultReminders;
  final String notificationSettings;
  final String conferenceProperties;

  Calendar({
    required this.etag,
    required this.id,
    required this.title,
    required this.description,
    this.timeZone = '',
    this.category = '',
    this.catColor = const Color(0xFF000000),
    this.defaultReminders = '',
    this.notificationSettings = '',
    this.conferenceProperties = '',
  });

  // Convert JSON to Calendar object
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      etag: json['etag'],
      id: json['id'],
      title: json['summary'],
      description: json['description'],
      timeZone: json['timeZone'],
      category: json['category'],
      catColor: json['catColor'],
      defaultReminders: json['defaultReminders'],
      notificationSettings: json['notificationSettings'],
      conferenceProperties: json['conferenceProperties'],
    );
  }

  // Convert Calendar object to JSON
  Map<String, dynamic> toJson() {
    return {
      'etag': etag,
      'id': id,
      'summary': title,
      'description': description,
      'timeZone': timeZone,
      'category': category,
      'catColor': catColor,
      'defaultReminders': defaultReminders,
      'notificationSettings': notificationSettings,
      'conferenceProperties': conferenceProperties,
    };
  }
}
