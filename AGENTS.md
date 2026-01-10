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
ComponentTechnologyFrameworkFlutter (Dart)State ManagementProvider (MultiProvider, ChangeNotifier, ProxyProvider)Calendar UISyncfusion Flutter CalendarHTTP Clienthttp package with custom ApiClient wrapperAuthenticationGoogle Sign-In, JWT, flutter_secure_storageSecure Storageflutter_secure_storageTimezone Handlingtimezone, flutter_timezoneLogginglogger packageEnvironmentflutter_dotenvDeploymentDocker, Nginx (Web), Fly.io

## Architecture
Project Structure (Current)
lib/
├── config/                    # Environment configuration
│   └── environment.dart
│
├── data_sources/
│   └── timelyst_calendar_data_source.dart  # Syncfusion data source adapter
│
├── main.dart                  # App entry point with Provider setup
│
├── models/
│   ├── timeEvent.dart         # Core event model (backend-expanded)
│   ├── customApp.dart         # CustomAppointment for Syncfusion
│   ├── task.dart
│   ├── calendar.dart
│   └── user.dart
│
├── providers/
│   ├── authProvider.dart      # Authentication state, session management
│   ├── eventProvider.dart     # Event state, caching, optimistic updates
│   ├── calendarProvider.dart  # Calendar list state, integrations
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
│   ├── googleIntegration/     # Google Calendar
│   │   ├── googleAuthService.dart
│   │   ├── googleSignInManager.dart
│   │   ├── googleCalendarService.dart
│   │   ├── googleEventsImportService.dart
│   │   └── calendarSyncManager.dart
│   │
│   ├── microsoftIntegration/  # Microsoft Calendar
│   │   ├── microsoftAuthService.dart
│   │   ├── microsoftSignInManager.dart
│   │   ├── microsoftCalendarService.dart
│   │   └── microsoftSignInOut.dart
│   │
│   └── appleIntegration/      # Apple Calendar
│       ├── appleAuthService.dart
│       ├── appleCalDAVManager.dart
│       ├── appleCalDAVService.dart
│       ├── appleCalendarService.dart
│       └── appleSignInManager.dart
│
├── themes.dart                # App theming
│
├── utils/
│   ├── api_client.dart        # Centralized HTTP client with auth headers
│   ├── event_mapper.dart      # TimeEvent ↔ CustomAppointment mapping
│   ├── date_utils.dart        # Date parsing and formatting
│   └── validators.dart        # Input validation
│
└── widgets/
    ├── calendar/
    │   ├── controllers/
    │   │   └── calendar.dart  # CalendarW widget
    │   ├── recurring_event_dialog.dart
    │   └── event_detail_sheet.dart
    ├── screens/               # Main application pages
    │   ├── agenda.dart
    │   ├── login_screen.dart
    │   └── wrapper.dart       # Auth-based routing
    ├── events/
    ├── tasks/
    ├── settings/
    └── common/

## Architecture Pattern
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│              (Widgets, Screens, CalendarW)                   │
│                                                              │
│   Wrapper ─── routes to ─── LogInScreen OR Agenda           │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    Provider Layer                            │
│     (AuthProvider, EventProvider, CalendarProvider)          │
│                                                              │
│   • Reactive state via ChangeNotifier                        │
│   • Optimistic updates with rollback                         │
│   • 5-minute event cache                                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    Service Layer                             │
│        (API Services, Integration Services)                  │
│                                                              │
│   • ApiClient: Auth headers, logging, error handling         │
│   • X-Timezone header on all requests                        │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                     Data Layer                               │
│        (Models, DTOs, Data Source Adapters)                  │
│                                                              │
│   • EventMapper: TimeEvent ↔ CustomAppointment               │
│   • TimelystCalendarDataSource: Syncfusion adapter           │
└─────────────────────────────────────────────────────────────┘
Provider Setup (main.dart)
dartMultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(...),
    ChangeNotifierProxyProvider<AuthProvider, EventProvider>(...),
    ChangeNotifierProxyProvider<AuthProvider, CalendarProvider>(...),
  ],
  child: Wrapper(),  // Auth-based routing
)

## Key Implementation Details
## Backend-Driven Event Expansion
Critical Architecture Decision: Unlike traditional calendar apps that expand RRULEs on the frontend, Timelyst delegates recurrence expansion to the backend.
┌─────────────┐     GET /events      ┌─────────────┐
│   Frontend  │ ──────────────────►  │   Backend   │
│             │                      │             │
│  Receives   │ ◄──────────────────  │  Expands    │
│  flat list  │   Expanded events    │  RRULEs     │
└─────────────┘                      └─────────────┘
What F
Flat list of expanded occurrences
Each occurrence has unique id and masterId
No RRULE parsing required on frontend

