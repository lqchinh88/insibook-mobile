#!/bin/bash

echo "🚀 Building InsiBook Mobile for Production Environment..."
echo

# Run production build
flutter run --dart-define=ENVIRONMENT=production --flavor production --release

echo
echo "✅ Production build completed!"