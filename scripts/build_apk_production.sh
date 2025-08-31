#!/bin/bash

echo "📱 Building Android APK for Production Environment..."
echo

# Build production APK
flutter build apk --dart-define=ENVIRONMENT=production --flavor production --release

echo
echo "✅ Production APK build completed!"
echo "📍 APK Location: build/app/outputs/flutter-apk/app-production-release.apk"