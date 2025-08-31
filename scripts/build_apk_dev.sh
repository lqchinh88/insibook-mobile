#!/bin/bash

echo "📱 Building Android APK for Development Environment..."
echo

# Build development APK
flutter build apk --dart-define=ENVIRONMENT=dev --flavor dev --debug

echo
echo "✅ Development APK build completed!"
echo "📍 APK Location: build/app/outputs/flutter-apk/app-dev-debug.apk"