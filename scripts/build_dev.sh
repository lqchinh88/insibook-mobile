#!/bin/bash

echo "🚀 Building InsiBook Mobile for Development Environment..."
echo

# Run development build
flutter run --dart-define=ENVIRONMENT=dev --flavor dev

echo
echo "✅ Development build completed!"