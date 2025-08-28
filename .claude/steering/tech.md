# Technical Steering Guide

## Tech Stack
- **Framework**: Flutter SDK ^3.8.1 with Dart
- **UI**: Material 3 design system with dark theme
- **State Management**: Provider pattern (^6.1.1) with ChangeNotifier
- **HTTP Client**: http package (^1.1.0) for API communication
- **Local Storage**: shared_preferences (^2.2.2) for token/settings persistence
- **Markdown Rendering**: markdown_widget (^2.3.2+6) for summary display
- **Testing**: flutter_test, mockito (^5.4.4), build_runner (^2.4.9)

## Architecture Patterns
- **Service Layer**: Centralized API communication through ApiService
- **Provider Pattern**: Use providers for auth state, language settings, and book data
- **Result Pattern**: Wrap API responses in Result<T> type for robust error handling
- **Model-First**: JSON serialization with factory constructors and fromJson methods

## API Configuration
- **Base URL**: `http://localhost:3000` (configurable in ApiService.baseUrl)
- **Authentication**: JWT Bearer token in Authorization headers
- **Error Handling**: Structured ApiError types for network, auth, parsing, and server errors
- **Endpoints**: RESTful API with `/books/*`, `/book-summaries/*`, `/auth/*` patterns

## Common Commands
```bash
# Development
flutter run                    # Run on connected device/emulator
flutter run -d chrome         # Run web version
flutter run -d macos         # Run desktop version

# Code Quality
flutter analyze               # Static analysis and linting
flutter test                 # Run unit and widget tests
flutter test integration/    # Run integration tests

# Build & Deploy
flutter clean                # Clean build artifacts
flutter pub get             # Install dependencies
flutter pub upgrade         # Update dependencies
flutter build apk          # Build Android APK
flutter build ios          # Build iOS app (macOS only)
```

## Development Guidelines
- **API-First**: Always check ApiService response patterns before adding new endpoints
- **Provider Usage**: Access providers via `context.read<T>()` for actions, `context.watch<T>()` for UI rebuilds
- **Error Handling**: Use Result pattern for all API calls, display user-friendly error messages
- **Testing**: Mock HTTP clients for unit tests, use integration tests for complete flows
- **Authentication**: Check AuthProvider.isLoggedIn before accessing protected features
- **Theme Consistency**: Use Material 3 dark theme colors consistently across all widgets