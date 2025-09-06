import 'package:flutter/material.dart';

enum CalendarSource { google, outlook, apple }

class Calendar {
  final String id;
  final String userId;
  final CalendarSource source;
  final String providerCalendarId;
  final String email;
  final bool isSelected;
  final bool isPrimary;
  final CalendarMetadata metadata;
  final CalendarPreferences preferences;
  final CalendarSyncInfo sync;
  final List<String> eventCount;

  Calendar({
    required this.id,
    required this.userId,
    required this.source,
    required this.providerCalendarId,
    required this.email,
    required this.isSelected,
    required this.isPrimary,
    required this.metadata,
    required this.preferences,
    required this.sync,
    this.eventCount = const [],
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] ?? '',
      userId: json['user'] ?? '',
      source: _parseSource(json['source']),
      providerCalendarId: json['providerCalendarId'] ?? '',
      email: json['email'] ?? '',
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      metadata: CalendarMetadata.fromJson(json['metadata'] ?? {}),
      preferences: CalendarPreferences.fromJson(json['preferences'] ?? {}),
      sync: CalendarSyncInfo.fromJson(json['sync'] ?? {}),
      eventCount:
          (json['events'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Calendar copyWith({
    String? id,
    String? userId,
    CalendarSource? source,
    String? providerCalendarId,
    String? email,
    bool? isSelected,
    bool? isPrimary,
    CalendarMetadata? metadata,
    CalendarPreferences? preferences,
    CalendarSyncInfo? sync,
    List<String>? eventCount,
  }) {
    return Calendar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      providerCalendarId: providerCalendarId ?? this.providerCalendarId,
      email: email ?? this.email,
      isSelected: isSelected ?? this.isSelected,
      isPrimary: isPrimary ?? this.isPrimary,
      metadata: metadata ?? this.metadata,
      preferences: preferences ?? this.preferences,
      sync: sync ?? this.sync,
      eventCount: eventCount ?? this.eventCount,
    );
  }

  static CalendarSource _parseSource(String source) {
    switch (source.toUpperCase()) {
      case 'GOOGLE':
        return CalendarSource.google;
      case 'OUTLOOK':
        return CalendarSource.outlook;
      case 'APPLE':
        return CalendarSource.apple;
      default:
        return CalendarSource.google; // Default fallback
    }
  }

  Map<String, dynamic> toJson({required email}) {
    return {
      'id': id,
      'user': userId,
      'source': source.name.toUpperCase(),
      'providerCalendarId': providerCalendarId,
      'isSelected': isSelected,
      'isPrimary': isPrimary,
      'metadata': metadata.toJson(),
      'preferences': preferences.toJson(),
      'sync': sync.toJson(),
      'events': eventCount,
    };
  }

  // Helper for legacy API support during migration
  factory Calendar.fromLegacyJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] ?? '',
      userId: json['user'] ?? '',
      source: _parseSource(json['sourceCalendar'] ?? 'Google'),
      providerCalendarId: json['calendarId'] ?? '',
      email: json['email'] ?? '',
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      metadata: CalendarMetadata(
        title: json['title'] ?? '',
        description: json['description'],
        timeZone: json['timeZone'],
        color: _parseColor(json['calendarColor']),
        defaultReminders: (json['defaultReminders'] as List?)
                ?.map((r) => CalendarReminder.fromJson(r))
                .toList() ??
            [],
        notifications: [],
        allowedConferenceTypes: [],
      ),
      preferences: CalendarPreferences(
        importSettings: CalendarImportSettings(
          importAll: json['importAll'] ?? false,
          importSubject: json['importSubject'] ?? false,
          importBody: json['importBody'] ?? false,
          importConferenceInfo: json['importConferenceInfo'] ?? false,
          importOrganizer: json['importOrganizer'] ?? false,
          importRecipients: json['importRecipients'] ?? false,
        ),
        category: json['category'],
        userColor: _parseColor(json['catColor']),
      ),
      sync: CalendarSyncInfo(
        etag: json['etag'],
        syncToken: json['syncToken'],
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.parse(json['lastSyncedAt'])
            : null,
      ),
    );
  }

  factory Calendar.fromGoogleJson(Map<String, dynamic> json) {
    return Calendar(
      id: '', // This will be set by the backend
      userId: '', // This will be set by the backend
      source: CalendarSource.google,
      providerCalendarId: json['id'] ?? '',
      email: '', // This will be set by the backend
      isSelected: json['selected'] ?? true,
      isPrimary: json['primary'] ?? false,
      metadata: CalendarMetadata(
        title: json['summary'] ?? '',
        description: json['description'],
        timeZone: json['timeZone'],
        color: _parseColor(json['backgroundColor']),
        defaultReminders: (json['defaultReminders'] as List?)
                ?.map((r) => CalendarReminder.fromJson(r))
                .toList() ??
            [],
        notifications: [],
        allowedConferenceTypes: [],
      ),
      preferences: CalendarPreferences(
        importSettings: CalendarImportSettings(
          importAll: false,
          importSubject: true,
          importBody: false,
          importConferenceInfo: true,
          importOrganizer: false,
          importRecipients: false,
        ),
        category: null,
        userColor: null,
      ),
      sync: CalendarSyncInfo(
        etag: json['etag'],
        syncToken: null, // This will be set by the backend
        lastSyncedAt: null, // This will be set by the backend
      ),
    );
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
      title: json['title'] ?? '',
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
      'color': '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
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
          ? '#${userColor!.toARGB32().toRadixString(16).padLeft(8, '0')}'
          : null,
    };
  }

  CalendarPreferences copyWith({
    CalendarImportSettings? importSettings,
    String? category,
    Color? userColor,
  }) {
    return CalendarPreferences(
      importSettings: importSettings ?? this.importSettings,
      category: category ?? this.category,
      userColor: userColor ?? this.userColor,
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
          ? DateTime.parse(json['lastSyncedAt'])
          : null,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'])
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
    this.importConferenceInfo = true,
    this.importOrganizer = false,
    this.importRecipients = false,
  });

  factory CalendarImportSettings.fromJson(Map<String, dynamic> json) {
    return CalendarImportSettings(
      importAll: json['importAll'] ?? false,
      importSubject: json['importSubject'] ?? true,
      importBody: json['importBody'] ?? false,
      importConferenceInfo: json['importConferenceInfo'] ?? true,
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

  CalendarImportSettings copyWith({
    bool? importAll,
    bool? importSubject,
    bool? importBody,
    bool? importConferenceInfo,
    bool? importOrganizer,
    bool? importRecipients,
  }) {
    return CalendarImportSettings(
      importAll: importAll ?? this.importAll,
      importSubject: importSubject ?? this.importSubject,
      importBody: importBody ?? this.importBody,
      importConferenceInfo: importConferenceInfo ?? this.importConferenceInfo,
      importOrganizer: importOrganizer ?? this.importOrganizer,
      importRecipients: importRecipients ?? this.importRecipients,
    );
  }
}

enum ReminderMethod { email, popup, sms }

enum NotificationType { eventCreation, eventChange, eventCancellation }

class CalendarPage {
  final List<Calendar> calendars;
  final String? nextPageToken;
  final bool hasMore;
  final String? syncToken;
  final int totalItems;

  CalendarPage({
    required this.calendars,
    this.nextPageToken,
    this.hasMore = false,
    this.syncToken,
    this.totalItems = 0,
  });

  factory CalendarPage.fromJson(Map<String, dynamic> json) {
    return CalendarPage(
      calendars: (json['calendars'] as List)
          .map((json) => Calendar.fromJson(json))
          .toList(),
      nextPageToken: json['nextPageToken'],
      hasMore: json['hasMore'] ?? false,
      syncToken: json['syncToken'],
      totalItems: json['totalItems'] ?? 0,
    );
  }
}

class CalendarDelta {
  final List<Calendar> changes;
  final List<String> deletedCalendarIds;
  final String newSyncToken;
  final bool hasMoreChanges;

  CalendarDelta({
    required this.changes,
    required this.deletedCalendarIds,
    required this.newSyncToken,
    this.hasMoreChanges = false,
  });

  factory CalendarDelta.fromJson(Map<String, dynamic> json) {
    return CalendarDelta(
      changes: (json['changes'] as List)
          .map((json) => Calendar.fromJson(json))
          .toList(),
      deletedCalendarIds: (json['deleted'] as List?)?.cast<String>() ?? [],
      newSyncToken: json['newSyncToken'],
      hasMoreChanges: json['hasMoreChanges'] ?? false,
    );
  }
}
