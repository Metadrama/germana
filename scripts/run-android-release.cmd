@echo off
cd /d "%~dp0.."
setlocal

set "DEVICE_ID="
for /f "tokens=1" %%i in ('adb devices ^| findstr /R /C:"device$"') do (
	if not defined DEVICE_ID set "DEVICE_ID=%%i"
)

if "%DEVICE_ID%"=="" (
	echo No Android device detected. Connect a phone or start an emulator, then retry.
	exit /b 1
)

echo Running RELEASE build on Android device: %DEVICE_ID%
flutter run --release -d %DEVICE_ID% --dart-define-from-file=.env.json
