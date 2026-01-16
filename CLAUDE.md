# Project Context: ptlog

This is a Flutter application designed as a management tool for personal trainers. It helps manage members, schedules, session logs, and payments. The name "ptlog" is derived from "Personal Training Log."

## Architecture & Patterns

The project follows a layered architecture, separating concerns for better maintainability and scalability.

- **State Management**: We use **Flutter Riverpod** for state management and dependency injection. Providers are used to expose repositories and manage UI state.
- **Repository Pattern**: Data operations are abstracted away using repositories (e.g., `AuthRepository`, `MemberRepository`). These handle the logic for fetching and pushing data, separating the application's business logic from the data sources.
- **Service Layer**: Services (e.g., `HandwritingService`) encapsulate specific business logic or interactions with external systems.
- **Model Classes**: Plain Dart objects in the `lib/models/` directory represent the data structures of the application (e.g., `User`, `Member`, `Schedule`).

## Key Directories

The core application logic resides within the `lib/` directory:

- `lib/screens/`: Contains the main UI screens or pages of the application.
- `lib/widgets/`: Holds reusable UI components shared across multiple screens.
- `lib/providers/`: Defines Riverpod providers for state management and dependency injection.
- `lib/repositories/`: Contains the data abstraction layer for fetching and manipulating data.
- `lib/models/`: Defines the data models and entities for the application.
- `lib/services/`: Implements specific business logic and third-party service integrations.
- `lib/constants/`: Stores application-wide constants such as colors, dimensions, and text styles.

## Development Standards

- **Code Style**: We adhere to the official Dart style guide, enforced by the linter configuration in `analysis_options.yaml` which uses `package:flutter_lints`.
- **Typing**: All code should be strongly typed. Avoid using `dynamic` where a specific type can be inferred or defined.
- **Library Usage**:
    - Use **Riverpod** for all state management needs.
    - Use the defined **Repositories** to interact with data; do not perform direct data calls from the UI layer.
    - Utilize constants from `lib/constants/` for consistent UI styling.

## Common Commands

- **Install/Update Dependencies**:
  ```bash
  flutter pub get
  ```
- **Run the App (Debug Mode)**:
  ```bash
  flutter run
  ```
- **Run Static Analysis**: Check for code style issues and potential errors.
  ```bash
  flutter analyze
  ```
- **Run Tests**:
  ```bash
  flutter test
  ```
- **Create a Release Build**:
  ```bash
  # For Android
  flutter build apk --release

  # For Web
  flutter build web
  ```

## Workflow Guidelines

When approaching a new task, please follow this general workflow:

1.  **Investigate**: Before writing code, examine the relevant files in `lib/`. Understand which providers, repositories, and models are related to the task.
2.  **Plan**: Briefly outline the changes. Determine if a new widget, provider, or repository method is needed. Consider the impact on existing code.
3.  **Implement**: Write the code, adhering to the established architecture and development standards. Prefer creating reusable widgets and leveraging existing providers.
4.  **Verify**: After implementation, run `flutter analyze` and any relevant tests to ensure the changes are correct and do not introduce new issues.

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