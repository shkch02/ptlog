# Project Context: ptlog

This is a Flutter application designed as a management tool for personal trainers. It helps manage members, schedules, session logs, and payments. The name "ptlog" is derived from "Personal Training Log."

## Current Project Status (As of 2026-01-16)

The application is a functional prototype with a comprehensive set of features implemented on the front end. All data is currently sourced from **mock data** located in `lib/data/mock_data.dart`. The repositories simulate asynchronous network calls using `Future.delayed`.

**Key Implemented Features:**
-   **Authentication:** A mock login screen (`LoginScreen`) that navigates to the main layout.
-   **Dashboard:** Displays today's schedules and allows for manual session creation.
-   **Member Management:** Full CRUD (Create, Read, Update, Delete) functionality for members, including archiving/unarchiving.
-   **Schedule Management:** A weekly timetable view (`ScheduleViewScreen`) and daily list view (`HomeScreen`).
-   **Workout Log:** Feature-rich session logging with two input modes: digital (keyboard) and handwriting (canvas).

The next major step for this project is to **replace the mock data layer with a real backend API**. The current architecture (Repository Pattern) is designed to make this transition smooth.

## Architecture & Patterns

The project follows a layered architecture, separating concerns for better maintainability and scalability.

-   **State Management (Flutter Riverpod):**
    -   **`Provider`**: Used for providing immutable objects like repositories (`repository_providers.dart`).
    -   **`FutureProvider`**: Extensively used for fetching asynchronous data from repositories and managing loading/error/data states in the UI (e.g., `home_providers.dart`, `schedule_providers.dart`).
    -   **`StateNotifierProvider`**: Used for managing mutable state that can change, such as the user's authentication status (`auth_providers.dart`).
    -   **`.family` Modifier**: Used to create providers that take external parameters (e.g., fetching schedules for a specific date).

-   **Repository Pattern**: Data operations are abstracted away using repositories (e.g., `AuthRepository`, `MemberRepository`). These handle the logic for fetching and pushing data, separating the application's business logic from the data sources.
    -   **Dependency Injection**: Repositories that depend on others are injected via the provider scope (e.g., `MemberRepository` receives an instance of `RelationRepository`).

-   **Service Layer**: Services (`HandwritingService`) encapsulate specific, complex business logic or third-party/platform-specific interactions. The `HandwritingService` uses conditional imports to provide different implementations for web and mobile.

-   **Data Modeling**:
    -   **Core Models**: Plain Dart objects in `lib/models/` represent the data structures (e.g., `User`, `Member`, `Schedule`). They include `copyWith`, `toJson`, and `fromJson` methods for immutability and serialization.
    -   **Relational Structure**: The data is modeled relationally. A `TrainerMemberRelation` model links a `User` (trainer) to a `Member`. `Schedule` and `PaymentLog` are then linked to this relation, not directly to the member, allowing a member to have contracts with multiple trainers.

## Key Directories

The core application logic resides within the `lib/` directory:

-   `lib/screens/`: Contains the main UI screens/pages of the application.
-   `lib/widgets/`: Holds reusable UI components. Subdirectories like `member_detail_tabs/` and `session_log/` group related widgets.
-   `lib/providers/`: Defines Riverpod providers for state management and dependency injection.
-   `lib/repositories/`: The data abstraction layer. **This is the primary area to modify for backend integration.**
-   `lib/models/`: Defines the data models and entities for the application.
-   `lib/services/`: Implements specific business logic and platform-specific code.
-   `lib/constants/`: Stores application-wide constants (colors, dimensions, text styles, assets).
-   `lib/data/`: Contains the `mock_data.dart` file, which currently serves as the database.

## Development Standards

-   **Code Style**: Adheres to the official Dart style guide, enforced by `package:flutter_lints` in `analysis_options.yaml`.
-   **Typing**: All code is strongly typed.
-   **Library Usage**:
    -   Use **Riverpod** for all state management.
    -   Use the defined **Repositories** to interact with data. UI widgets should not access `mock_data.dart` directly.
    -   Utilize constants from `lib/constants/` for consistent UI styling.

## Security Guidelines

**IMPORTANT:** As the project moves towards backend integration for authentication and login, security becomes a top priority. All development must adhere to the following principles:

-   **Secret Management:** Never hardcode API keys, tokens, or other secrets directly in the source code. Use environment variables (e.g., via `.env` files and a package like `flutter_dotenv`) to manage sensitive information. Ensure that any secret files are listed in `.gitignore`.
-   **Secure Communication:** All communication with the backend must use HTTPS. When creating the API service layer (e.g., with `dio`), ensure the base URL is `https://` and that certificate validation is not disabled in production builds.
-   **Token Handling:** Authentication tokens (e.g., JWT) received from the backend should be stored securely on the device using packages like `flutter_secure_storage`. Avoid storing them in `SharedPreferences` or other insecure locations.
-   **Input Validation:** Do not trust any data coming from the backend without validation. Similarly, validate all user input on the client side before sending it to the backend.
-   **No Sensitive Data in Logs:** Do not log sensitive information such as passwords, tokens, or personal user data in debug or production logs.

## Common Commands

-   **Install/Update Dependencies**: `flutter pub get`
-   **Run Static Analysis**: `flutter analyze`
-   **Run the App**: `flutter run`

## Workflow Guidelines

1.  **Investigate**: Before writing code, examine the relevant files. Understand which providers, repositories, and models are related to the task.
2.  **Plan**: Briefly outline the changes. Determine if a new widget, provider, or repository method is needed.
3.  **Implement**: Write the code, adhering to the established architecture.
4.  **Verify**: After implementation, run `flutter analyze` to ensure code quality.

## Change Log

### 2026-01-16

● Refactoring complete. Here's a summary of the changes:

  Files Modified:

  1. lib/widgets/session_log_widgets.dart
    - Added import: import 'package:ptlog/constants/app_assets.dart';
    - Replaced 2 occurrences of hardcoded path with AppAssets.workoutTemplateV1
  2. lib/widgets/session_log/handwriting_input_content.dart
    - Added import: import 'package:ptlog/constants/app_assets.dart';
    - Replaced 1 occurrence (default parameter) with AppAssets.workoutTemplateV1

  Verification: flutter analyze passed with no issues.