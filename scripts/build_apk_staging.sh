#!/bin/bash

echo "📱 Building Android APK for Staging Environment..."
echo

# Build staging APK
flutter build apk --dart-define=ENVIRONMENT=staging --flavor staging --release

echo
echo "✅ Staging APK build completed!"
echo "📍 APK Location: build/app/outputs/flutter-apk/app-staging-release.apk"