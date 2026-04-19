@echo off
cd /d "%~dp0.."
setlocal

echo Building Web (release) with env defines from .env.json...
flutter build web --release --dart-define-from-file=.env.json
if errorlevel 1 exit /b 1

echo Output: build\web\
