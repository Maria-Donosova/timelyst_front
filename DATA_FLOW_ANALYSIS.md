# Complete Data Flow Analysis: Event Creation to Display

This document traces the complete flow of datetime data from when a user picks a time to when the event is displayed back on the calendar.

## Purpose

To identify **exactly where** the time jumping issue occurs by logging every transformation of the datetime data.

## Data Flow Diagram

```
User Picks Time (UI)
        ↓
[1] EventDetails Widget - Creates DateTime object
        ↓
[2] EventDetails Widget - Formats to ISO8601 string
        ↓
[3] EventService - Sends GraphQL mutation to backend
        ↓
[4] Backend (processes and stores)
        ↓
[5] EventService - Receives response from backend
        ↓
[6] TimeEvent Model - Parses JSON from backend
        ↓
[7] DateTimeUtils - Converts string to DateTime
        ↓
[8] EventMapper - Creates CustomAppointment
        ↓
Calendar Widget - Displays event
```

## Log Points with Expected Output

### [1] EventDetails: User Input Capture

**File**: `lib/widgets/calendar/views/eventDetails.dart` (lines 453-465)

**Logs**:
```
📅 [EventDetails] User picked times:
  - Date: 2024-11-21 00:00:00.000
  - Start time: 14:30
  - End time: 15:30
  - Created DateTime objects:
    - start: 2024-11-21 14:30:00.000
    - end: 2024-11-21 15:30:00.000
    - start.timeZoneName: EST (or PST, etc.)
    - start.timeZoneOffset: -5:00:00.000000
  - deviceTimeZone: America/New_York
```

**What to Check**:
- `start.timeZoneName` should match your location (EST, PST, etc.)
- `start.timeZoneOffset` should match your timezone offset
- `deviceTimeZone` should be an IANA timezone (NOT 'UTC')

---

### [2] EventDetails: Formatting for Backend

**File**: `lib/widgets/calendar/views/eventDetails.dart` (lines 471-488)

**Logs**:
```
📤 [EventDetails] Formatting for backend:
  - start formatted: 2024-11-21T14:30:00.000-05:00
  - end formatted: 2024-11-21T15:30:00.000-05:00
  - start_timeZone: America/New_York
  - end_timeZone: America/New_York
📦 [EventDetails] Complete eventData being sent to service:
  {...full event data map...}
```

**What to Check**:
- `start formatted` should have timezone offset (e.g., `-05:00`, `-08:00`)
- `start_timeZone` should be IANA timezone (e.g., `America/New_York`)
- Both the offset in the ISO string and the timezone name should be consistent

**Example of CORRECT data**:
- start: `2024-11-21T14:30:00.000-05:00` (has `-05:00` offset)
- start_timeZone: `America/New_York` (EST is UTC-5)
- ✅ CONSISTENT!

**Example of INCORRECT data**:
- start: `2024-11-21T14:30:00.000-05:00` (has `-05:00` offset)
- start_timeZone: `UTC` (UTC is UTC+0)
- ❌ MISMATCH! This will cause time jumping

---

### [3] EventService: Sending to Backend

**File**: `lib/services/eventsService.dart` (lines 323-404)

**Logs**:
```
📨 [EventService.createTimeEvent] Entering createTimeEvent
📨 [EventService.createTimeEvent] TimeEventInput received:
  - start: 2024-11-21T14:30:00.000-05:00
  - end: 2024-11-21T15:30:00.000-05:00
  - start_timeZone: America/New_York
  - end_timeZone: America/New_York
  - timeZone: America/New_York
  - Full input: {...}
📡 [EventService.createTimeEvent] Sending to backend:
  - URL: https://your-backend-url/graphql
  - Variables: {timeEventInput: {...}}
```

**What to Check**:
- This is the LAST point before data leaves the frontend
- Verify the exact values being sent to backend
- All timezone fields should have correct values

---

### [4] Backend Processing

**⚠️ THIS HAPPENS ON THE BACKEND - NOT VISIBLE IN FRONTEND LOGS**

The backend receives the GraphQL mutation with:
```json
{
  "start": "2024-11-21T14:30:00.000-05:00",
  "end": "2024-11-21T15:30:00.000-05:00",
  "start_timeZone": "America/New_York",
  "end_timeZone": "America/New_York",
  "timeZone": "America/New_York"
}
```

**Possible Backend Issues**:
1. Backend might ignore timezone offset and parse as UTC
2. Backend might ignore timezone name fields
3. Backend might convert to UTC and lose original time
4. Backend might store as Unix timestamp without timezone
5. Backend might use `new Date()` which can shift times

