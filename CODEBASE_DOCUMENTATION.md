# Timelyst Frontend Codebase Documentation

This document provides a comprehensive overview of the Timelyst Flutter application, including its tech stack, architecture, project structure, and key implementation details.

## 🛠 Tech Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`MultiProvider`, `ChangeNotifier`, `ProxyProvider`) |
| **Calendar UI** | [Syncfusion Flutter Calendar](https://pub.dev/packages/syncfusion_flutter_calendar) |
| **Networking** | `http` package with custom `ApiClient` wrapper |
| **Authentication** | Google Sign-In, JWT (JSON Web Tokens), `flutter_secure_storage` |
| **Persistence** | `flutter_secure_storage` (for tokens and user settings) |
| **Timezone Handling** | `timezone`, `flutter_timezone` |
| **Logging** | `logger` package |
| **Deployment** | Docker, Nginx (for Web), Fly.io |

## 🏗 Architecture

The application follows a **Layered Architecture** with a focus on reactivity and clear separation of concerns.

### 1. UI Layer (`lib/widgets/`)
- **Screens:** High-level widgets representing app pages (e.g., `Agenda`, `LogInScreen`).
- **Components:** Reusable UI elements (e.g., `CustomButton`, `EventForm`).
- **View-Models (via Providers):** The UI reacts to changes in Providers using `context.watch()` or `Consumer`.

### 2. State Management Layer (`lib/providers/`)
- **`AuthProvider`**: Manages user session, login, registration, and persistent auth state.
- **`EventProvider`**: Core logic for calendar events, including fetching, caching, optimistic updates, and rollbacks.
- **`TaskProvider`**: Manages user tasks and their lifecycle.
- **`CalendarProvider`**: Handles external calendar integrations (Google, etc.).

### 3. Service Layer (`lib/services/`)
- **API Services:** Encapsulate HTTP calls to the backend (e.g., `EventsService`, `AuthService`).
- **Integrations:** Dedicated services for `googleIntegration`, `microsoftIntegration`, and `appleIntegration`.
- **`ApiClient`**: A centralized utility for adding auth headers, logging requests, and handling common error responses.

### 4. Data Layer (`lib/models/` & `lib/data_sources/`)
- **Models:** Strongly-typed Dart classes for data entities (e.g., `TimeEvent`, `CustomAppointment`, `Task`). Supports JSON serialization.
- **Data Sources:** Adapters for third-party libraries. `TimelystCalendarDataSource` acts as a bridge between the app's `TimeEvent` models and Syncfusion's `Appointment` format.

## 📂 Project Structure

```text
lib/
├── config/             # Environment configurations and global constants
├── data_sources/       # Adapters for Syncfusion Calendar
├── models/             # Data models and DTOs
├── providers/          # ChangeNotifier classes for state management
├── services/           # Backend API services and 3rd party integrations
├── utils/              # Helper functions (Date parsing, Mapping, API client)
├── widgets/            # UI components and screens
│   ├── calendar/       # Calendar-specific views and controllers
│   ├── common/         # Shared UI components
│   └── screens/        # Main application pages
├── main.dart           # App entry point and Provider setup
└── themes.dart         # Global styling and theme definitions
```

## 🚀 Key Implementation Details

### 1. Backend-Driven Event Expansion
Unlike traditional calendar apps that expand RRULEs on the frontend, Timelyst delegates recurrence expansion to the backend. The frontend receives a flat list of expanded occurrences, each with a `masterId` and a unique `id`. This prevents rendering bottlenecks and ensures consistency across platforms.

### 2. Timezone Resilience
The app implements a strict timezone handling strategy:
- Uses `flutter_timezone` to detect device IANA timezone (e.g., `America/New_York`).
- Sends the user's timezone in headers (`X-Timezone`) for all API requests.
- Maps backend UTC strings to local `DateTime` objects while preserving offset information to avoid "time jumping."

### 3. Optimistic Updates & Rollbacks
To provide a "latency-free" experience, operations like dragging or resizing events are updated locally in the `EventProvider` immediately. If the backend API call fails, the provider uses a snapshot-based rollback mechanism to restore the previous valid state.

### 4. Reactive Authentication Flow
The `Wrapper` widget in `main.dart` acts as a router that automatically switches between `LogInScreen` and `Agenda` based on the `AuthProvider.isLoggedIn` state. It also handles auto-login on startup.

### 5. Calendar Mapper Pattern
The `EventMapper` utility decouples the API model (`TimeEvent`) from the UI model (`CustomAppointment`). This allows the UI to remain stable even if the backend schema changes, provided the mapping logic is updated.

---

*This documentation is accurate as of January 2026. For specific implementation details, refer to the comments within the respective source files.*
