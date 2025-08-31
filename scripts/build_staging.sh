#!/bin/bash

echo "🚀 Building InsiBook Mobile for Staging Environment..."
echo

# Run staging build
flutter run --dart-define=ENVIRONMENT=staging --flavor staging

echo
echo "✅ Staging build completed!"