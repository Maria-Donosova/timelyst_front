# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based mobile application for Timelyst, a calendar and task management tool with Google Calendar integration. The app uses GraphQL for API communication and Provider for state management.

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Build for release
flutter build apk --release
flutter build ios --release

# Clean build cache
flutter clean
flutter pub get
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Run with specific device
flutter run -d <device-id>
```

## Architecture

### State Management
- **Provider**: Primary state management solution
- **MultiProvider** setup in `main.dart` with dependency injection
- Key providers: `AuthProvider`, `TaskProvider`, `EventProvider`, `CalendarProvider`

### Authentication
- **Dual authentication**: Email/password and Google Sign-In
- **AuthService**: Handles authentication logic with secure token storage
- **AuthProvider**: Manages authentication state
- **Flutter Secure Storage**: Stores auth tokens and user data

### Google Integration
- **GoogleSignInManager**: Coordinates Google authentication flow
- **GoogleAuthService**: Handles Google OAuth authentication codes
- **GoogleSignInOutService**: Manages Google sign-in/out operations
- **GoogleCalendarService**: Integrates with Google Calendar API
- **CalendarSyncManager**: Handles calendar synchronization

### API Communication
- **GraphQL**: Primary API communication via `graphql_flutter`
- **ApiClient**: Custom HTTP client for GraphQL requests
- **Environment configuration**: Centralized in `Config` class

### Project Structure
```
lib/
├── config/           # Environment and configuration
├── models/           # Data models (User, Task, Event, Calendar)
├── providers/        # State management providers
├── services/         # Business logic and API services
│   ├── googleIntegration/  # Google-specific services
│   └── config_service*.dart # Platform-specific config
├── utils/            # Utility functions
├── widgets/          # UI components
│   ├── calendar/     # Calendar-related widgets
│   ├── screens/      # Screen-level widgets
│   ├── shared/       # Shared UI components
│   └── ToDo/         # Task management widgets
└── main.dart         # App entry point
```

## Environment Configuration

The app uses environment variables configured through:
- **Config class** (`lib/config/envVarConfig.dart`)
- **Platform-specific config services**: `config_service_web.dart` and `config_service_vm.dart`
- **Required variables**: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `BACKEND_URL`, `BACKEND_URL_GRAPHQL`

## Key Dependencies

- **Flutter**: Core framework
- **Provider**: State management
- **graphql_flutter**: GraphQL client
- **google_sign_in**: Google authentication
- **syncfusion_flutter_calendar**: Calendar component
- **flutter_secure_storage**: Secure token storage
- **http**: HTTP requests

## Testing

- Tests located in `test/` directory
- Use `flutter test` to run the test suite
- Mockito for mocking dependencies

## Important Notes

- The app supports both mobile and web platforms
- Google Calendar integration requires proper OAuth setup
- Authentication tokens are stored securely using Flutter Secure Storage
- The app uses a wrapper widget (`Wrapper`) to handle authentication routing