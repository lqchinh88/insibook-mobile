# Language Switcher Design Document

## Overview

The Language Switcher feature enables users to switch the app's interface language between English and Vietnamese. This design enhances the existing LanguageProvider to support persistence, first-time language detection, Profile tab integration, and real-time language switching without app restart. The implementation prioritizes user experience by providing immediate language changes and maintaining preferences across app sessions.

## Architecture Design

### System Architecture Diagram

```mermaid
graph TB
    A[Flutter App] --> B[Enhanced LanguageProvider]
    B --> C[SharedPreferences]
    B --> D[AppLocalizations]
    B --> E[First-Time Language Screen]
    B --> F[Profile Language Switcher]
    
    A --> G[Main Navigation Screen]
    G --> H[Profile Screen]
    H --> F
    
    D --> I[English Translations]
    D --> J[Vietnamese Translations]
    
    C --> K[Local Storage]
    E --> L[Language Selection Dialog]
    F --> L
```

### Data Flow Diagram

```mermaid
graph LR
    A[App Startup] --> B{First Time?}
    B -->|Yes| C[Show Language Selection Screen]
    B -->|No| D[Load Saved Language]
    
    C --> E[User Selects Language]
    E --> F[Save to SharedPreferences]
    F --> G[Update LanguageProvider]
    
    D --> G
    G --> H[Notify UI Listeners]
    H --> I[Update All Interface Elements]
    
    J[Profile Language Tap] --> K[Show Language Options]
    K --> E
```

## Component Design

### Enhanced LanguageProvider

**Responsibilities:**
- Manage current language state with persistence
- Handle first-time language detection and initialization
- Provide localization services to the entire app
- Notify UI components of language changes
- Fallback to default language when translations are missing

**Interfaces:**
```dart
class LanguageProvider extends ChangeNotifier {
  // State management
  String get currentLanguage;
  Locale get currentLocale;
  AppLocalizations get l10n;
  bool get isFirstLaunch;
  
  // Language operations
  Future<void> initialize();
  Future<void> setLanguage(String languageCode);
  Future<void> markFirstLaunchComplete();
  
  // Supported languages
  List<Language> getSupportedLanguages();
  Language getLanguageByCode(String code);
}
```

**Dependencies:**
- SharedPreferences for persistence
- AppLocalizations for translations
- Flutter ChangeNotifier for state management

### Language Model

**Responsibilities:**
- Define language metadata including code, native name, and flag
- Provide structured data for language selection UI

**Interfaces:**
```dart
class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;
  
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}
```

### First-Time Language Selection Screen

**Responsibilities:**
- Present language options to new users
- Handle initial language selection
- Navigate to main app after selection
- Provide accessible and intuitive language selection UI

**Interfaces:**
```dart
class FirstTimeLanguageScreen extends StatelessWidget {
  Future<void> _handleLanguageSelection(Language language);
  Widget _buildLanguageOption(Language language);
  Widget _buildLanguageList();
}
```

### Profile Language Switcher Widget

**Responsibilities:**
- Display current language in Profile tab
- Provide access to language selection dialog
- Show language change confirmation
- Integrate seamlessly with existing Profile screen

**Interfaces:**
```dart
class LanguageSwitcherTile extends StatelessWidget {
  final VoidCallback? onTap;
  Widget _buildCurrentLanguageDisplay();
  Widget _buildLanguageDialog();
}
```

### Language Selection Dialog

**Responsibilities:**
- Present available languages in a modal dialog
- Handle language selection and confirmation
- Provide immediate UI feedback
- Support both first-time and profile-initiated selections

**Interfaces:**
```dart
class LanguageSelectionDialog extends StatefulWidget {
  final Language currentLanguage;
  final Function(Language) onLanguageSelected;
  
  Widget _buildLanguageList();
  Widget _buildLanguageItem(Language language);
}
```

## Data Model

### Core Data Structure Definitions

```typescript
// Language definition
interface Language {
  code: string;           // ISO language code (e.g., 'en', 'vi')
  name: string;          // English name (e.g., 'English', 'Vietnamese')
  nativeName: string;    // Native name (e.g., 'English', 'Tiếng Việt')
  flag: string;          // Unicode flag emoji (e.g., '🇺🇸', '🇻🇳')
  locale: Locale;        // Flutter Locale object
}

// Persistence keys
interface StorageKeys {
  SELECTED_LANGUAGE: 'selected_language';
  FIRST_LAUNCH_COMPLETE: 'first_launch_complete';
}

// Provider state
interface LanguageProviderState {
  currentLanguage: string;
  isFirstLaunch: boolean;
  isInitialized: boolean;
  supportedLanguages: Language[];
}
```

