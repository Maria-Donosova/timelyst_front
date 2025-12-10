# Timelyst Frontend Agent Instructions

## Agent Identity

You are the **timelyst_front agent**, responsible for developing and maintaining the Flutter-based frontend for Timelyst—a unified calendar and task management application.

---

## Project Context

### What is Timelyst?

Timelyst solves three critical pain points in calendar/task management:

1. **Multi-Calendar Sync Failures** — Users suffer from sync delays, duplicates, and missed deletions
2. **Apple Calendar Integration** — iCloud has 5-10 minute sync delays vs real-time for others
3. **Fragmented Tools** — Constant app-switching between calendars and task managers

### Your Role

You build the user-facing application that provides:
- A unified view of all calendars (Google, Microsoft, Apple)
- Integrated task management alongside calendar events
- Recurring event support with master/exception model
- Seamless cross-platform experience (iOS, Android, Web)

---

## Technology Stack (Current)

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | Provider |
| Calendar UI | Syncfusion Flutter Calendar |
| HTTP Client | http package |
| Secure Storage | flutter_secure_storage |
| Environment | flutter_dotenv |

---

## Architecture

### Project Structure (Current)

```
lib/
├── config/                    # Environment configuration
│   └── environment.dart
│
├── data_sources/
│   └── timelyst_calendar_data_source.dart  # Syncfusion data source
│
├── main.dart                  # App entry point with Provider setup
│
├── models/
│   ├── timeEvent.dart         # Core event model (with recurrence fields)
│   ├── customApp.dart         # CustomAppointment for Syncfusion
│   ├── task.dart
│   ├── calendar.dart
│   └── user.dart
│
├── providers/
│   ├── authProvider.dart      # Authentication state
│   ├── eventProvider.dart     # Event state + caching
│   ├── calendarProvider.dart  # Calendar list state
│   └── taskProvider.dart      # Task state
│
├── services/
│   ├── authService.dart       # Login, register, token management
│   ├── eventsService.dart     # Event CRUD + recurring operations
│   ├── calendarsService.dart  # Calendar CRUD
│   ├── tasksService.dart      # Task CRUD
│   ├── contactService.dart    # Contact form
│   ├── event_handler_service.dart  # Recurring event dialogs/logic
│   │
│   ├── googleIntegration/     # Google Calendar (8 files)
│   │   ├── googleAuthService.dart
│   │   ├── googleSignInManager.dart
│   │   ├── googleCalendarService.dart
│   │   ├── googleEventsImportService.dart
│   │   └── calendarSyncManager.dart
│   │
│   ├── microsoftIntegration/  # Microsoft Calendar (5 files)
│   │   ├── microsoftAuthService.dart
│   │   ├── microsoftSignInManager.dart
│   │   ├── microsoftCalendarService.dart
│   │   └── microsoftSignInOut.dart
│   │
│   └── appleIntegration/      # Apple Calendar (7 files)
│       ├── appleAuthService.dart
│       ├── appleCalDAVManager.dart
│       ├── appleCalDAVService.dart
│       ├── appleCalendarService.dart
│       └── appleSignInManager.dart
│
├── themes.dart                # App theming
│
├── utils/
│   ├── rrule_utils.dart       # RRULE parsing and expansion
│   ├── date_utils.dart
│   └── validators.dart
│
└── widgets/
    ├── calendar/
    │   ├── controllers/
    │   │   └── calendar.dart  # CalendarW widget
    │   ├── recurring_event_dialog.dart
    │   └── event_detail_sheet.dart
    ├── events/
    ├── tasks/
    ├── settings/
    └── common/
```

### Architecture Pattern

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│     (Widgets, Screens, CalendarW)               │
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────┐
│               Provider Layer                    │
│  (AuthProvider, EventProvider, CalendarProvider)│
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────┐
│               Service Layer                     │
│   (EventService, CalendarService, AuthService)  │
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────┐
│                Model Layer                      │
│    (TimeEvent, CustomAppointment, Calendar)     │
└─────────────────────────────────────────────────┘
```

### Provider Setup (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(...),
    ChangeNotifierProxyProvider<AuthProvider, EventProvider>(...),
    ChangeNotifierProxyProvider<AuthProvider, CalendarProvider>(...),
  ],
)
```

---

## Core Services

### EventService

**File**: `services/eventsService.dart`

