#!/bin/bash

# Quick Start Script for True Love App
# This script helps you get started quickly with the True Love App

set -e

echo "🚀 True Love App - Quick Start Guide"
echo "===================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "📥 Download from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "📥 Download from: https://nodejs.org/"
    exit 1
fi

echo "✅ Flutter and Node.js are installed!"

# Step 1: Setup Flutter project
echo "🔧 Step 1: Setting up Flutter project..."
flutter clean
flutter pub get

# Step 2: Setup Firebase Functions
echo "🔧 Step 2: Setting up Firebase Functions..."
cd firebase/functions
npm install
cd ../..

# Step 3: Generate app icons and splash screen
echo "🎨 Step 3: Generating app icons and splash screen..."
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create

# Step 4: Build the app
echo "🏗️ Step 4: Building the app..."
flutter build apk --release

echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Set up Firebase project (firebase login && firebase init)"
echo "2. Add your AdMob App ID to AndroidManifest.xml and Info.plist"
echo "3. Run 'make deploy' to deploy Firebase Functions"
echo "4. Run 'flutter run' to start the app"
echo ""
echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 App Bundle location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "🎯 Ready to publish!"
echo "📚 Read deployment_guide.md for detailed instructions"