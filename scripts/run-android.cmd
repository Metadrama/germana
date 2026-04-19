@echo off
cd /d "%~dp0.."
flutter run -d android --dart-define-from-file=.env.json
