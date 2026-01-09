# Timelyst Frontend (Flutter)

This is a Flutter-based mobile application for Timelyst, a tool for managing calendars, events, and tasks. The application communicates with a backend server using GraphQL and supports integration with Google Calendar for seamless event synchronization. User authentication is handled through both email/password registration and Google Sign-In.

## Key Features

*   Calendar, event, and task management
*   Google Calendar integration for event synchronization
*   User authentication with email/password and Google Sign-In
*   GraphQL API communication
*   State management with Provider

## Technologies Used

*   **Frontend:** Flutter
*   **State Management:** [Provider](https://pub.dev/packages/provider)
*   **API Communication:** MariaDB
*   **Authentication:** [Google Sign-In](https://pub.dev/packages/google_sign_in), Email/Password (via GraphQL mutations)
*   **Calendar:** [Syncfusion Flutter Calendar](https://pub.dev/packages/syncfusion_flutter_calendar)
*   **Secure Storage:** [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) for storing auth tokens
*   **Environment Variables:** [Flutter DotEnv](https://pub.dev/packages/flutter_dotenv)

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### Installation

1.  Clone the repo
    ```sh
    git clone https://github.com/your_username_/timelyst_front-end_flutter.git
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```

### Running

1.  Create a `.env` file in the `lib/` directory and add the necessary backend URLs and API keys.
2.  Run the app
    ```sh
    flutter run
    ```

## Testing

To run the test suite:

```bash
flutter test
```

## Environment Variables

The project uses a `.env` file to manage environment variables. A `lib/.env` file should be created with the necessary backend URLs and API keys. The `lib/config/envVarConfig.dart` file loads these variables.

## Project Structure

```
.
├── android
├── assets
├── ios
├── lib
│   ├── config
│   ├── models
│   ├── providers
│   ├── services
│   ├── utils
│   └── widgets
├── test
└── ...
```
