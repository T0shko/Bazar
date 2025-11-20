#!/bin/bash

# Flutter path
FLUTTER=~/flutter/bin/flutter

# Check if Flutter exists
if [ ! -f "$FLUTTER" ]; then
    echo "Flutter not found at $FLUTTER"
    exit 1
fi

echo "Available devices:"
$FLUTTER devices

echo ""
echo "Select platform:"
echo "1) Android"
echo "2) iOS"
echo "3) Web"
echo "4) macOS Desktop"
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo "Running on Android..."
        $FLUTTER run -d android
        ;;
    2)
        echo "Running on iOS..."
        $FLUTTER run -d ios
        ;;
    3)
        echo "Running on Web..."
        $FLUTTER run -d chrome --web-renderer html
        ;;
    4)
        echo "Running on macOS..."
        $FLUTTER run -d macos
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

