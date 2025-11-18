# Backend Changes Required for Timezone Support

## Overview

The frontend has been updated to implement **Approach 1: Full Timezone Separation**, which treats start and end times as potentially being in different timezones. The backend needs to be updated to properly handle and store timezone information for events.

## Current Backend Issues

Based on the investigation, the backend has the following issues:

1. ❌ **Database fields exist but are not populated**: Both `start_timeZone` and `end_timeZone` fields exist in database models but are never populated
2. ❌ **Only single timezone captured**: During event synchronization, only a single `timeZone` field is extracted from `event.start.timeZone`
3. ❌ **No timezone conversion**: Events are stored with original datetime strings using `new Date()` without timezone conversion
4. ❌ **End timezone lost**: If an event has different start and end timezones, the end timezone is not captured
5. 📦 **Unused library**: `moment-timezone` is installed but never used

## Required Backend Changes

### 1. Update GraphQL Schema

**File**: `schema/` (GraphQL schema definitions)

Add `start_timeZone` and `end_timeZone` fields to both `TimeEventInputData` and `DayEventInputData` input types:

```graphql
# Time Event Input Type
input TimeEventInputData {
  user_id: String!
  createdBy: String
  user_calendars: String
  source_calendar: String
  event_organizer: String
  event_title: String!
  start: String!              # ISO8601 with timezone offset (e.g., "2024-11-18T14:30:00-05:00")
  end: String!                # ISO8601 with timezone offset (e.g., "2024-11-18T15:30:00-05:00")
  start_timeZone: String      # NEW: IANA timezone (e.g., "America/New_York")
  end_timeZone: String        # NEW: IANA timezone (e.g., "America/New_York")
  timeZone: String            # LEGACY: Keep for backward compatibility
  is_AllDay: Boolean
  recurrenceRule: String
  recurrenceId: String
  exceptionDates: [String]
  time_EventInstance: [String]
  category: String
  event_body: String
  event_location: String
  event_ConferenceDetails: String
  event_attendees: String
  reminder: Boolean
  holiday: Boolean
}

# Day Event Input Type
input DayEventInputData {
  user_id: String!
  createdBy: String
  user_calendars: String
  source_calendar: String
  event_organizer: String
  event_title: String!
  start: String!              # ISO8601 with timezone offset
  end: String!                # ISO8601 with timezone offset
  start_timeZone: String      # NEW: IANA timezone
  end_timeZone: String        # NEW: IANA timezone
  timeZone: String            # LEGACY: Keep for backward compatibility
  is_AllDay: Boolean
  recurrenceRule: String
  recurrenceId: String
  exceptionDates: [String]
  day_EventInstance: String
  category: String
  event_body: String
  event_location: String
  event_ConferenceDetails: String
  event_attendees: String
  reminder: Boolean
  holiday: Boolean
}
```

### 2. Update Google Calendar Service

**File**: `services/googleService.js` (around line 1026)

**Current Code**:
```javascript
// ❌ PROBLEM: Only captures start timezone
const timeEventInput = {
  start: event.start.dateTime,
  end: event.end.dateTime,
  timeZone: event.start.timeZone,  // Only start timezone!
  // ... other fields
};
```

**Updated Code**:
```javascript
// ✅ SOLUTION: Capture both start and end timezones
const timeEventInput = {
  start: event.start.dateTime,           // Already has timezone offset
  end: event.end.dateTime,               // Already has timezone offset
  start_timeZone: event.start.timeZone,  // NEW: Start timezone (IANA format)
  end_timeZone: event.end.timeZone,      // NEW: End timezone (IANA format)
  timeZone: event.start.timeZone,        // LEGACY: Keep for backward compat
  // ... other fields
};
```

**Important Notes**:
- Google Calendar API provides `event.start.timeZone` and `event.end.timeZone` in IANA format (e.g., "America/New_York")
- The `dateTime` fields from Google Calendar already include timezone offset (e.g., "2024-11-18T14:30:00-05:00")
- For all-day events, Google uses `event.start.date` (just the date, no time)

### 3. Update Microsoft Calendar Service

**File**: `services/microsoftService.js` (around line 980)

