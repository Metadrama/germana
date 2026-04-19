@echo off
cd /d "%~dp0.."
setlocal

echo Building Android APK (release) with env defines from .env.json...
flutter build apk --release --dart-define-from-file=.env.json
if errorlevel 1 exit /b 1

echo Output: build\app\outputs\flutter-apk\app-release.apk
