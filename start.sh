#!/bin/bash

echo "========================================"
echo "  VeritaShop - Quick Start Script"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if MongoDB is running
echo -e "${YELLOW}[1/4] Checking MongoDB...${NC}"
if ! mongosh --eval "db.version()" > /dev/null 2>&1; then
    echo -e "${RED}[!] MongoDB is not running. Please start MongoDB first.${NC}"
    echo "    Run: mongod"
    exit 1
fi
echo -e "${GREEN}[OK] MongoDB is running${NC}"

# Start Backend
echo ""
echo -e "${YELLOW}[2/4] Starting Backend Server...${NC}"
cd "$SCRIPT_DIR/backend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "[*] Installing backend dependencies..."
    npm install
fi

# Seed database
echo "[*] Seeding database..."
npm run seed

# Start server in background
echo "[*] Starting server on port 3000..."
npm run dev &
BACKEND_PID=$!

# Wait for server to start
sleep 3

# Check if server is running
if ! curl -s http://localhost:3000/api/products > /dev/null 2>&1; then
    echo -e "${RED}[!] Backend server failed to start${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Backend server is running at http://localhost:3000${NC}"

# Go back to root
cd "$SCRIPT_DIR"

# Install Flutter dependencies
echo ""
echo -e "${YELLOW}[3/4] Installing Flutter dependencies...${NC}"
flutter pub get

# Run Flutter app
echo ""
echo -e "${YELLOW}[4/4] Starting Flutter app...${NC}"
echo ""
echo "Choose platform:"
echo "  1. Android Emulator"
echo "  2. iOS Simulator"
echo "  3. Chrome (Web)"
echo "  4. Connected Device"
echo ""
read -p "Enter choice (1-4): " platform

case $platform in
    1)
        echo "Starting on Android..."
        flutter run -d android
        ;;
    2)
        echo "Starting on iOS..."
        flutter run -d ios
        ;;
    3)
        echo "Starting on Chrome..."
        flutter run -d chrome
        ;;
    4)
        echo "Starting on connected device..."
        flutter run
        ;;
    *)
        echo "Invalid choice. Starting on default device..."
        flutter run
        ;;
esac

# Cleanup
echo ""
echo "Stopping backend server..."
kill $BACKEND_PID 2>/dev/null