Benefits:
Prevents rendering bottlenecks
Ensures consistency across platforms
Simplifies frontend complexity
Backend handles timezone-aware expansion

## Timezone Resilience
The app implements strict timezone handling:
dart// 1. Detect device timezone using flutter_timezone
final deviceTimezone = await FlutterTimezone.getLocalTimezone();
// e.g., "America/New_York"

// 2. Send timezone in headers for all API requests
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $authToken',
  'X-Timezone': deviceTimezone,
}

// 3. Backend returns times adjusted for viewer's timezone
Timezone Flow:

flutter_timezone detects device IANA timezone
X-Timezone header sent with all API requests
Backend expands events in their original timezone
Frontend maps UTC strings to local DateTime objects
Offset information preserved to avoid "time jumping"

## Optimistic Updates & Rollbacks
To provide a "latency-free" experience:
dart// In EventProvider
Future<void> updateEvent(event) async {
  // 1. Store snapshot for rollback
  final snapshot = List.from(_events);
  
  // 2. Apply update immediately (optimistic)
  _applyLocalUpdate(event);
  notifyListeners();
  
  // 3. Call API
  try {
    await eventService.updateEvent(event);
  } catch (e) {
    // 4. Rollback on failure
    _events = snapshot;
    notifyListeners();
    rethrow;
  }
}
Applies To:
Drag-and-drop event moves
Event resizing
Quick edits

## Reactive Authentication Flow
The Wrapper widget in main.dart acts as an auth-based router:
dartclass Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn) {
          return Agenda();
        } else {
          return LogInScreen();
        }
      },
    );
  }
}
Features:
Automatic screen switching based on AuthProvider.isLoggedIn
Handles auto-login on startup
Manages token refresh flow

## Event Mapper Pattern
The EventMapper utility decouples API models from UI models:
dart// utils/event_mapper.dart
class EventMapper {
  static CustomAppointment toAppointment(TimeEvent event) {
    return CustomAppointment(
      id: event.id,
      subject: event.eventTitle,
      startTime: event.start,
      endTime: event.end,
      color: _getCategoryColor(event.category),
      isAllDay: event.isAllDay,
      masterId: event.masterId,
      // ... other mappings
    );
  }
  
  static TimeEvent fromAppointment(CustomAppointment apt) {
    // Reverse mapping for updates
  }
}
Benefits:
UI remains stable if backend schema changes
Centralized mapping logic
Easy to add computed properties

## Core Services
ApiClient
File: utils/api_client.dart
Purpose: Centralized HTTP client with authentication and timezone headers
dartclass ApiClient {
  final String baseUrl;
  
  Future<http.Response> get(String path, String authToken) async {
    final timezone = await FlutterTimezone.getLocalTimezone();
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
        'X-Timezone': timezone,
      },
    );
  }
  
  // Similar for post, put, delete
}
EventService
File: services/eventsService.dart
Standard Endpoints:
dartfetchEvents(authToken, startDate?, endDate?)  // GET /events
createEvent(eventInput, authToken)             // POST /events
updateEvent(id, eventInput, authToken)         // PUT /events/:id
deleteEvent(id, authToken, deleteScope?)       // DELETE /events/:id
Recurring Event Endpoints:
dart// GET /api/calendar - Expanded occurrences from backend
getCalendarView(authToken, start, end)

// PUT /recurring-events/:id/occurrences/:date
updateThisOccurrence(authToken, masterEventId, originalStart, updates)

// PUT /recurring-events/:id/split?from=date
updateThisAndFuture(authToken, masterEventId, fromDate, updates)

// PUT /recurring-events/:id
updateAllOccurrences(authToken, masterEventId, updates)

// DELETE /recurring-events/:id/occurrences/:date
deleteThisOccurrence(authToken, masterEventId, originalStart)

// DELETE /recurring-events/:id/future?from=date
deleteThisAndFuture(authToken, masterEventId, fromDate)

// DELETE /recurring-events/:id
deleteAllOccurrences(authToken, masterEventId)
EventHandlerService
File: services/event_handler_service.dart
Purpose: Centralized logic for recurring event user interactions
dart// Shows 3-option dialog: This occurrence / This and future / All
handleEventEdit(context, event, occurrenceCount)