**To investigate backend, check**:
- How the backend parses the `start` field
- What gets stored in the database
- Whether timezone fields are saved

---

### [5] EventService: Response from Backend

**File**: `lib/services/eventsService.dart` (lines 474-495)

**Logs**:
```
📥 [EventService.createTimeEvent] Response from backend:
  - start: ??? (this is the key value to check!)
  - end: ???
  - start_timeZone: ???
  - end_timeZone: ???
  - timeZone: ???
✅ [EventService.createTimeEvent] Time event created successfully: abc123
  - timeEvent.start: ???
  - timeEvent.end: ???
  - timeEvent.startTimeZone: ???
  - timeEvent.endTimeZone: ???
```

**What to Check**:
- **CRITICAL**: What format is `start` in the response?
  - Is it the same ISO string we sent? `2024-11-21T14:30:00.000-05:00` ✅
  - Did it get converted to UTC? `2024-11-21T19:30:00.000Z` ❌
  - Is it a Unix timestamp? `1732209000000` ❌
  - Did the time change? `2024-11-21T09:30:00.000-05:00` ❌

**Common Backend Issues**:

| Backend Sends | What It Means | Effect |
|---------------|---------------|---------|
| `2024-11-21T14:30:00.000-05:00` | Preserved original | ✅ Correct! |
| `2024-11-21T19:30:00.000Z` | Converted to UTC | ❌ Will display wrong time |
| `1732209000000` | Unix timestamp (UTC) | ❌ Might shift time |
| `2024-11-21T14:30:00` | No timezone info | ⚠️ Ambiguous, might cause issues |

---

### [6] TimeEvent Model: Parsing Backend Data

**File**: `lib/models/timeEvent.dart` (lines 114-178)

**Logs**:
```
🔍 [TimeEvent.fromJson] Parsing JSON for event: Team Meeting
  - RAW start from backend: 2024-11-21T14:30:00.000-05:00 (type: String)
  - RAW end from backend: 2024-11-21T15:30:00.000-05:00 (type: String)
  - start_timeZone: "America/New_York"
  - end_timeZone: "America/New_York"
  - timeZone: "America/New_York"
🔄 [TimeEvent._parseStartEnd] Parsing value: 2024-11-21T14:30:00.000-05:00 (type: String)
  ✅ Value is already a string: 2024-11-21T14:30:00.000-05:00
```

**What to Check**:
- Type of `start` value (String, int, or something else?)
- If it's a string, does it have timezone info?
- Does `_parseStartEnd` modify the value?

---

### [7] DateTimeUtils: String to DateTime Conversion

**File**: `lib/utils/dateUtils.dart` (lines 6-51)

**Logs**:
```
🔍 [DateTimeUtils.parseAnyFormat] Parsing: 2024-11-21T14:30:00.000-05:00 (type: String)
  - Parsed ISO string: 2024-11-21 14:30:00.000-0500
  - parsedDate.isUtc: false
  ✅ Has timezone info, converted to local: 2024-11-21 14:30:00.000
    - result.timeZoneName: EST
    - result.timeZoneOffset: -5:00:00.000000
```

**What to Check**:
- **CRITICAL**: Does `converted to local` change the time?
  - Sent: `2024-11-21T14:30:00.000-05:00` (2:30 PM EST)
  - Parsed: `2024-11-21 14:30:00.000` (should still be 2:30 PM)
  - If parsed shows different hour → **FOUND THE BUG!**

**Common Issue**:
If backend sends `2024-11-21T19:30:00.000Z` (UTC):
- Frontend converts to local: `2024-11-21 14:30:00.000 EST`
- But user created event at 2:30 PM, not 7:30 PM!
- Event appears correct BUT backend has wrong time stored

---

### [8] EventMapper: Creating Display Object

**File**: `lib/utils/eventsMapper.dart` (lines 83-103)

**Logs**:
```
🗺️ [EventMapper] Mapping TimeEvent to CustomAppointment:
  - Event: Team Meeting
  - timeEvent.start: 2024-11-21T14:30:00.000-05:00
  - timeEvent.end: 2024-11-21T15:30:00.000-05:00
  - timeEvent.startTimeZone: America/New_York
  - timeEvent.endTimeZone: America/New_York
  - Parsed startTime: 2024-11-21 14:30:00.000
  - Parsed endTime: 2024-11-21 15:30:00.000
  - startTime.timeZoneName: EST
  - startTime.timeZoneOffset: -5:00:00.000000
```

**What to Check**:
- Final DateTime objects that will be displayed
- These should match what the user originally entered

---

## How to Test

### Step 1: Clear Console
Clear your console/terminal to start fresh.

