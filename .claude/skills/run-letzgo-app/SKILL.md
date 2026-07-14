---
name: run-letzgo-app
description: Build, analyze, and test the LetzGo Flutter mobile app. Use when asked to build the app, run flutter analyze, take web screenshots, or verify Flutter code.
---

The LetzGo mobile app is a Flutter project at [`letzgo_app/`](../../) that builds for Android, iOS, Windows, Linux, macOS, and web. Since it's a mobile app, "running" it means analyzing, building for web, and (when available) running on a connected device or emulator.

All paths below are relative to `letzgo_app/`.

## Prerequisites

- Flutter SDK 3.x (3.44 in this environment)
- Dart 3.x

## Setup

```bash
flutter pub get
```

## Analyze

```bash
flutter analyze
```

## Build (web — best for headless verification)

```bash
flutter build web
# → Output in build/web/
```

## Build (Windows desktop)

```bash
flutter build windows
# → Output in build/windows/
```

## Run (agent path)

```bash
# Build for web to verify compilation
flutter build web

# Serve the web build for browser testing
flutter run -d web-server --web-port 8080 &
# → Web server started at http://localhost:8080

# Or use dart's http serve for the build output
dart pub global activate dhttpd
dhttpd --path build/web --port 8080 &
```

## Run (human path)

```bash
# Launch on connected device / emulator
flutter run

# Or for specific platform
flutter run -d windows    # Windows desktop
flutter run -d web        # Web (Chrome)
flutter run -d android    # Android device/emulator
```

## Test

```bash
flutter test
```

Note: no test files exist yet in the project. Running `flutter test` will find zero tests.

## Architecture overview

- **State management**: Riverpod (via `flutter_riverpod` + `riverpod_annotation`)
- **Navigation**: `go_router`
- **Networking**: `dio`
- **Maps**: `flutter_map` with `latlong2`
- **Location**: `geolocator` / `geocoding`
- **Auth**: Firebase (`firebase_auth`, `firebase_messaging`)
- **Storage**: `shared_preferences`, `flutter_secure_storage`

## Direct invocation (isolated code testing)

For testing specific Dart logic without running the full app, use `dart run`:

```bash
# Run a specific Dart file
cd letzgo_app
dart run lib/main.dart
```

## Gotchas

- **Firebase required for auth.** `firebase_core` must be initialized. On web this requires `firebase-config.js`; on mobile it requires platform-specific config files (`google-services.json`, `GoogleService-Info.plist`).
- **No test files yet.** `flutter test` will succeed trivially — test coverage is not established.
- **Web build may have platform-specific issues.** Plugins like `geolocator`, `firebase_messaging`, and `flutter_secure_storage` have limited web support. For full verification, build for the target platform.
- **Riverpod code generation.** If you modify providers with `@riverpod`, run `dart run build_runner build` to regenerate `.g.dart` files.
- **JSON serialization.** If you modify model classes with `@JsonSerializable`, run `dart run build_runner build` to regenerate `.g.dart` files.

## Troubleshooting

- **`flutter pub get` fails on stale lockfile**: delete `pubspec.lock` and retry.
- **`Analysis failed`**: run `dart fix --apply` to apply automatic fixes.
- **Missing `.g.dart` files**: the project uses `json_serializable` and `riverpod_generator`. Run `dart run build_runner build --delete-conflicting-outputs`.
- **Firebase not configured**: platform-specific Firebase configs (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) are required for running on device.