**Standard Endpoints** (`/events/` prefix):
```dart
fetchEvents(userId, authToken, startDate?, endDate?)  // GET /events
createEvent(eventInput, authToken)                     // POST /events
updateEvent(id, eventInput, authToken)                 // PUT /events/:id
deleteEvent(id, authToken, deleteScope?)               // DELETE /events/:id
```

**Recurring Event Endpoints** (`/recurring-events/` prefix):
```dart
// GET /api/calendar - Masters, exceptions, occurrence counts
getCalendarView(authToken, start, end)

// PUT /recurring-events/:id/occurrences/:date - Create/update exception
updateThisOccurrence(authToken, masterEventId, originalStart, updates)

// PUT /recurring-events/:id/split?from=date - Split series
updateThisAndFuture(authToken, masterEventId, fromDate, updates)

// PUT /recurring-events/:id?preserveExceptions=bool - Update master
updateAllOccurrences(authToken, masterEventId, updates, preserveExceptions)

// DELETE /recurring-events/:id/occurrences/:date - Cancelled exception
deleteThisOccurrence(authToken, masterEventId, originalStart)

// DELETE /recurring-events/:id/future?from=date - Truncate series
deleteThisAndFuture(authToken, masterEventId, fromDate)

// DELETE /recurring-events/:id?deleteAll=true - Delete entire series
deleteAllOccurrences(authToken, masterEventId)
```

### EventHandlerService

**File**: `services/event_handler_service.dart`

**Purpose**: Centralized logic for recurring event operations

```dart
// Shows 3-option dialog: This occurrence / This and future / All
handleEventEdit(context, event, occurrenceCount)

// Shows 3-option delete dialog
handleEventDelete(context, event, occurrenceCount)

// Shows 2-option dialog for drag-and-drop: This occurrence / All
handleDragDrop(context, event, newStart, newEnd)
```

### Calendar Integration Services

**Google** (`services/googleIntegration/`):
- OAuth flow via `googleSignInManager`
- Backend exchanges auth code for tokens
- `googleEventsImportService.dart` (15KB) handles sync logic

**Microsoft** (`services/microsoftIntegration/`):
- OAuth with PKCE
- Backend handles token exchange

**Apple** (`services/appleIntegration/`):
- App-specific password auth
- CalDAV protocol via backend

---

## State Providers

### EventProvider

**File**: `providers/eventProvider.dart`

**State**:
```dart
List<CustomAppointment> _events       // UI-ready appointments
List<TimeEvent> _timeEvents           // Raw event data
Map<String, List<CustomAppointment>> _eventCache  // 5-minute cache
Map<String, int> _occurrenceCounts    // For recurring event dialogs
```

**Key Methods**:
```dart
fetchCalendarView()        // Fetches masters, exceptions, counts
fetchDayViewEvents()
fetchWeekViewEvents()
fetchMonthViewEvents()
createEvent()
updateEvent()
deleteEvent()
getOccurrenceCount(masterEventId)  // For dialog display
invalidateCache()          // Force fresh fetch
```

**Caching Strategy**:
- Cache key: `"startDate_endDate"` (e.g., "2025-10-12_2025-10-13")
- TTL: 5 minutes
- Invalidated on: view change, manual refresh, CRUD operations

### CalendarProvider

**File**: `providers/calendarProvider.dart`

**Responsibilities**:
- Manage user's calendar list
- Track calendar selection state
- Handle Google re-authentication callback

### AuthProvider

**File**: `providers/authProvider.dart`

**State**:
```dart
AuthService authService
bool googleReAuthRequired
```

### TaskProvider

**File**: `providers/taskProvider.dart`

**Responsibilities**: Task management (separate from events)

---

## Data Models

### TimeEvent (Core Model)

**File**: `models/timeEvent.dart`

**Standard Fields**:
```dart
String id
String eventTitle
DateTime start
DateTime end
String? startTimeZone
String? endTimeZone
String? location
String? description
bool isAllDay
String? calendarId
String? category
```

**Provider/Sync Fields**:
```dart
String? provider              // 'google', 'microsoft', 'apple', 'timelyst'
String? providerCalendarId
String? providerEventId
String? etag
String? status                // 'confirmed', 'cancelled', 'tentative'
int? sequence
String? busyStatus
String? visibility
List<Map>? attendees
String? organizerEmail
String? organizerName
Map? rawData
```

**Recurrence Fields**:
```dart
String? recurrenceRule        // RRULE string
String? recurrenceId          // Points to master's providerEventId
DateTime? originalStart       // Original occurrence time (for exceptions)
```

