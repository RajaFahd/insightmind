@echo off
echo ========================================
echo InsightMind Flutter Setup
echo ========================================
echo.

echo [1/2] Installing Flutter dependencies...
call flutter pub get
echo.

echo [2/2] Setup complete!
echo.
echo IMPORTANT: Update the API base URL in lib/services/api_service.dart
echo.
echo For development:
echo   - Android Emulator: http://10.0.2.2:8000/api
echo   - iOS Simulator: http://localhost:8000/api
echo   - Physical Device: http://YOUR_IP:8000/api
echo.
echo To run the app:
echo   flutter run
echo.
pause
