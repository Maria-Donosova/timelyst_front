import 'package:flutter/material.dart';
import 'import_settings.dart';
import 'calendar_import_config.dart';

/// Safe date parsing helper - handles null, empty, and invalid date strings
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  if (str.isEmpty) return null;
  try {
    return DateTime.parse(str);
  } catch (e) {
    return null;
  }
}

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    // Backend may return flat structure (name, color, etc. at top level)
    // or nested structure (metadata: {title, color, ...})
    // If no nested 'metadata' object exists, use the json itself for metadata fields
    final metadataSource = json['metadata'] is Map<String, dynamic> 
        ? json['metadata'] as Map<String, dynamic>
        : json; // Use top-level json when metadata is not nested
    
    return Calendar(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      source: _parseSource(json['source'] ?? json['provider']),
      providerCalendarId: json['providerCalendarId'] ?? '',
      metadata: CalendarMetadata.fromJson(metadataSource),
      preferences: CalendarPreferences.fromJson(
          json['preferences'] is Map<String, dynamic>
              ? json['preferences']
              : {}),
      sync: CalendarSyncInfo.fromJson(
          json['sync'] is Map<String, dynamic> ? json['sync'] : {}),
      syncToken: json['syncToken'],
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  factory Calendar.fromAppleJson(Map<String, dynamic> json) {
    // Same flat/nested handling as fromJson
    final metadataSource = json['metadata'] is Map<String, dynamic> 
        ? json['metadata'] as Map<String, dynamic>
        : json;
    
    return Calendar(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      source: CalendarSource.APPLE,
      providerCalendarId: json['providerCalendarId'] ?? '',
      metadata: CalendarMetadata.fromJson(metadataSource),
      preferences: CalendarPreferences.fromJson(
          json['preferences'] is Map<String, dynamic>
              ? json['preferences']
              : {}),
      sync: CalendarSyncInfo.fromJson(
          json['sync'] is Map<String, dynamic> ? json['sync'] : {}),
      syncToken: json['syncToken'],
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }
  
  static Color _parseColor(String? hexColor) {
    hexColor = hexColor?.replaceAll('#', '');
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFA4BDFC);
    }
    return Color(int.parse(hexColor.padLeft(8, 'FF'), radix: 16));
  }

  Calendar copyWith({
    String? id,
    String? userId,
    CalendarSource? source,
    String? providerCalendarId,
    CalendarMetadata? metadata,
    CalendarPreferences? preferences,
    CalendarSyncInfo? sync,
    String? syncToken,
    bool? isSelected,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      providerCalendarId: providerCalendarId ?? this.providerCalendarId,
      metadata: metadata ?? this.metadata,
      preferences: preferences ?? this.preferences,
      sync: sync ?? this.sync,
      syncToken: syncToken ?? this.syncToken,
      isSelected: isSelected ?? this.isSelected,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarMetadata {
  final String? title;
  final String? color;
  final String? timeZone;
  final String? description;
  final String? category;

  CalendarMetadata({
    this.title,
    this.color,
    this.timeZone,
    this.description,
    this.category,
  });

  factory CalendarMetadata.fromJson(Map<String, dynamic> json) {
    return CalendarMetadata(
      // Backend may return 'name' instead of 'title' for calendar names
      title: json['title'] ?? json['name'] ?? json['summary'],
      color: json['color'] ?? json['backgroundColor'],
      timeZone: json['timeZone'],
      description: json['description'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color,
      'timeZone': timeZone,
      'description': description,
      'category': category,
    };
  }
  
  CalendarMetadata copyWith({
    String? title,
    String? color,
    String? timeZone,
    String? description,
    String? category,
  }) {
    return CalendarMetadata(
      title: title ?? this.title,
      color: color ?? this.color,
      timeZone: timeZone ?? this.timeZone,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  Color get parsedColor {
    var hexColor = color?.replaceAll('#', '');
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFA4BDFC);
    }
    try {
      return Color(int.parse(hexColor.padLeft(8, 'FF'), radix: 16));
    } catch (e) {
      return const Color(0xFFA4BDFC);
    }
  }
}

class CalendarPreferences {
  late final ImportSettings importSettings;
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
          ImportSettings.fromJson(json['importSettings'] ?? {}),
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
          ? '#${userColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
    };
  }

  CalendarPreferences copyWith({
    ImportSettings? importSettings,
    String? category,
    bool clearCategory = false,
    Color? userColor,
  }) {
    return CalendarPreferences(
      importSettings: importSettings ?? this.importSettings,
      category: clearCategory ? null : (category ?? this.category),
      userColor: userColor ?? this.userColor,
    );
  }
}

class UpdatePreferencesResponse {
  final bool syncTriggered;
  final CalendarPreferences? preferences;

  UpdatePreferencesResponse({
    required this.syncTriggered,
    this.preferences,
  });

  factory UpdatePreferencesResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePreferencesResponse(
      syncTriggered: json['syncTriggered'] ?? false,
      preferences: json['preferences'] != null
          ? CalendarPreferences.fromJson(json['preferences'])
          : null,
    );
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
      'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
      'expiration': expiration?.toUtc().toIso8601String(),
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

// Removed old CalendarImportSettings class as it's replaced by ImportSettings model

enum ReminderMethod { email, popup, sms }

enum NotificationType { eventCreation, eventChange, eventCancellation }