// Shows 3-option delete dialog
handleEventDelete(context, event, occurrenceCount)

// Shows 2-option dialog for drag-and-drop: This occurrence / All
handleDragDrop(context, event, newStart, newEnd)

## State Providers
EventProvider
File: providers/eventProvider.dart
State:
dartList<CustomAppointment> _events       // UI-ready appointments
Map<String, List<CustomAppointment>> _eventCache  // 5-minute TTL cache
bool _isLoading
String? _error
Key Methods:
dartfetchEvents(start, end)        // Fetches expanded events from backend
createEvent(event)             // With optimistic update
updateEvent(event)             // With optimistic update + rollback
deleteEvent(id, scope)         // With optimistic update + rollback
invalidateCache()              // Force fresh fetch
Caching Strategy:

Cache key: "startDate_endDate" (e.g., "2025-10-12_2025-10-13")
TTL: 5 minutes
Invalidated on: view change, manual refresh, CRUD operations

CalendarProvider
File: providers/calendarProvider.dart
Responsibilities:

Manage user's calendar list (all providers)
Track calendar selection state
Handle provider re-authentication callbacks
Manage import settings per calendar

AuthProvider
File: providers/authProvider.dart
State:
dartAuthService authService
bool isLoggedIn
User? currentUser
bool googleReAuthRequired
bool microsoftReAuthRequired
bool appleReAuthRequired
Features:

Persistent auth state via flutter_secure_storage
Auto-login on app startup
Token refresh handling

TaskProvider
File: providers/taskProvider.dart
Responsibilities: Task lifecycle management (separate from calendar events)

## Data Models
TimeEvent (Core Model)
File: models/timeEvent.dart
Standard Fields:
dartString id
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
Provider/Sync Fields:
dartString? provider              // 'google', 'microsoft', 'apple', 'timelyst'
String? providerCalendarId
String? providerEventId
String? etag
String? status                // 'confirmed', 'cancelled', 'tentative'
String? busyStatus
String? visibility
List<Map>? attendees
String? organizerEmail
String? organizerName
Recurrence Fields (for master events only):
dartString? masterId              // ID of master event (for occurrences)
String? recurrenceRule        // RRULE string (master events only)
DateTime? originalStart       // Original occurrence time (for exceptions)
CustomAppointment (UI Model)
File: models/customApp.dart
Purpose: Syncfusion Calendar-compatible appointment
Key Fields:
dartString id
String subject
DateTime startTime
DateTime endTime
Color color
bool isAllDay
String? masterId              // Links occurrence to master
String? notes
String? location

## Calendar Data Source
TimelystCalendarDataSource
File: data_sources/timelyst_calendar_data_source.dart
Purpose: Bridge between backend events and Syncfusion Calendar
dartclass TimelystCalendarDataSource extends CalendarDataSource {
  TimelystCalendarDataSource(List<CustomAppointment> events) {
    appointments = events;
  }
  
  // Syncfusion CalendarDataSource overrides
  @override
  DateTime getStartTime(int index) => appointments![index].startTime;
  
  @override
  DateTime getEndTime(int index) => appointments![index].endTime;
  
  @override
  String getSubject(int index) => appointments![index].subject;
  
  @override
  Color getColor(int index) => appointments![index].color;
  
  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}
Note: Unlike previous architecture, this no longer expands RRULEs. Backend sends pre-expanded occurrences.

## API Communication
Base URL
dart// From environment config
final baseUrl = dotenv.env['BACKEND_URL'] ?? 'https://timelyst-core.fly.dev';
Request Headers
dartheaders: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $authToken',
  'X-Timezone': await FlutterTimezone.getLocalTimezone(),
}
Backend Endpoints Used
Authentication:

POST /auth/login
POST /auth/register

Events:

GET /events - Returns expanded occurrences
POST /events
PUT /events/:id
DELETE /events/:id

Recurring Events:

GET /api/calendar - Calendar view with expanded events
PUT /recurring-events/:id
DELETE /recurring-events/:id
PUT /recurring-events/:id/occurrences/:date
DELETE /recurring-events/:id/occurrences/:date
PUT /recurring-events/:id/split
DELETE /recurring-events/:id/future

Calendars:

GET /calendars
POST /calendars
PUT /calendars/:id
PUT /calendars/:id/preferences - Import settings
DELETE /calendars/:id

Tasks:

GET /tasks
POST /tasks
PUT /tasks/:id
DELETE /tasks/:id

Integrations:

POST /integrations/google/connect
POST /integrations/google/sync
POST /integrations/microsoft/connect
POST /integrations/microsoft/sync
POST /integrations/apple/connect
POST /integrations/apple/sync
POST /apple/calendars/fetch
POST /apple/calendars/save
DELETE /apple/calendars/delete
DELETE /apple/accounts/delete

Other:

GET /health
POST /contact


Widget Integration
CalendarW Widget
File: widgets/calendar/controllers/calendar.dart
Integration Points:

Uses TimelystCalendarDataSource for event display
Calls EventHandlerService for drag-and-drop
Calls EventHandlerService for event resize
Shows RecurringEventDialog for recurring event actions

dartSfCalendar(
  dataSource: TimelystCalendarDataSource(events),
  onTap: _handleCalendarTap,
  onLongPress: _handleLongPress,
  allowDragAndDrop: true,
  onDragEnd: (details) => _handleDragDrop(details),
  view: CalendarView.week,
)
RecurringEventDialog
File: widgets/calendar/recurring_event_dialog.dart
Purpose: 3-option dialog for recurring event modifications
Options:

This occurrence only
This and future occurrences
All occurrences

dartfinal result = await showRecurringEventDialog(
  context,
  event: event,
  isDelete: false,
);

switch (result) {
  case RecurringEditChoice.thisOccurrence:
    // Update single occurrence
    break;
  case RecurringEditChoice.thisAndFuture:
    // Split series
    break;
  case RecurringEditChoice.allOccurrences:
    // Update master
    break;
}
Wrapper Widget
File: widgets/screens/wrapper.dart
Purpose: Auth-based routing between login and main app
dartclass Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.isLoading) {
      return LoadingScreen();
    }
    
    return auth.isLoggedIn ? Agenda() : LogInScreen();
  }
}

## Development Commands
bash# Install dependencies
flutter pub get

# Run app (debug)
flutter run

# Run app on specific device
flutter run -d chrome
flutter run -d ios
flutter run -d android

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Build for web
flutter build web

# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Analyze code
flutter analyze

# Format code
dart format lib/

## Environment Variables
File: lib/.env
BACKEND_URL=https://timelyst-core.fly.dev
GOOGLE_CLIENT_ID=...
MICROSOFT_CLIENT_ID=...

Testing Status
Completed

✅ Event mapper utilities
✅ Date utilities
✅ Basic provider tests

Pending
⏳ EventProvider comprehensive tests
⏳ CalendarProvider tests
⏳ Widget tests for CalendarW
⏳ Widget tests for RecurringEventDialog
⏳ Integration tests for auth flow
⏳ Integration tests for event CRUD
⏳ End-to-end recurring event tests

## Manual Testing Verified 
✅ Google events display correctly
✅ Microsoft events display correctly
✅ Apple events display correctly
✅ Recurring events display in all views
✅ Drag-and-drop for events
✅ Event creation and editing


## Code Quality Notes
Strengths
✅ Clear separation of concerns (layered architecture)
✅ Backend-driven event expansion (no frontend RRULE parsing)
✅ Timezone-aware API communication
✅ Optimistic updates with rollback
✅ Centralized API client
✅ Event mapper pattern for UI decoupling
✅ Proper error handling
✅ Extensive logging

## Areas for Improvement
⚠️ Test coverage needs expansion
⚠️ Some aggressive cache invalidation (potential performance impact)
⚠️ Error boundary implementation needed


## Coordination with Backend
The frontend is designed to work with the updated timelyst-core backend:
AspectFrontend ExpectationBackend ProvidesEvent ExpansionFlat list of occurrencesRRULE expansion server-sideTimezoneSends X-Timezone headerExpands events in correct timezoneImport SettingsPer-calendar configurationPUT /calendars/:id/preferencesAuthJWT in Authorization header30-day expiry tokensProvidersGoogle, Microsoft, Apple, TimelystProvider-specific tablesRecurring EventsmasterId links occurrencesUnique IDs per occurrence
API Contract:

REST responses (not GraphQL)
Consistent error response format
Events include masterId for recurring occurrences
Calendar includes importSettings for privacy control


## Deployment
Web (Docker + Nginx)
dockerfile# Dockerfile for web deployment
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
Fly.io
bash# Deploy to Fly.io
fly deploy

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

This documentation is accurate as of January 2026. For specific implementation details, refer to the comments within the respective source files.