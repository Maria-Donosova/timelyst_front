import 'package:flutter/material.dart';

enum CalendarSource { google, outlook, apple }

class Calendar {
  final String id;
  final String userId;
  final CalendarSource source;
  final String providerCalendarId;
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
      isSelected: json['isSelected'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      metadata: CalendarMetadata.fromJson(json['metadata'] ?? {}),
      preferences: CalendarPreferences.fromJson(json['preferences'] ?? {}),
      sync: CalendarSyncInfo.fromJson(json['sync'] ?? {}),
      eventCount:
          (json['events'] as List?)?.map((e) => e.toString()).toList() ?? [],
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

  Map<String, dynamic> toJson() {
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
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'defaultReminders': defaultReminders.map((r) => r.toJson()).toList(),
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'allowedConferenceTypes': allowedConferenceTypes,
    };
  }
}

class CalendarPreferences {
  final CalendarImportSettings importSettings;
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
}

enum ReminderMethod { email, popup, sms }

enum NotificationType { eventCreation, eventChange, eventCancellation }

// import 'package:flutter/material.dart';

// class Calendar {
//   final String user;
//   final String? sourceCalendar;
//   final String? calendarId;
//   final String? kind;
//   final String? etag;
//   final String? id;
//   final String title;
//   final String? description;
//   final String? timeZone;
//   final String? category;
//   final Color? catColor; // Directly use Color object
//   final List<Map<String, dynamic>>? defaultReminders;
//   final Map<String, dynamic>? notificationSettings;
//   final Map<String, dynamic>? conferenceProperties;
//   final String? organizer;
//   final List<String>? recipients;

//   // Import settings
//   bool importAll;
//   bool importSubject;
//   bool importBody;
//   bool importConferenceInfo;
//   bool importOrganizer;
//   bool importRecipients;

//   Calendar({
//     required this.user,
//     this.kind,
//     this.etag,
//     this.id,
//     required this.title,
//     this.calendarId,
//     this.description,
//     this.sourceCalendar = '',
//     this.timeZone = '',
//     this.category = '',
//     this.catColor = const Color(0xFFA4BDFC), // Default color
//     this.defaultReminders = const [],
//     this.notificationSettings = const {},
//     this.conferenceProperties = const {},
//     this.organizer,
//     this.recipients,
//     this.importAll = false,
//     this.importSubject = false,
//     this.importBody = false,
//     this.importConferenceInfo = false,
//     this.importOrganizer = false,
//     this.importRecipients = false,
//     required int color,
//     required bool isDefault,
//     required bool isPrimary,
//     required String type,
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
//       catColor:
//           _parseColor(json['catColor']), // Deserialize hex string to Color
//       defaultReminders: (json['defaultReminders'] as List<dynamic>?)
//               ?.cast<Map<String, dynamic>>() ??
//           [],
//       notificationSettings:
//           (json['notificationSettings'] as Map<String, dynamic>?) ?? {},
//       conferenceProperties:
//           (json['conferenceProperties'] as Map<String, dynamic>?) ?? {},
//       organizer: json['organizer'],
//       recipients: (json['recipients'] as List<dynamic>?)?.cast<String>(),
//       importAll: json['importAll'] ?? false,
//       importSubject: json['importSubject'] ?? false,
//       importBody: json['importBody'] ?? false,
//       importConferenceInfo: json['importConferenceInfo'] ?? false,
//       importOrganizer: json['importOrganizer'] ?? false,
//       importRecipients: json['importRecipients'] ?? false, color: 0xFFA4BDFC,
//       isDefault: false, isPrimary: false, type: '',
//     );
//   }

//   // Convert Calendar object to JSON
//   Map<String, dynamic> toJson({required String email}) {
//     return {
//       'user': user,
//       'kind': kind,
//       'etag': etag,
//       'id': id,
//       'summary': title,
//       'description': description,
//       'sourceCalendar': _getSourceCalendarFromEmail(email),
//       'timeZone': timeZone,
//       'category': category,
//       'catColor': _colorToHex(catColor), // Serialize Color to hex string
//       'defaultReminders': defaultReminders,
//       'notificationSettings': notificationSettings,
//       'conferenceProperties': conferenceProperties,
//       'organizer': organizer,
//       'recipients': recipients,
//       'importAll': importAll,
//       'importSubject': importSubject,
//       'importBody': importBody,
//       'importConferenceInfo': importConferenceInfo,
//       'importOrganizer': importOrganizer,
//       'importRecipients': importRecipients,
//     };
//   }

//   // Helper function to convert hex string to Color
//   static Color _parseColor(String? hexColor) {
//     if (hexColor == null || hexColor.isEmpty) {
//       return const Color(0xFFA4BDFC); // Default color
//     }
//     hexColor = hexColor.replaceAll('#', '');
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor'; // Add opacity if missing
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }

//   // Helper function to convert Color to hex string
//   static String _colorToHex(Color? color) {
//     if (color == null) {
//       return '#A4BDFC'; // Default color
//     }
//     return '#${color.value.toRadixString(16).padLeft(8, '0')}';
//   }

//   // Helper function to identify the source calendar
//   String _getSourceCalendarFromEmail(String email) {
//     final lowercaseEmail = email.toLowerCase();
//     if (lowercaseEmail.endsWith('@gmail.com')) {
//       return 'Google';
//     } else if (lowercaseEmail.endsWith('@outlook.com') ||
//         lowercaseEmail.endsWith('@hotmail.com') ||
//         lowercaseEmail.endsWith('@live.com')) {
//       return 'Outlook';
//     } else if (lowercaseEmail.endsWith('@icloud.com') ||
//         lowercaseEmail.endsWith('@me.com') ||
//         lowercaseEmail.endsWith('@mac.com')) {
//       return 'Apple';
//     } else {
//       throw ArgumentError('Unsupported email domain: $email');
//     }
//   }
// }