**Current Code**:
```javascript
// ❌ PROBLEM: Only captures start timezone
const timeEventInput = {
  start: event.start.dateTime,
  end: event.end.dateTime,
  timeZone: event.start.timeZone,  // Only start timezone!
  // ... other fields
};
```

**Updated Code**:
```javascript
// ✅ SOLUTION: Capture both start and end timezones
const timeEventInput = {
  start: event.start.dateTime,           // Already has timezone offset
  end: event.end.dateTime,               // Already has timezone offset
  start_timeZone: convertWindowsToIANA(event.start.timeZone),  // NEW: Convert Windows to IANA
  end_timeZone: convertWindowsToIANA(event.end.timeZone),      // NEW: Convert Windows to IANA
  timeZone: convertWindowsToIANA(event.start.timeZone),        // LEGACY: Keep for backward compat
  // ... other fields
};
```

**Important Notes**:
- Microsoft Graph API provides timezones in Windows format (e.g., "Eastern Standard Time")
- Use the existing `utils/timezoneConverter.js` to convert Windows format to IANA format
- The converter already handles this conversion when sending events TO Microsoft

### 4. Update Database Models

**Files**:
- `models/timeEventIns.js` (lines 88-95)
- `models/dayEventIns.js` (lines 88-95)

**Current Code**:
```javascript
// ❌ PROBLEM: Fields exist but are never populated
const timeEventSchema = new Schema({
  // ... other fields
  start: { type: String, required: true },
  end: { type: String, required: true },
  start_timeZone: { type: String },      // Exists but unused!
  end_timeZone: { type: String },        // Exists but unused!
  timeZone: { type: String },
  // ... other fields
});
```

**No changes needed to schema**, but ensure these fields are populated when creating/updating events.

### 5. Add Timezone Validation (Optional but Recommended)

Create a new utility function to validate IANA timezone names:

**File**: `utils/timezoneValidator.js` (NEW FILE)

```javascript
const moment = require('moment-timezone');

/**
 * Validates if a string is a valid IANA timezone name
 * @param {string} timeZone - Timezone name to validate
 * @returns {boolean} - True if valid, false otherwise
 */
function isValidIANATimezone(timeZone) {
  if (!timeZone || typeof timeZone !== 'string') {
    return false;
  }

  return moment.tz.names().includes(timeZone);
}

/**
 * Gets a safe timezone or falls back to UTC
 * @param {string} timeZone - Timezone name
 * @returns {string} - Valid timezone or 'UTC'
 */
function getSafeTimezone(timeZone) {
  return isValidIANATimezone(timeZone) ? timeZone : 'UTC';
}

module.exports = {
  isValidIANATimezone,
  getSafeTimezone,
};
```

### 6. Update Event Creation/Update Resolvers

**Files**: GraphQL resolvers for `createTimeEvent`, `updateTimeEvent`, `createDayEvent`, `updateDayEvent`

Ensure the resolvers properly handle and store the new timezone fields:

```javascript
// Example for createTimeEvent resolver
createTimeEvent: async (_, { timeEventInput }, context) => {
  // Validate timezone fields if provided
  if (timeEventInput.start_timeZone && !isValidIANATimezone(timeEventInput.start_timeZone)) {
    throw new Error(`Invalid start timezone: ${timeEventInput.start_timeZone}`);
  }

  if (timeEventInput.end_timeZone && !isValidIANATimezone(timeEventInput.end_timeZone)) {
    throw new Error(`Invalid end timezone: ${timeEventInput.end_timeZone}`);
  }

  // If start_timeZone and end_timeZone are not provided, use timeZone as fallback
  const eventData = {
    ...timeEventInput,
    start_timeZone: timeEventInput.start_timeZone || timeEventInput.timeZone || 'UTC',
    end_timeZone: timeEventInput.end_timeZone || timeEventInput.timeZone || 'UTC',
  };

  // Create the event with timezone fields populated
  const newEvent = new TimeEventIns(eventData);
  return await newEvent.save();
}
```

## Data Format Examples

### Frontend Sends (After Changes):

```json
{
  "event_title": "Team Meeting",
  "start": "2024-11-18T14:30:00.000-05:00",      // ISO8601 WITH timezone offset
  "end": "2024-11-18T15:30:00.000-05:00",        // ISO8601 WITH timezone offset
  "start_timeZone": "America/New_York",           // IANA timezone
  "end_timeZone": "America/New_York",             // IANA timezone
  "timeZone": "America/New_York",                 // Legacy field (same as start_timeZone)
  "is_AllDay": false
}
```

