#!/bin/bash

echo "🍎 Building iOS for Staging Environment..."
echo

# Clean previous builds
flutter clean
flutter pub get

# Build iOS with staging environment
flutter build ios --dart-define=ENVIRONMENT=staging --release

echo
echo "✅ iOS Staging build completed!"
echo "📍 Open ios/Runner.xcworkspace in Xcode and select Staging scheme for TestFlight"