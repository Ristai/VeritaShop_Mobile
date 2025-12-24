@echo off
echo ========================================
echo   VeritaShop - Quick Start Script
echo ========================================
echo.

:: Check if MongoDB is running
echo [1/4] Checking MongoDB...
mongosh --eval "db.version()" > nul 2>&1
if %errorlevel% neq 0 (
    echo [!] MongoDB is not running. Please start MongoDB first.
    echo     Run: mongod
    pause
    exit /b 1
)
echo [OK] MongoDB is running

:: Start Backend
echo.
echo [2/4] Starting Backend Server...
cd /d "%~dp0backend"

:: Check if node_modules exists
if not exist "node_modules" (
    echo [*] Installing backend dependencies...
    call npm install
)

:: Seed database
echo [*] Seeding database...
call npm run seed

:: Start server in background
echo [*] Starting server on port 3000...
start "VeritaShop Backend" cmd /c "npm run dev"

:: Wait for server to start
timeout /t 3 > nul

:: Check if server is running
curl -s http://localhost:3000/api/products > nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Backend server failed to start
    pause
    exit /b 1
)
echo [OK] Backend server is running at http://localhost:3000

:: Go back to root
cd /d "%~dp0"

:: Install Flutter dependencies
echo.
echo [3/4] Installing Flutter dependencies...
call flutter pub get

:: Run Flutter app
echo.
echo [4/4] Starting Flutter app...
echo.
echo Choose platform:
echo   1. Android Emulator
echo   2. iOS Simulator
echo   3. Chrome (Web)
echo   4. Connected Device
echo.
set /p platform="Enter choice (1-4): "

if "%platform%"=="1" (
    echo Starting on Android...
    flutter run -d android
) else if "%platform%"=="2" (
    echo Starting on iOS...
    flutter run -d ios
) else if "%platform%"=="3" (
    echo Starting on Chrome...
    flutter run -d chrome
) else if "%platform%"=="4" (
    echo Starting on connected device...
    flutter run
) else (
    echo Invalid choice. Starting on default device...
    flutter run
)

pause
