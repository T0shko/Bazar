#!/bin/bash

# Flutter path
FLUTTER=~/flutter/bin/flutter

echo "======================================"
echo "Bazar Sales App - Setup Script"
echo "======================================"
echo ""

# Add Flutter to PATH for this session
export PATH="$PATH:$HOME/flutter/bin"

# Run Flutter doctor
echo "Checking Flutter installation..."
$FLUTTER doctor

echo ""
echo "======================================"
echo "Setup Instructions:"
echo "======================================"
echo ""
echo "For ANDROID Testing:"
echo "1. Install Android Studio: https://developer.android.com/studio"
echo "2. Open Android Studio and install Android SDK"
echo "3. Create a virtual device (AVD) from Tools > Device Manager"
echo "4. Run: ~/flutter/bin/flutter doctor --android-licenses"
echo ""
echo "For iOS Testing (macOS only):"
echo "1. Install Xcode from App Store"
echo "2. Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
echo "3. Run: sudo xcodebuild -runFirstLaunch"
echo "4. Install CocoaPods: sudo gem install cocoapods"
echo "5. Open Simulator from Xcode > Open Developer Tool > Simulator"
echo ""
echo "For Web Testing:"
echo "1. Install Chrome browser"
echo "2. Run: ~/flutter/bin/flutter run -d chrome"
echo ""
echo "To add Flutter to your PATH permanently, add this to ~/.zshrc:"
echo 'export PATH="$PATH:$HOME/flutter/bin"'
echo ""
echo "======================================"