### Step 2: Create an Event
1. Open the app
2. Create a new event
3. Pick a specific time (e.g., 2:30 PM)
4. Note the time you selected
5. Click Save

### Step 3: Analyze Console Logs

Look for this sequence:
```
📅 [EventDetails] User picked times:
  - Start time: 14:30  ← What you picked

📤 [EventDetails] Formatting for backend:
  - start formatted: 2024-11-21T14:30:00.000-05:00  ← What we send

📨 [EventService.createTimeEvent] TimeEventInput received:
  - start: 2024-11-21T14:30:00.000-05:00  ← Confirm it's sent correctly

📥 [EventService.createTimeEvent] Response from backend:
  - start: ???  ← CHECK THIS! Is it the same or different?

🔍 [TimeEvent.fromJson] Parsing JSON:
  - RAW start from backend: ???  ← What backend gave us back

🔍 [DateTimeUtils.parseAnyFormat] Parsing:
  - converted to local: ???  ← Final DateTime before display
```

### Step 4: Compare Times

Make this comparison table:

| Stage | Expected Time | Actual Time | Match? |
|-------|--------------|-------------|--------|
| User picked | 2:30 PM | _from logs_ | ? |
| Sent to backend | 2:30 PM (-05:00) | _from logs_ | ? |
| Received from backend | 2:30 PM (-05:00) | _from logs_ | ? |
| Parsed for display | 2:30 PM | _from logs_ | ? |

### Step 5: Fetch the Event
1. Refresh the calendar or navigate away and back
2. Look for these logs:

```
📥 [EventService.fetchTimeEvents] Event from backend:
  - start: ???  ← Is this still correct?
  - start_timeZone: ???

🔍 [DateTimeUtils.parseAnyFormat] Parsing: ???
  - converted to local: ???  ← What time shows on calendar?
```

---

## Common Issues and How to Identify Them

### Issue #1: Backend Converts to UTC
**Symptom**: Backend response shows UTC time instead of local time

**Logs will show**:
```
📤 Sent: start: 2024-11-21T14:30:00.000-05:00
📥 Received: start: 2024-11-21T19:30:00.000Z  ← 5 hours added!
```

**Result**: Event jumps 5 hours forward

**Solution**: Backend needs to store the original time with offset

---

### Issue #2: Backend Stores Unix Timestamp
**Symptom**: Backend response shows timestamp instead of ISO string

**Logs will show**:
```
📤 Sent: start: 2024-11-21T14:30:00.000-05:00
📥 Received: start: 1732209000000  ← Unix timestamp
🔄 Converted timestamp to ISO: 2024-11-21T19:30:00.000Z ← Wrong!
```

**Result**: Event time changes

**Solution**: Backend should store ISO strings, not timestamps

---

### Issue #3: Frontend Converts Incorrectly
**Symptom**: Backend sends correct data but frontend displays wrong time

**Logs will show**:
```
📥 Received: start: 2024-11-21T14:30:00.000-05:00  ← Correct
🔍 Parsed ISO string: 2024-11-21 09:30:00.000  ← Wrong! Lost 5 hours
```

**Result**: Event shows wrong time

**Solution**: Fix DateTimeUtils.parseAnyFormat logic

---

### Issue #4: Timezone Name Mismatch
**Symptom**: Time offset and timezone name don't match

**Logs will show**:
```
📤 Sent:
  - start: 2024-11-21T14:30:00.000-05:00  ← Says EST (-05:00)
  - start_timeZone: UTC  ← Says UTC (+00:00)
  ❌ MISMATCH!
```

**Result**: Backend gets confused, stores wrong time

**Solution**: Ensure timezone detection works (should be fixed now)

---

## What to Share

After running the test, share:

1. **Full console logs** from creating an event
2. **Full console logs** from fetching events
3. **Comparison table** showing:
   - Time you picked
   - Time sent to backend (from logs)
   - Time received from backend (from logs)
   - Time displayed on calendar
4. **Screenshot** of the event on the calendar showing the wrong time

This will pinpoint EXACTLY where the issue occurs!

---

## Files with Logging

- `lib/widgets/calendar/views/eventDetails.dart` - Event creation UI
- `lib/services/eventsService.dart` - Backend communication
- `lib/models/timeEvent.dart` - Data model parsing
- `lib/utils/dateUtils.dart` - DateTime conversions
- `lib/utils/eventsMapper.dart` - Mapping to display objects
- `lib/utils/timezoneUtils.dart` - Timezone detection

All files have emoji-prefixed logs (📅, 📤, 📥, 🔍, etc.) for easy identification.