### Google Calendar Provides:

```json
{
  "summary": "Team Meeting",
  "start": {
    "dateTime": "2024-11-18T14:30:00-05:00",
    "timeZone": "America/New_York"
  },
  "end": {
    "dateTime": "2024-11-18T15:30:00-05:00",
    "timeZone": "America/New_York"
  }
}
```

### Microsoft Calendar Provides:

```json
{
  "subject": "Team Meeting",
  "start": {
    "dateTime": "2024-11-18T14:30:00",
    "timeZone": "Eastern Standard Time"          // Windows timezone format!
  },
  "end": {
    "dateTime": "2024-11-18T15:30:00",
    "timeZone": "Eastern Standard Time"
  }
}
```

### Backend Should Store:

```javascript
{
  event_title: "Team Meeting",
  start: "2024-11-18T14:30:00.000-05:00",        // ISO8601 with offset
  end: "2024-11-18T15:30:00.000-05:00",          // ISO8601 with offset
  start_timeZone: "America/New_York",             // IANA format
  end_timeZone: "America/New_York",               // IANA format
  timeZone: "America/New_York",                   // Legacy field
  is_AllDay: false
}
```

## Migration Strategy

For existing events in the database that don't have timezone fields populated:

1. **Option 1: Migration Script**
   ```javascript
   // Migrate existing events to populate timezone fields
   const events = await TimeEventIns.find({
     start_timeZone: { $in: [null, ''] }
   });

   for (const event of events) {
     event.start_timeZone = event.timeZone || 'UTC';
     event.end_timeZone = event.timeZone || 'UTC';
     await event.save();
   }
   ```

2. **Option 2: On-the-fly Population**
   - When querying events, check if `start_timeZone` is empty
   - If empty, populate it from `timeZone` field or default to 'UTC'
   - Return the event with populated timezone fields

## Testing Checklist

- [ ] Create a new event from the frontend - verify `start_timeZone` and `end_timeZone` are stored
- [ ] Update an existing event - verify timezone fields are preserved
- [ ] Sync events from Google Calendar - verify both timezones are captured
- [ ] Sync events from Microsoft Calendar - verify Windows→IANA conversion works
- [ ] Create all-day event - verify timezone fields are still populated
- [ ] Query events from frontend - verify timezone fields are returned
- [ ] Test event in different timezones (e.g., PST user creates event, EST user views it)
- [ ] Test recurring events with timezone
- [ ] Test events spanning DST transition

## Benefits of This Approach

1. ✅ **Accurate Time Representation**: Preserves exact time with timezone offset
2. ✅ **Multi-Timezone Support**: Handles events with different start/end timezones (e.g., flights, virtual meetings)
3. ✅ **Google/Microsoft Compatibility**: Matches how calendar providers handle timezones
4. ✅ **Backward Compatible**: Keeps legacy `timeZone` field for older clients
5. ✅ **DST Handling**: IANA timezones automatically handle daylight saving transitions
6. ✅ **Database Ready**: Leverages existing database schema fields

## Frontend Timezone Detection Note

**Current Implementation**: The frontend currently defaults to 'UTC' as the IANA timezone name. The DateTime objects still include the correct timezone offset (e.g., "-05:00"), so times are preserved accurately, but the timezone name sent to the backend is 'UTC'.

**For Production**: Consider adding `flutter_native_timezone` package to get the actual device IANA timezone (e.g., "America/New_York"). Alternatively, for web apps, you can detect the timezone from the browser using JavaScript:

```dart
import 'dart:html' as html;

String getBrowserTimezone() {
  try {
    // This works in web browsers
    return html.window.navigator.timeZone ?? 'UTC';
  } catch (e) {
    return 'UTC';
  }
}
```

## References

- **IANA Timezone Database**: https://www.iana.org/time-zones
- **Google Calendar API Timezone Handling**: https://developers.google.com/calendar/api/guides/create-events#timezone
- **Microsoft Graph API Timezones**: https://learn.microsoft.com/en-us/graph/api/resources/datetimetimezone
- **Moment Timezone Documentation**: https://momentjs.com/timezone/docs/