**Computed Properties**:
```dart
bool get isMasterEvent => recurrenceRule != null && recurrenceId == null
bool get isException => recurrenceId != null
bool get isCancelled => status == 'cancelled'
bool get isRecurring => recurrenceRule != null || recurrenceId != null
```

### CustomAppointment (UI Model)

**File**: `models/customApp.dart`

**Purpose**: Syncfusion Calendar-compatible appointment

**Key Fields**:
```dart
String id
String title
DateTime startTime
DateTime endTime
Color color
String? recurrenceRule
String? recurrenceId
DateTime? originalStart
bool isMasterEvent
bool isException
```

---

## Calendar Data Source

### TimelystCalendarDataSource

**File**: `data_sources/timelyst_calendar_data_source.dart`

**Purpose**: Bridge between TimeEvent/CustomAppointment and Syncfusion Calendar

**Key Responsibilities**:
- Expand master events into occurrences using RRULE
- Apply exceptions (modified occurrences)
- Filter cancelled occurrences
- Return CustomAppointment list for Syncfusion

```dart
class TimelystCalendarDataSource extends CalendarDataSource {
  TimelystCalendarDataSource(List<TimeEvent> events) {
    appointments = _processEvents(events);
  }

  List<CustomAppointment> _processEvents(List<TimeEvent> events) {
    // 1. Separate masters and exceptions
    // 2. Expand masters using RRULE
    // 3. Apply exceptions to matching occurrences
    // 4. Filter cancelled occurrences
    // 5. Return CustomAppointment list
  }
}
```

---

## API Communication

### Base URL

```dart
// From environment config
final baseUrl = dotenv.env['BACKEND_URL'] ?? 'https://timelyst-core.fly.dev';
```

### Authentication

```dart
// JWT token in header
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $authToken',
}
```

### Backend Endpoints Used

**Authentication**:
- `POST /auth/login`
- `POST /auth/register`

**Events**:
- `GET /events`
- `POST /events`
- `PUT /events/:id`
- `DELETE /events/:id`

**Recurring Events**:
- `GET /api/calendar`
- `PUT /recurring-events/:id`
- `DELETE /recurring-events/:id`
- `PUT /recurring-events/:id/occurrences/:date`
- `DELETE /recurring-events/:id/occurrences/:date`
- `PUT /recurring-events/:id/split`
- `DELETE /recurring-events/:id/future`

**Calendars**:
- `GET /calendars`
- `POST /calendars`
- `PUT /calendars/:id`
- `DELETE /calendars/:id`

**Tasks**:
- `GET /tasks`
- `POST /tasks`
- `PUT /tasks/:id`
- `DELETE /tasks/:id`

**Integrations**:
- `POST /integrations/google/connect`
- `POST /integrations/google/sync`
- `POST /integrations/microsoft/connect`
- `POST /integrations/microsoft/sync`
- `POST /integrations/apple/connect`
- `POST /integrations/apple/sync`
- `POST /apple/calendars/fetch`
- `POST /apple/calendars/save`
- `DELETE /apple/calendars/delete`
- `DELETE /apple/accounts/delete`

**Other**:
- `POST /contact`

---

## Recurring Events Architecture

### Flow: Display Recurring Events

```
1. EventProvider.fetchCalendarView()
   → EventService.getCalendarView()
   → Backend returns: { masters, exceptions, occurrenceCounts }

2. EventProvider stores:
   → _timeEvents (raw TimeEvent objects)
   → _occurrenceCounts (for dialogs)

3. TimelystCalendarDataSource processes:
   → Expands masters using RRULE
   → Applies exceptions
   → Returns CustomAppointment list

4. CalendarW widget displays
```

### Flow: Edit Single Occurrence

```
1. User taps occurrence → EventHandlerService.handleEventEdit()
2. Dialog shows: "This occurrence" / "This and future" / "All"
3. User selects "This occurrence"
4. EventService.updateThisOccurrence(masterEventId, originalStart, updates)
   → PUT /recurring-events/:id/occurrences/:date
5. Backend creates/updates exception
6. EventProvider.invalidateCache()
7. UI refreshes
```

### Flow: Delete This and Future

```
1. User taps delete → EventHandlerService.handleEventDelete()
2. Dialog shows: "This occurrence" / "This and future" / "All"
3. User selects "This and future"
4. EventService.deleteThisAndFuture(masterEventId, fromDate)
   → DELETE /recurring-events/:id/future?from=date
5. Backend updates master RRULE with UNTIL
6. EventProvider.invalidateCache()
7. UI refreshes
```

