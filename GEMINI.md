# Timelyst Frontend (Flutter)

## Project Overview

This is a Flutter-based mobile application for Timelyst, a tool for managing calendars, events, and tasks. The application communicates with a backend server using GraphQL and supports integration with Google Calendar for seamless event synchronization. User authentication is handled through both email/password registration and Google Sign-In.

**Key Technologies:**

*   **Frontend:** Flutter
*   **State Management:** Provider
*   **API Communication:** GraphQL (`graphql_flutter`)
*   **Authentication:** Google Sign-In, Email/Password (via GraphQL mutations)
*   **Calendar:** `syncfusion_flutter_calendar`
*   **Secure Storage:** `flutter_secure_storage` for storing auth tokens.
*   **Environment Variables:** `flutter_dotenv`

## Building and Running

To build and run the application, you will need to have the Flutter SDK installed.

**1. Install Dependencies:**

```bash
flutter pub get
```

**2. Run the Application:**

```bash
flutter run
```

**3. Running Tests:**

To run the test suite:

```bash
flutter test
```

## Development Conventions

*   **State Management:** The project uses the `provider` package for state management. New features should follow this pattern, creating providers for different domains of the application (e.g., `CalendarProvider`, `TaskProvider`).
*   **API Communication:** All communication with the backend is handled via GraphQL. Queries and mutations are defined within the services that use them (e.g., `AuthService`).
*   **Environment Variables:** The project uses a `.env` file to manage environment variables. A `lib/.env` file should be created with the necessary backend URLs and API keys. The `lib/config/envVarConfig.dart` file loads these variables, but it also contains hardcoded fallback values, including sensitive information. It is strongly recommended to remove these hardcoded values and rely solely on the `.env` file.
*   **Authentication:** The `AuthService` class is responsible for all authentication-related logic, including login, registration, and token management.
*   **Google Integration:** The `GoogleSignInOutService` and other Google-related services handle the integration with Google Calendar.
