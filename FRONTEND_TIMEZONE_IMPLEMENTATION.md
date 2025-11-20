# Frontend Timezone Implementation

## Overview

The frontend now properly detects the device's IANA timezone and sends accurate timezone information to the backend. This document explains how timezone data is captured, formatted, and sent.

## Changes Made

### 1. Added `flutter_native_timezone` Package

**File**: `pubspec.yaml`

```yaml
dependencies:
  flutter_native_timezone: ^2.0.0  # Detects device's IANA timezone
  timezone: ^0.10.0                # Timezone database and conversions
```

### 2. Updated Timezone Detection

**File**: `lib/utils/timezoneUtils.dart`

**Key Changes**:
- Uses `FlutterNativeTimezone.getLocalTimezone()` to detect actual device timezone
- Validates detected timezone against IANA timezone database
- Falls back to 'UTC' if detection fails
- Logs timezone detection for debugging

**Example Output**:
```
🌍 [TimezoneUtils] Detected device timezone: America/New_York
✅ [TimezoneUtils] Using timezone: America/New_York
```

### 3. Initialization

**File**: `lib/main.dart` (line 22)

```dart
// Already initialized on app startup
await TimezoneUtils.initialize();
```

This runs once when the app starts, detecting and caching the device timezone.

## Data Format Sent to Backend

### Example: Creating an Event in New York (EST/EDT)

When a user in New York (timezone: "America/New_York", offset: UTC-5 in winter, UTC-4 in summer) creates an event for **November 20, 2024 at 2:30 PM**:

#### GraphQL Mutation

```graphql
mutation CreateTimeEvent($timeEventInput: TimeEventInputData!) {
  createTimeEvent(timeEventInput: $timeEventInput) {
    id
    event_title
    start
    end
    start_timeZone
    end_timeZone
    timeZone
    # ... other fields
  }
}
```

#### Variables Sent

```json
{
  "timeEventInput": {
    "user_id": "user123",
    "event_title": "Team Meeting",
    "start": "2024-11-20T14:30:00.000-05:00",
    "end": "2024-11-20T15:30:00.000-05:00",
    "start_timeZone": "America/New_York",
    "end_timeZone": "America/New_York",
    "timeZone": "America/New_York",
    "is_AllDay": false,
    "source_calendar": "calendar_abc123",
    "category": "Meeting",
    "event_body": "Discuss Q4 goals",
    "event_location": "Conference Room A",
    "event_ConferenceDetails": "https://zoom.us/j/123456",
    "event_attendees": "john@example.com, jane@example.com",
    "reminder": true,
    "holiday": false,
    "recurrenceRule": "",
    "exceptionDates": [],
    "createdBy": "user123",
    "user_calendars": "calendar_abc123"
  }
}
```

### Field Explanations

| Field | Value | Format | Notes |
|-------|-------|--------|-------|
| `start` | `"2024-11-20T14:30:00.000-05:00"` | ISO8601 with offset | ✅ Contains both local time AND timezone offset |
| `end` | `"2024-11-20T15:30:00.000-05:00"` | ISO8601 with offset | ✅ Contains both local time AND timezone offset |
| `start_timeZone` | `"America/New_York"` | IANA timezone name | ✅ NEW: Actual detected timezone (not 'UTC'!) |
| `end_timeZone` | `"America/New_York"` | IANA timezone name | ✅ NEW: Actual detected timezone (not 'UTC'!) |
| `timeZone` | `"America/New_York"` | IANA timezone name | ✅ Legacy field for backward compatibility |

### Before vs After

#### ❌ BEFORE (Incorrect)
```json
{
  "start": "2024-11-20T14:30:00.000-05:00",    // ✅ Correct offset
  "start_timeZone": "UTC",                      // ❌ WRONG! Says UTC but time is in EST
  "end_timeZone": "UTC"                         // ❌ WRONG! Says UTC but time is in EST
}
```
**Problem**: Mismatch between offset (-05:00) and timezone name (UTC)

#### ✅ AFTER (Correct)
```json
{
  "start": "2024-11-20T14:30:00.000-05:00",    // ✅ Correct offset
  "start_timeZone": "America/New_York",         // ✅ CORRECT! Matches the offset
  "end_timeZone": "America/New_York"            // ✅ CORRECT! Matches the offset
}
```
**Solution**: Both offset and timezone name are consistent

## How It Works

### 1. Event Creation Flow

```
User selects: Nov 20, 2024 at 2:30 PM
         ↓
DateTime object created in LOCAL timezone
DateTime(2024, 11, 20, 14, 30)
         ↓
Format to ISO8601 with offset
toIso8601String() → "2024-11-20T14:30:00.000-05:00"
         ↓
Get device timezone name
TimezoneUtils.getDeviceTimeZone() → "America/New_York"
         ↓
Create event data with BOTH pieces
{
  start: "2024-11-20T14:30:00.000-05:00",
  start_timeZone: "America/New_York"
}
         ↓
Send to backend via GraphQL
```

