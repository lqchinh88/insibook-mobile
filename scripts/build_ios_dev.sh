#!/bin/bash

echo "🍎 Building iOS for Development Environment..."
echo

# Clean previous builds
flutter clean
flutter pub get

# Build iOS with development environment
flutter build ios --dart-define=ENVIRONMENT=dev --debug

echo
echo "✅ iOS Development build completed!"
echo "📍 Open ios/Runner.xcworkspace in Xcode and select Dev scheme"