### Data Model Diagrams

```mermaid
classDiagram
    class Language {
        +String code
        +String name
        +String nativeName
        +String flag
        +Locale locale
    }
    
    class LanguageProvider {
        -String _currentLanguage
        -bool _isFirstLaunch
        -bool _isInitialized
        -AppLocalizations _localizations
        -SharedPreferences _prefs
        +initialize() Future~void~
        +setLanguage(String) Future~void~
        +getSupportedLanguages() List~Language~
        +notifyListeners()
    }
    
    class AppLocalizations {
        +String locale
        +getText(String) String
        +operator[](String) String
    }
    
    LanguageProvider --> Language : uses
    LanguageProvider --> AppLocalizations : creates
    LanguageProvider --> SharedPreferences : persists to
```

## Business Process

### Process 1: App Initialization and First-Time Language Selection

```mermaid
flowchart TD
    A[App Launch] --> B[Create LanguageProvider]
    B --> C[languageProvider.initialize]
    C --> D[Load SharedPreferences]
    D --> E[prefs.getBool FIRST_LAUNCH_COMPLETE]
    E --> F{First Launch?}
    F -->|Yes| G[Set isFirstLaunch = true]
    F -->|No| H[prefs.getString SELECTED_LANGUAGE]
    
    G --> I[Use default language 'en']
    H --> J{Saved Language?}
    J -->|Yes| K[Set current language from prefs]
    J -->|No| L[Use default language 'en']
    
    I --> M[Update AppLocalizations]
    K --> M
    L --> M
    M --> N[notifyListeners]
    
    N --> O{isFirstLaunch?}
    O -->|Yes| P[Navigate to FirstTimeLanguageScreen]
    O -->|No| Q[Navigate to MainNavigationScreen]
    
    P --> R[User selects language]
    R --> S[languageProvider.setLanguage]
    S --> T[languageProvider.markFirstLaunchComplete]
    T --> U[Navigate to MainNavigationScreen]
```

### Process 2: Language Change from Profile Tab

```mermaid
sequenceDiagram
    participant User
    participant ProfileScreen
    participant LanguageSwitcherTile
    participant LanguageSelectionDialog
    participant LanguageProvider
    participant SharedPreferences
    participant UI
    
    User->>ProfileScreen: Tap Language Option
    ProfileScreen->>LanguageSwitcherTile: onTap()
    LanguageSwitcherTile->>LanguageSelectionDialog: showDialog()
    LanguageSelectionDialog->>LanguageProvider: getSupportedLanguages()
    LanguageProvider-->>LanguageSelectionDialog: List<Language>
    
    User->>LanguageSelectionDialog: Select Language
    LanguageSelectionDialog->>LanguageProvider: setLanguage(languageCode)
    LanguageProvider->>SharedPreferences: setString(SELECTED_LANGUAGE)
    LanguageProvider->>LanguageProvider: Update _localizations
    LanguageProvider->>UI: notifyListeners()
    
    UI->>ProfileScreen: Rebuild with new language
    UI->>MainNavigationScreen: Update navigation labels
    UI->>AllScreens: Update all visible text
```

### Process 3: Real-time Language Update Propagation

```mermaid
flowchart TD
    A[Language Change Triggered] --> B[languageProvider.setLanguage]
    B --> C[Update _currentLanguage]
    C --> D[Create new AppLocalizations]
    D --> E[Save to SharedPreferences]
    E --> F[notifyListeners]
    
    F --> G[Consumer Widgets Rebuild]
    G --> H[Current Screen Updates]
    G --> I[Navigation Bar Updates]
    G --> J[App Bar Updates]
    G --> K[All Visible UI Updates]
    
    H --> L[Profile Screen Text]
    I --> M[Bottom Navigation Labels]
    J --> N[App Bar Titles]
    K --> O[Buttons, Labels, Messages]
```

## Error Handling Strategy

### Language Loading Failures

```mermaid
flowchart TD
    A[Language Change Request] --> B{SharedPreferences Available?}
    B -->|No| C[Log Warning]
    C --> D[Continue with Current Language]
    B -->|Yes| E{Translation File Exists?}
    E -->|No| F[Log Missing Translation Warning]
    F --> G[Fallback to English]
    E -->|Yes| H{Valid Translation Data?}
    H -->|No| I[Log Corrupt Data Warning]
    I --> G
    H -->|Yes| J[Apply Language Successfully]
    
    G --> K[Show User Notification]
    K --> L[Maintain App Functionality]
```

### Error Handling Mechanisms

1. **Missing Translation Fallback**
   - When a translation key is missing, fall back to English text
   - Log warning for debugging purposes
   - Never show raw translation keys to users

