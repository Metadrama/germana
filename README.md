# germana

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API key setup (local dev)

Use one local secrets file and keep it out of git:

1. Copy `.env.example.json` to `.env.json`.
2. Put your real key in `GOOGLE_MAPS_API_KEY`.

Run with:

```bash
flutter run -d edge --dart-define-from-file=.env.json
```

```bash
flutter run -d android --dart-define-from-file=.env.json
```

Notes:

- Dart code reads `GOOGLE_MAPS_API_KEY` via `String.fromEnvironment`.
- Android manifest placeholder also reads the same key from `.env.json`
	(and still supports env var / Gradle property in CI).
- Optional: set `MALAYSIA_FUEL_PRICE_FEED_URL` to sync fuel prices from a
	remote JSON feed for fair-rate calculations.

Fuel feed JSON format (top-level or under `data`):

```json
{
	"effectiveFrom": "2026-04-20",
	"ron95": 2.05,
	"ron97": 3.18,
	"diesel": 3.26
}
```

If feed is missing/unreachable/invalid, app automatically falls back to bundled
local price snapshots.

### iOS key setup

For iOS Google Maps SDK, use an xcconfig secret file:

1. Copy `ios/Flutter/MapsKeys.xcconfig.example` to `ios/Flutter/MapsKeys.xcconfig`.
2. Set `GOOGLE_MAPS_API_KEY` in that file.

`Debug.xcconfig` and `Release.xcconfig` already include this file optionally.
The key is read from `Info.plist` (`GMSApiKey`) and initialized in `AppDelegate.swift`.

### Route request resilience

The app now applies timeout + retry behavior for route requests and timeout
handling for Places autocomplete/details to reduce transient network failures.

### Web map snippet note

The web ride map snippet now uses Google Static Maps image rendering for a real
map preview with pickup/destination markers and optional route overlay.
Ensure the **Static Maps API** is enabled for your Google Cloud project key.

The app automatically attempts web map snapshots when possible.
If Google returns an image error (for example 403 due to key restrictions),
the app automatically falls back to the route preview card for that run.

For in-app Street View on Android/iOS (WebView-based), ensure **Maps Embed API**
is also enabled for the same key.

Also note: browser builds do not call the Directions HTTP endpoint directly
(CORS blocked). The app uses a local route estimate on web for distance/time.

### Short local commands

Use one-command scripts instead of typing long flags every time:

```powershell
./scripts/run-web.cmd
```

```powershell
./scripts/run-android.cmd
```

`run-web.cmd` is the single web run command. Graphic mini maps on web are
enabled automatically when API/key setup allows them.

If you prefer PowerShell scripts, run once with bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/run-web.ps1
```

You can also run these from VS Code Tasks:

- `Run Web (env file)`
- `Run Android (env file)`

## Release commands (with env)

Use the same `.env.json` for release mode so API keys and defines are injected
the same way as debug.

Run release build directly on connected Android device:

```powershell
./scripts/run-android-release.cmd
```

Build Android APK (release):

```powershell
./scripts/build-android-apk-release.cmd
```

Build Android App Bundle (Play Store upload):

```powershell
./scripts/build-android-aab-release.cmd
```

Build Web release bundle:

```powershell
./scripts/build-web-release.cmd
```

Outputs:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- Web: `build/web/`

Note: Android/iOS release publishing still requires signing setup. These scripts
handle environment define injection (`--dart-define-from-file=.env.json`).
