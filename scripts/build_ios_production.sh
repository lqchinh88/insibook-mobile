#!/bin/bash

echo "🍎 Building iOS for Production (App Store)..."
echo

# Clean previous builds
flutter clean
flutter pub get

# Build iOS archive
flutter build ios --dart-define=ENVIRONMENT=production --release

echo
echo "✅ iOS Production build completed!"
echo "📍 Next: Open ios/Runner.xcworkspace in Xcode and archive for App Store"