2. **Storage Persistence Failures**
   - Continue with current session language if persistence fails
   - Show non-blocking notification to user about preference save failure
   - Attempt to retry persistence on next language change

3. **Initialization Failures**
   - Default to English language if initialization fails
   - Allow user to manually change language from Profile
   - Log detailed error information for debugging

4. **Network Independence**
   - All translations stored locally in app bundle
   - No network dependency for language switching
   - Immediate language changes without API calls

## UI/UX Specifications

### First-Time Language Selection Screen

**Design Requirements:**
- Full-screen modal with brand colors and gradient background
- Large, easily tappable language options (minimum 44pt touch target)
- Clear visual hierarchy with app logo and welcome message
- Native language names displayed prominently
- Flag emojis for visual recognition
- Smooth transition animations

**Layout Structure:**
```
┌─────────────────────────────┐
│        App Logo            │
│                           │
│     Welcome Message       │
│   "Choose your language"   │
│                           │
│  ┌─────────────────────┐   │
│  │ 🇺🇸  English        │   │
│  └─────────────────────┘   │
│                           │
│  ┌─────────────────────┐   │
│  │ 🇻🇳  Tiếng Việt     │   │
│  └─────────────────────┘   │
│                           │
└─────────────────────────────┘
```

### Profile Tab Language Switcher

**Design Requirements:**
- Consistent with existing Profile screen ListTile pattern
- Shows current language with flag and native name
- Integrates seamlessly between "Settings" and "Logout" options
- Provides clear visual feedback for current selection
- Uses existing app theming and styling

**Integration Layout:**
```
Profile Actions Section:
├── Refresh Profile
├── Settings  
├── Language (NEW)
│   ├── Icon: 🌐
│   ├── Title: "Language"
│   ├── Subtitle: Current language display
│   └── Trailing: Arrow + Current flag
└── Logout
```

### Language Selection Dialog

**Design Requirements:**
- Modal bottom sheet or dialog following Material Design guidelines
- List of available languages with radio button selection
- Current language clearly marked as selected
- Smooth animations for selection changes
- Immediate UI updates upon selection

## Technical Implementation Strategy

### Phase 1: Enhanced LanguageProvider Implementation
1. Add SharedPreferences dependency to LanguageProvider
2. Implement persistence methods (load/save language preference)
3. Add first-time detection logic
4. Enhance initialization with async loading
5. Add supported languages configuration

### Phase 2: First-Time Language Selection
1. Create FirstTimeLanguageScreen widget
2. Implement language selection UI with proper styling
3. Add navigation logic for first-time flow
4. Integrate with app startup sequence in main.dart

### Phase 3: Profile Integration
1. Create LanguageSwitcherTile widget for Profile screen
2. Add language selection dialog component
3. Integrate switcher into existing Profile screen layout
4. Ensure proper positioning between Settings and Logout

### Phase 4: Localization Enhancement
1. Expand translation coverage for all UI elements
2. Add translations for new language switcher components
3. Implement proper error messages and fallbacks
4. Test translation completeness across all screens

### Phase 5: Testing and Refinement
1. Test first-time user experience flow
2. Verify persistence across app restarts
3. Test real-time language switching on all screens
4. Validate accessibility and usability requirements

## Testing Strategy

### Unit Testing
- Test LanguageProvider state management and persistence
- Test Language model data integrity
- Test translation fallback mechanisms
- Test first-time detection logic

### Widget Testing
- Test FirstTimeLanguageScreen UI and interactions
- Test LanguageSwitcherTile rendering and tap handling
- Test LanguageSelectionDialog functionality
- Test Profile screen integration

### Integration Testing
- Test end-to-end first-time language selection flow
- Test language switching from Profile tab
- Test persistence across app restart scenarios
- Test real-time UI updates across multiple screens

### User Experience Testing
- Verify accessibility compliance for all language selection UI
- Test with both English and Vietnamese users
- Validate translation quality and completeness
- Ensure smooth animation and transition experiences

## Performance Considerations

### Memory Management
- Lazy loading of AppLocalizations instances
- Efficient translation key lookup with fallback
- Minimal memory footprint for language switching

### Storage Efficiency
- Use lightweight SharedPreferences for language storage
- Store only necessary language preference data
- Quick initialization without blocking app startup

### UI Performance
- Optimize rebuilds using Consumer widgets selectively
- Minimize unnecessary widget rebuilds during language changes
- Use efficient translation key access patterns

This design provides a comprehensive foundation for implementing the language switcher feature while maintaining the existing app architecture and ensuring a smooth user experience.