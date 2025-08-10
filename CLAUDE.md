# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project named "elle" - a cross-platform mobile application built with Flutter framework. The project is currently a basic Flutter app with the default counter demo implementation.

## Key Commands

### Development
- `flutter run` - Run the app in development mode with hot reload
- `flutter run --release` - Run the app in release mode
- `flutter run -d chrome` - Run the app in Chrome browser
- `flutter run -d <device_id>` - Run on specific device

### Testing
- `flutter test` - Run all unit and widget tests
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report

### Code Quality
- `flutter analyze` - Run static analysis on Dart code
- `flutter format .` - Format all Dart files in the project
- `flutter format lib/` - Format only lib directory

### Build
- `flutter build apk` - Build Android APK
- `flutter build appbundle` - Build Android App Bundle
- `flutter build ios` - Build iOS app (requires macOS)
- `flutter build web` - Build web version
- `flutter build windows` - Build Windows app
- `flutter build macos` - Build macOS app
- `flutter build linux` - Build Linux app

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter pub outdated` - Check for outdated packages

## Project Structure

```
elle/
├── lib/
│   └── main.dart          # App entry point with MyApp and MyHomePage
├── test/
│   └── widget_test.dart   # Widget tests
├── pubspec.yaml           # Dependencies and project configuration
├── analysis_options.yaml # Linting configuration
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── web/                   # Web-specific files
├── windows/               # Windows-specific files
├── macos/                 # macOS-specific files
└── linux/                 # Linux-specific files
```

## Architecture

- **Single-file app**: Currently contains a simple counter demo in `lib/main.dart`
- **Material Design**: Uses Material Design components and theming
- **State Management**: Uses basic StatefulWidget for local state
- **Testing**: Widget tests using `flutter_test` package

## Development Notes

- The app uses Dart SDK ^3.7.2
- Linting is configured with `flutter_lints` package
- Material Design icons are enabled via `uses-material-design: true`
- The project supports all major platforms (Android, iOS, Web, Windows, macOS, Linux)
- Working directory is `elle/` - all Flutter commands should be run from this directory

## Key Files

- `lib/main.dart` - Main application entry point
- `pubspec.yaml` - Project dependencies and configuration
- `analysis_options.yaml` - Dart analyzer and linting rules
- `test/widget_test.dart` - Example widget test for the counter functionality