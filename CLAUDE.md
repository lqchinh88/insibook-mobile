# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InsiBook Mobile is a Flutter mobile application for searching and reading book summaries. The app connects to a backend API to search both internal book databases and Google Books API, and displays AI-generated book summaries.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS)
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis/linting
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts

### Production Builds
To build for production deployment, you must specify the environment:

**iOS App Store Release:**
```bash
flutter build ios --release --dart-define=ENVIRONMENT=production
```

**Android Play Store Release:**
```bash
flutter build apk --release --dart-define=ENVIRONMENT=production
flutter build appbundle --release --dart-define=ENVIRONMENT=production
```

The app uses environment configuration in `lib/config/environment.dart` to switch between dev/staging/production modes. Always use `--dart-define=ENVIRONMENT=production` for store releases.

### Platform-specific Development
- **Android**: Use `flutter run` or open `android/` folder in Android Studio
- **iOS**: Use `flutter run` or open `ios/Runner.xcworkspace` in Xcode
- **Web**: `flutter run -d chrome` for web development
- **Desktop**: `flutter run -d macos/windows/linux` for desktop platforms

## Architecture Overview

### Core Structure
- **lib/main.dart**: App entry point, configures MaterialApp with BookSearchScreen as home
- **lib/models/**: Data models for API responses and book data
- **lib/services/**: API service layer for backend communication  
- **lib/screens/**: UI screens (search, details, summary reader)
- **lib/widgets/**: Reusable UI components

### Key Models
- `InternalBookItem`: Books from internal database with summary metadata
- `BookSearchItem`: Google Books API search results
- `BookWithSummary`: Complete book data with generated AI summaries
- `Summary`/`SummaryChapter`: Structure for book summary content

### API Integration
The app connects to a backend API at `localhost:3000` (configurable in `BookApiService.baseUrl`):
- `/books/search/internal` - Search internal book database
- `/books/search/google` - Search via Google Books API proxy
- `/book-summaries/generate-async` - Trigger async summary generation
- `/books/:id` - Fetch complete book with summary

### State Management
Uses Flutter's built-in StatefulWidget pattern. Search screen manages:
- Book search results from both internal and Google APIs
- Pagination for large result sets
- Loading states and error handling
- Search input validation

## Code Conventions

- Uses Material 3 design system (`useMaterial3: true`)
- Follows Flutter/Dart linting rules from `flutter_lints` package
- Null safety enabled (SDK ^3.8.1)
- Factory constructors for JSON deserialization
- Async/await pattern for API calls with try-catch error handling

### Anti-Patterns to Avoid

**❌ Never call data loading functions inside Consumer builders:**
```dart
// BAD - Creates infinite retry loops on API failures
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(); // This will be called on every rebuild!
      });
    }
    return SomeWidget();
  },
)
```

**✅ Use flags to prevent repeated calls:**
```dart
// GOOD - Prevents infinite loops
bool _hasTriggeredLoad = false;

Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isAuthenticated && !_hasTriggeredLoad) {
      _hasTriggeredLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(); // Called only once
      });
    }
    return SomeWidget();
  },
)
```

**Why this matters:** When API calls fail, they can trigger widget rebuilds. If data loading is inside a Consumer builder, it creates an infinite loop of API calls → failures → rebuilds → more API calls, causing UI flashing and poor UX.

## Testing

- Test files located in `test/` directory
- Run tests with `flutter test`
- Widget tests use `flutter_test` package
- Current test coverage includes basic smoke test for main app widget

## API Configuration

Update `BookApiService.baseUrl` in `lib/services/book_api_service.dart` to point to your backend:
- Development: `http://localhost:3000`
- Production: Update to your deployed API URL

The app expects the backend to handle CORS for mobile requests and provide the specified endpoint structure.

## Steering Documents

Additional guidance documents are available in `.claude/steering/` to provide focused direction for AI assistants:

- **`.claude/steering/product.md`** - Product purpose, core features, business logic rules, and user value proposition
- **`.claude/steering/tech.md`** - Tech stack, architecture patterns, API configuration, and development commands  
- **`.claude/steering/structure.md`** - Directory organization, file naming conventions, and component architecture

- Use best practices for naming, architecture, flow. Inform me when I stray out of path. Work with scale in mind
- never build widget in state, create separate widget file for reusability
- never try to flutter run
- Dont be sycophant. Fight back when i'm wrong. If you dont understand the problem enough, clarify.