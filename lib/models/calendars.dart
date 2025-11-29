import 'package:flutter/material.dart';

enum CalendarSource { LOCAL, GOOGLE, MICROSOFT, APPLE }

class Calendar {
  final String id;
  final String userId;
  final CalendarSource source;
  final String providerCalendarId;
  final CalendarMetadata metadata;
  final CalendarPreferences preferences;
  final CalendarSyncInfo sync;
  final String? syncToken;
  final bool isSelected;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Calendar({
    required this.id,
    required this.userId,
    required this.source,
    required this.providerCalendarId,
    required this.metadata,
    required this.preferences,
    required this.sync,
    this.syncToken,
    required this.isSelected,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      source: _parseSource(json['source']),
      providerCalendarId: json['providerCalendarId'] ?? '',
      metadata: CalendarMetadata.fromJson(json['metadata'] ?? {}),
      preferences: CalendarPreferences.fromJson(json['preferences'] ?? {}),
      sync: CalendarSyncInfo.fromJson(json['sync'] ?? {}),
      syncToken: json['syncToken'],
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static CalendarSource _parseSource(String? source) {
    if (source == null) return CalendarSource.LOCAL;
    
    switch (source.toUpperCase()) {
      case 'GOOGLE':
        return CalendarSource.GOOGLE;
      case 'MICROSOFT':
        return CalendarSource.MICROSOFT;
      case 'APPLE':
        return CalendarSource.APPLE;
      case 'LOCAL':
      default:
        return CalendarSource.LOCAL;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'source': source.name,
      'providerCalendarId': providerCalendarId,
      'metadata': metadata.toJson(),
      'preferences': preferences.toJson(),
      'sync': sync.toJson(),
      'syncToken': syncToken,
      'isSelected': isSelected,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  static Color _parseColor(String? hexColor) {
    hexColor = hexColor?.replaceAll('#', '');
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFA4BDFC);
    }
    return Color(int.parse(hexColor.padLeft(8, 'FF'), radix: 16));
  }
}

class CalendarMetadata {
  final String title;
  final String? description;
  final String? timeZone;
  final Color color;
  final List<CalendarReminder> defaultReminders;
  final List<CalendarNotification> notifications;
  final List<String> allowedConferenceTypes;

  CalendarMetadata({
    required this.title,
    this.description,
    this.timeZone,
    required this.color,
    this.defaultReminders = const [],
    this.notifications = const [],
    this.allowedConferenceTypes = const [],
  });

  factory CalendarMetadata.fromJson(Map<String, dynamic> json) {
    return CalendarMetadata(
      title: json['title'] ?? json['summary'] ?? '',
      description: json['description'],
      timeZone: json['timeZone'],
      color: Calendar._parseColor(json['color']),
      defaultReminders: (json['defaultReminders'] as List?)
              ?.map((r) => CalendarReminder.fromJson(r))
              .toList() ??
          [],
      notifications: (json['notifications'] as List?)
              ?.map((n) => CalendarNotification.fromJson(n))
              .toList() ??
          [],
      allowedConferenceTypes:
          (json['allowedConferenceTypes'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timeZone': timeZone,
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'defaultReminders': defaultReminders.map((r) => r.toJson()).toList(),
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'allowedConferenceTypes': allowedConferenceTypes,
    };
  }
}

class CalendarPreferences {
  late final CalendarImportSettings importSettings;
  final String? category;
  final Color? userColor;

  CalendarPreferences({
    required this.importSettings,
    this.category,
    this.userColor,
  });

  factory CalendarPreferences.fromJson(Map<String, dynamic> json) {
    return CalendarPreferences(
      importSettings:
          CalendarImportSettings.fromJson(json['importSettings'] ?? {}),
      category: json['category'],
      userColor:
          json['color'] != null ? Calendar._parseColor(json['color']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'importSettings': importSettings.toJson(),
      'category': category,
      'color': userColor != null
          ? '#${userColor!.value.toRadixString(16).padLeft(8, '0')}'
          : null,
    };
  }
}

class CalendarSyncInfo {
  final String? etag;
  final String? syncToken;
  final DateTime? lastSyncedAt;
  final DateTime? expiration;

  CalendarSyncInfo({
    this.etag,
    this.syncToken,
    this.lastSyncedAt,
    this.expiration,
  });

  factory CalendarSyncInfo.fromJson(Map<String, dynamic> json) {
    return CalendarSyncInfo(
      etag: json['etag'],
      syncToken: json['syncToken'],
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt']).toLocal()
          : null,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etag': etag,
      'syncToken': syncToken,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'expiration': expiration?.toIso8601String(),
    };
  }
}

class CalendarReminder {
  final ReminderMethod method;
  final int minutes;

  CalendarReminder({
    required this.method,
    required this.minutes,
  });

  factory CalendarReminder.fromJson(Map<String, dynamic> json) {
    return CalendarReminder(
      method: ReminderMethod.values.firstWhere(
        (e) => e.name == (json['method'] as String).toLowerCase(),
        orElse: () => ReminderMethod.email,
      ),
      minutes: json['minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.name.toUpperCase(),
      'minutes': minutes,
    };
  }
}

class CalendarNotification {
  final NotificationType type;
  final ReminderMethod method;

  CalendarNotification({
    required this.type,
    required this.method,
  });

  factory CalendarNotification.fromJson(Map<String, dynamic> json) {
    return CalendarNotification(
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] as String).toLowerCase(),
        orElse: () => NotificationType.eventCreation,
      ),
      method: ReminderMethod.values.firstWhere(
        (e) => e.name == (json['method'] as String).toLowerCase(),
        orElse: () => ReminderMethod.email,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name.toUpperCase(),
      'method': method.name.toUpperCase(),
    };
  }
}

class CalendarImportSettings {
  final bool importAll;
  final bool importSubject;
  final bool importBody;
  final bool importConferenceInfo;
  final bool importOrganizer;
  final bool importRecipients;

  CalendarImportSettings({
    this.importAll = false,
    this.importSubject = true,
    this.importBody = false,
    this.importConferenceInfo = false,
    this.importOrganizer = false,
    this.importRecipients = false,
  });

  factory CalendarImportSettings.fromJson(Map<String, dynamic> json) {
    return CalendarImportSettings(
      importAll: json['importAll'] ?? false,
      importSubject: json['importSubject'] ?? true,
      importBody: json['importBody'] ?? false,
      importConferenceInfo: json['importConferenceInfo'] ?? false,
      importOrganizer: json['importOrganizer'] ?? false,
      importRecipients: json['importRecipients'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'importAll': importAll,
      'importSubject': importSubject,
      'importBody': importBody,
      'importConferenceInfo': importConferenceInfo,
      'importOrganizer': importOrganizer,
      'importRecipients': importRecipients,
    };
  }
}

enum ReminderMethod { email, popup, sms }

enum NotificationType { eventCreation, eventChange, eventCancellation }
