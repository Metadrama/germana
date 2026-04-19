@echo off
cd /d "%~dp0.."
flutter run -d edge --dart-define-from-file=.env.json