---

## Widget Integration

### CalendarW Widget

**File**: `widgets/calendar/controllers/calendar.dart`

**Integration Points**:
- Uses `TimelystCalendarDataSource` for event display
- Calls `EventHandlerService` for drag-and-drop
- Calls `EventHandlerService` for event resize
- Shows `RecurringEventDialog` for recurring event actions

```dart
SfCalendar(
  dataSource: TimelystCalendarDataSource(events),
  onTap: _handleCalendarTap,
  onLongPress: _handleLongPress,
  allowDragAndDrop: true,
  onDragEnd: (details) => _handleDragDrop(details),
)
```

### RecurringEventDialog

**File**: `widgets/calendar/recurring_event_dialog.dart`

**Purpose**: 3-option dialog for recurring event modifications

**Options**:
1. This occurrence only
2. This and future occurrences
3. All occurrences

**Usage**:
```dart
final result = await showRecurringEventDialog(
  context,
  event: event,
  occurrenceCount: provider.getOccurrenceCount(event.id),
  isDelete: false,
);
```

---

## Known Issues

### 🔴 CRITICAL: Microsoft/Apple Events Not Appearing

**Problem**: Only Google events appear in UI. Microsoft and Apple events have empty `source` and `userCalendars` fields.

**Status**: Frontend ready, backend fix needed

**Investigation Needed**:
1. Verify events exist in database
2. Check OAuth token status
3. Review sync job logs
4. Test API directly for Microsoft/Apple events

### 🟡 MEDIUM: Recurring Events Integration Incomplete

**Completed**:
- ✅ Backend API endpoints
- ✅ Frontend data models
- ✅ TimelystCalendarDataSource
- ✅ EventHandlerService
- ✅ RecurringEventDialog
- ✅ EventProvider.fetchCalendarView()
- ✅ CalendarW integration

**Pending**:
- ⏳ End-to-end testing
- ⏳ Provider sync for recurring events
- ⏳ Edge case handling

### 🟡 MEDIUM: Backend Performance

**Issue**: Backend fetches broad date ranges regardless of frontend request

**Impact**:
- Day view: Fetches 210 days instead of 1
- Week view: Fetches 210 days instead of 7
- Month view: Fetches 210 days instead of 30

---

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Analyze code
flutter analyze
```

---

## Environment Variables

**File**: `lib/.env`

```
BACKEND_URL=https://timelyst-core.fly.dev
GOOGLE_CLIENT_ID=...
MICROSOFT_CLIENT_ID=...
```

---

## Testing Status

### Completed
- ✅ RRULE utilities (all passing)
- ✅ Recurring events API (3 tests passing)

### Pending
- ⏳ Service layer tests
- ⏳ Provider tests
- ⏳ Widget tests
- ⏳ End-to-end recurring event tests
- ⏳ Calendar sync flow tests

### Manual Testing Required
- [ ] Recurring events display in all views
- [ ] Exception events display correctly
- [ ] Drag-and-drop for recurring events
- [ ] Edit/delete dialogs show correct occurrence counts
- [ ] Microsoft/Apple event sync and display

---

## Code Quality Notes

### Strengths
- ✅ Clear separation of concerns
- ✅ Comprehensive recurring events architecture
- ✅ Backward compatibility maintained
- ✅ Proper error handling
- ✅ Extensive logging

### Areas for Improvement
- ⚠️ Aggressive cache invalidation (performance impact)
- ⚠️ Dual event storage in provider (memory overhead)
- ⚠️ Frontend RRULE format fixing (should be backend)
- ⚠️ Missing comprehensive test coverage

---

## Coordination with Backend

When coordinating with timelyst-core agent:

1. **API Contract**: Verify response format for endpoints
2. **New Features**: Request new endpoints as needed
3. **Error Handling**: Understand error codes and messages
4. **Sync Behavior**: Understand webhook vs polling behavior
5. **Data Format**: Ensure TimeEvent fields match backend response

---

## Checklist Before Committing

- [ ] Code compiles without errors
- [ ] No analyzer warnings
- [ ] New code has appropriate tests
- [ ] UI works on different screen sizes
- [ ] Error states are handled
- [ ] Loading states are shown
- [ ] API changes coordinated with backend team
