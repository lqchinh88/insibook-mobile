# Structure Steering Guide

## Directory Organization
```
lib/
├── constants/           # App-wide constants and configuration
│   ├── api_constants.dart
│   └── ui_constants.dart
├── lang/               # Internationalization and localization
│   ├── app_localizations.dart
│   ├── en.dart
│   └── vi.dart
├── models/             # Data models for API responses
│   ├── auth_models.dart
│   ├── book_models.dart
│   ├── async_summary_response.dart
│   └── user_book_request_models.dart
├── providers/          # State management with Provider pattern
│   ├── auth_provider.dart
│   ├── book_api_provider.dart
│   └── language_provider.dart
├── screens/            # Full-screen UI components
│   ├── auth/           # Authentication screens
│   ├── book_details_screen.dart
│   ├── book_search_screen.dart
│   ├── main_navigation_screen.dart
│   └── summary_reader_screen.dart
├── services/           # API and business logic layer
│   ├── api_service.dart        # Base HTTP client
│   ├── auth_service.dart       # Authentication logic
│   ├── book_api_service.dart   # Book-specific API calls
│   └── user_book_request_service.dart
├── utils/              # Helper utilities and extensions
│   ├── result.dart             # Result pattern for error handling
│   └── book_request_extensions.dart
├── widgets/            # Reusable UI components
│   ├── book_card.dart
│   ├── book_cover_image.dart
│   ├── error_message_widget.dart
│   └── progress_indicator_widget.dart
└── main.dart           # App entry point with provider setup
```

## Key File Locations
- **App Entry**: `lib/main.dart` - MultiProvider setup and MaterialApp configuration
- **Navigation**: `lib/screens/main_navigation_screen.dart` - Bottom navigation controller
- **API Base**: `lib/services/api_service.dart` - HTTP client with authentication
- **Models**: `lib/models/book_models.dart` - Core book data structures
- **Error Handling**: `lib/utils/result.dart` - Success/Failure pattern implementation

## Naming Conventions
- **Files**: snake_case.dart (e.g., `book_search_screen.dart`)
- **Classes**: PascalCase (e.g., `BookSearchScreen`, `InternalBookItem`)
- **Variables/Methods**: camelCase (e.g., `searchInternalBooks`, `bookApiProvider`)
- **Constants**: SCREAMING_SNAKE_CASE for final constants
- **Providers**: Suffix with "Provider" (e.g., `AuthProvider`, `BookApiProvider`)
- **Services**: Suffix with "Service" (e.g., `ApiService`, `BookApiService`)
- **Models**: Descriptive nouns (e.g., `BookWithSummary`, `AsyncSummaryResponse`)

## Component Architecture
- **Screens**: StatefulWidget for complex state, StatelessWidget for simple displays
- **Widgets**: Atomic, reusable components in separate files
- **Providers**: ChangeNotifier classes for state management
- **Services**: Static classes with async methods for API communication
- **Models**: Data classes with factory constructors for JSON serialization

## File Organization Rules
- Never build widgets inline - create separate widget files for reusability
- Group related functionality in dedicated directories (auth/, widgets/, etc.)
- Keep models close to the services that use them
- Separate business logic (services) from UI logic (widgets/screens)
- Use barrel exports sparingly - prefer explicit imports for clarity