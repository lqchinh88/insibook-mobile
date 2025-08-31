# Environment Configuration Setup

This document describes how to use the multi-environment build configuration for InsiBook Mobile.

## Overview

The app now supports three environments:
- **Development** (`dev`) - For local development with localhost API
- **Staging** (`staging`) - For testing with staging API
- **Production** (`production`) - For production builds with live API

## Environment Configuration

### API URLs
- **Development**: `http://localhost:3000`
- **Staging**: `https://staging-api.insibook.com`
- **Production**: `https://api.insibook.com`

### App Names & Identifiers
- **Development**: "InsiBook Dev" (`com.example.insibook_mobile.dev`)
- **Staging**: "InsiBook Staging" (`com.example.insibook_mobile.staging`)
- **Production**: "InsiBook" (`com.example.insibook_mobile`)

## Running the App

### Using VS Code
Use the pre-configured launch configurations in VS Code:
- Development
- Development (Profile)
- Development (Release)
- Staging
- Staging (Profile)
- Staging (Release)
- Production
- Production (Profile)
- Production (Release)

### Using Command Line

#### Development
```bash
flutter run --dart-define=ENVIRONMENT=dev --flavor dev
```

#### Staging
```bash
flutter run --dart-define=ENVIRONMENT=staging --flavor staging
```

#### Production
```bash
flutter run --dart-define=ENVIRONMENT=production --flavor production --release
```

### Using Helper Scripts
Execute the pre-made scripts:
```bash
# Run development
./scripts/build_dev.sh

# Run staging
./scripts/build_staging.sh

# Run production
./scripts/build_production.sh
```

## Building APKs

### Using Command Line

#### Development APK (Debug)
```bash
flutter build apk --dart-define=ENVIRONMENT=dev --flavor dev --debug
```

#### Staging APK (Release)
```bash
flutter build apk --dart-define=ENVIRONMENT=staging --flavor staging --release
```

#### Production APK (Release)
```bash
flutter build apk --dart-define=ENVIRONMENT=production --flavor production --release
```

### Using Helper Scripts
```bash
# Build development APK
./scripts/build_apk_dev.sh

# Build staging APK
./scripts/build_apk_staging.sh

# Build production APK
./scripts/build_apk_production.sh
```

## Environment Features

### Environment Banner
Non-production environments show a colored banner:
- **Development**: Green banner with "DEVELOPMENT"
- **Staging**: Orange banner with "STAGING"
- **Production**: No banner

### Debug Features
- **Development**: All debug features enabled, logging enabled
- **Staging**: Debug features disabled, logging enabled
- **Production**: All debug features and logging disabled

## File Structure

```
lib/
├── config/
│   ├── environment.dart      # Environment enum and configuration
│   └── app_config.dart       # App configuration per environment
├── services/
│   ├── token_service.dart    # Extracted token management
│   ├── api_service.dart      # Updated to use dynamic URLs
│   └── auth_service.dart     # Updated to use token service
└── widgets/
    └── environment_banner.dart # Environment banner widget

scripts/
├── build_dev.sh             # Run development build
├── build_staging.sh         # Run staging build  
├── build_production.sh      # Run production build
├── build_apk_dev.sh         # Build development APK
├── build_apk_staging.sh     # Build staging APK
└── build_apk_production.sh  # Build production APK

.vscode/
└── launch.json              # VS Code launch configurations

android/app/
└── build.gradle.kts         # Android product flavors configuration
```

## Key Changes Made

1. **Environment Configuration**: Created `EnvironmentConfig` and `AppConfig` classes
2. **Dynamic API URLs**: Removed hardcoded localhost URLs from services
3. **Token Service**: Extracted token management to avoid circular dependencies
4. **Android Flavors**: Added product flavors for different app variants
5. **Environment Banner**: Visual indicator for non-production environments
6. **Build Scripts**: Convenient scripts for building different environments
7. **VS Code Integration**: Launch configurations for easy debugging

## Notes

- The environment is determined by the `--dart-define=ENVIRONMENT=xxx` flag
- If no environment is specified, it defaults to development
- Each environment can have different API URLs, app names, and feature flags
- Android flavors ensure different app variants can be installed simultaneously