### 2. Code Location

**File**: `lib/widgets/calendar/views/eventDetails.dart`

**Key Section** (lines 437-485):

```dart
// Create DateTime in local timezone
final start = DateTime(
  eventDate.year,
  eventDate.month,
  eventDate.day,
  startTime.hour,
  startTime.minute,
);

// Get device timezone (NOW RETURNS ACTUAL TIMEZONE!)
final deviceTimeZone = TimezoneUtils.getDeviceTimeZone(); // e.g., "America/New_York"

// Prepare event data
final Map<String, dynamic> eventData = {
  'start': _formatDateTimeWithTimezone(start),  // ISO8601 with offset
  'end': _formatDateTimeWithTimezone(end),      // ISO8601 with offset
  'start_timeZone': deviceTimeZone,              // IANA timezone name
  'end_timeZone': deviceTimeZone,                // IANA timezone name
  'timeZone': deviceTimeZone,                    // Legacy field
  // ... other fields
};
```

### 3. Service Layer

**File**: `lib/services/eventsService.dart`

The GraphQL mutation (lines 340-371) sends this data to the backend:

```dart
final response = await _apiClient.post(
  Config.backendGraphqlURL,
  body: {
    'query': mutation,
    'variables': {'timeEventInput': eventData},
  },
);
```

## Platform Support

### Supported Platforms
- ✅ **Android**: Detects timezone via Android APIs
- ✅ **iOS**: Detects timezone via iOS APIs
- ✅ **Web**: Detects timezone via browser JavaScript
- ✅ **Desktop** (Windows/macOS/Linux): Detects system timezone

### Example Timezones Detected

| Location | IANA Timezone | UTC Offset (Winter) | UTC Offset (Summer) |
|----------|---------------|---------------------|---------------------|
| New York | America/New_York | UTC-5 (EST) | UTC-4 (EDT) |
| Los Angeles | America/Los_Angeles | UTC-8 (PST) | UTC-7 (PDT) |
| London | Europe/London | UTC+0 (GMT) | UTC+1 (BST) |
| Tokyo | Asia/Tokyo | UTC+9 (JST) | UTC+9 (JST) |
| Sydney | Australia/Sydney | UTC+11 (AEDT) | UTC+10 (AEST) |

## Debugging

### Check Timezone Detection

Look for these log messages on app startup:

```
🌍 [TimezoneUtils] Detected device timezone: America/New_York
✅ [TimezoneUtils] Using timezone: America/New_York
```

### Check Event Creation

Look for these log messages when creating an event:

```
🕐 [TimezoneUtils] Getting device timezone: America/New_York
```

### Verify Data Sent to Backend

The event service logs the GraphQL request. Check your console for the actual data being sent.

## Benefits

1. ✅ **No More Timezone Mismatch**: Offset and timezone name are consistent
2. ✅ **Accurate Event Times**: Events appear at the correct time for users
3. ✅ **DST Handling**: IANA timezones handle daylight saving transitions automatically
4. ✅ **Multi-Timezone Support**: Different start/end timezones (e.g., flights)
5. ✅ **Calendar Provider Compatibility**: Matches Google/Microsoft timezone format
6. ✅ **Cross-Platform**: Works on all Flutter platforms

## Testing Checklist

To test the timezone implementation:

- [ ] Run `flutter pub get` to install `flutter_native_timezone`
- [ ] Launch the app and check console for timezone detection logs
- [ ] Create a new event at a specific time (e.g., 2:30 PM)
- [ ] Verify the event appears at the same time (not shifted)
- [ ] Check backend database to verify timezone fields are populated
- [ ] Test on different devices/locations if possible
- [ ] Test during DST transition periods (if applicable)

## Next Steps

The frontend is now sending correct timezone data. The backend needs to:

1. ✅ Accept `start_timeZone` and `end_timeZone` in GraphQL schema (already exists)
2. ✅ Store these fields in the database (schema already exists)
3. ❌ Populate these fields when syncing from Google/Microsoft Calendar
4. ❌ Return these fields when querying events

See `BACKEND_TIMEZONE_CHANGES.md` for backend implementation details.

## References

- **flutter_native_timezone**: https://pub.dev/packages/flutter_native_timezone
- **IANA Timezone Database**: https://www.iana.org/time-zones
- **ISO8601 DateTime Format**: https://en.wikipedia.org/wiki/ISO_8601
- **Flutter DateTime API**: https://api.flutter.dev/flutter/dart-core/DateTime-class.html
