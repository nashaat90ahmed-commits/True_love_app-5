# Makefile for True Love App

.PHONY: help setup build deploy clean test

# Default target
help:
	@echo "Available commands:"
	@echo "  make setup    - Initial setup"
	@echo "  make build    - Build APK and App Bundle"
	@echo "  make deploy   - Deploy to Firebase"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make test     - Run tests"

# Initial setup
setup:
	@echo "🔧 Setting up True Love App..."
	@flutter clean
	@flutter pub get
	@cd firebase/functions && npm install
	@echo "✅ Setup complete!"

# Build APK and App Bundle
build:
	@echo "🏗️ Building True Love App..."
	@flutter clean
	@flutter pub get
	@flutter build apk --release
	@flutter build appbundle --release
	@echo "✅ Build complete!"
	@echo "📱 APK: build/app/outputs/flutter-apk/app-release.apk"
	@echo "📦 App Bundle: build/app/outputs/bundle/release/app-release.aab"

# Deploy to Firebase
deploy:
	@echo "🚀 Deploying to Firebase..."
	@cd firebase/functions && firebase deploy --only functions
	@firebase deploy --only firestore:rules
	@firebase deploy --only firestore:indexes
	@echo "✅ Deploy complete!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@rm -rf .packages
	@cd firebase/functions && rm -rf node_modules/
	@echo "✅ Clean complete!"

# Run tests
test:
	@echo "🧪 Running tests..."
	@flutter test
	@echo "✅ Tests complete!"

# Run the app
run:
	@echo "▶️ Running True Love App..."
	@flutter run

# Build for iOS
ios:
	@echo "🍎 Building for iOS..."
	@flutter clean
	@flutter pub get
	@flutter build ios --release
	@echo "✅ iOS build complete!"

# Generate icons and splash screen
generate:
	@echo "🎨 Generating icons and splash screen..."
	@flutter pub run flutter_launcher_icons:main
	@flutter pub run flutter_native_splash:create
	@echo "✅ Generation complete!"

# Format code
format:
	@echo "📝 Formatting code..."
	@dart format .
	@echo "✅ Format complete!"

# Analyze code
analyze:
	@echo "🔍 Analyzing code..."
	@flutter analyze
	@echo "✅ Analysis complete!"

# Run all checks
check: format analyze test
	@echo "✅ All checks passed!"

# Build and deploy everything
all: clean setup build deploy
	@echo "🎉 All tasks complete!"