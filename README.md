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

### Short local commands

Use one-command scripts instead of typing long flags every time:

```powershell
./scripts/run-web.cmd
```

```powershell
./scripts/run-android.cmd
```

If you prefer PowerShell scripts, run once with bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/run-web.ps1
```

You can also run these from VS Code Tasks:

- `Run Web (env file)`
- `Run Android (env file)`
