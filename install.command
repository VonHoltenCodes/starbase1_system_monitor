#!/bin/bash

# Starbase1 System Monitor - Mac Installer
# Double-click to install on macOS

cd "$(dirname "$0")"

# Make the script look nice in Terminal
printf '\e[8;25;80t'  # Resize terminal window

echo ""
echo "🖥️  Starbase1 System Monitor - Mac Installer"
echo "   Windows 95 Style System Monitoring Dashboard"
echo ""

# Check if Docker Desktop is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker Desktop is not installed"
    echo ""
    echo "Please install Docker Desktop for Mac first:"
    echo "https://docs.docker.com/desktop/mac/install/"
    echo ""
    echo "After installation:"
    echo "1. Start Docker Desktop"
    echo "2. Wait for it to fully start"
    echo "3. Double-click this installer again"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker Desktop is not running"
    echo ""
    echo "Please start Docker Desktop and try again"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "✅ Docker Desktop is running"
echo ""
echo "Installing Starbase1 System Monitor..."
echo ""

# Use the main install script
bash install.sh

echo ""
echo "🎉 Installation complete!"
echo ""
read -p "Press Enter to close this window..."