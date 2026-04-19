@echo off
cd /d "%~dp0.."
setlocal

echo Building Android App Bundle (release) with env defines from .env.json...
flutter build appbundle --release --dart-define-from-file=.env.json
if errorlevel 1 exit /b 1

echo Output: build\app\outputs\bundle\release\app-release.aab
