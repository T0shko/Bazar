# Bazar Sales App - Testing Guide

## Quick Start Testing

### Option 1: Web Browser (Fastest - No Additional Setup Required)

If you have Chrome/Edge browser installed:

```bash
~/flutter/bin/flutter run -d chrome
```

### Option 2: macOS Desktop (Available Now)

```bash
~/flutter/bin/flutter run -d macos
```

### Option 3: Use Helper Script

```bash
./run.sh
```

## Setting Up Mobile Testing

### For Android Testing

1. **Install Android Studio**

   - Download from: https://developer.android.com/studio
   - Install and open Android Studio

2. **Install Android SDK**

   - Open Android Studio
   - Go to Settings/Preferences > Appearance & Behavior > System Settings > Android SDK
   - Install latest Android SDK

3. **Create Virtual Device (Emulator)**

   - Open Device Manager in Android Studio
   - Click "Create Device"
   - Select a phone (e.g., Pixel 7)
   - Download and select a system image (e.g., Android 14)
   - Finish and start the emulator

4. **Accept Android Licenses**

   ```bash
   ~/flutter/bin/flutter doctor --android-licenses
   ```

5. **Run the App**
   ```bash
   ~/flutter/bin/flutter run -d android
   # or use the run.sh script
   ```

### For iOS Testing (macOS Only)

1. **Install Xcode**

   - Open App Store
   - Search for "Xcode" and install (this takes a while - it's ~15GB)

2. **Set Up Xcode Command Line Tools**

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Install CocoaPods**

   ```bash
   sudo gem install cocoapods
   ```

4. **Open iOS Simulator**

   - Open Xcode
   - Go to Xcode > Open Developer Tool > Simulator
   - Or run: `open -a Simulator`

5. **Run the App**
   ```bash
   ~/flutter/bin/flutter run -d ios
   # or use the run.sh script
   ```

### For Physical Device Testing

#### Android Device:

1. Enable Developer Options on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging in Developer Options
3. Connect device via USB
4. Allow USB debugging on the device
5. Run: `~/flutter/bin/flutter run`

#### iOS Device:

1. Connect iPhone/iPad via USB
2. Open project in Xcode: `open ios/Runner.xcworkspace`
3. Select your device in Xcode
4. You may need an Apple Developer account (free or paid)
5. Click Run in Xcode or use: `~/flutter/bin/flutter run`

## Verifying Your Setup

Check your Flutter installation and available platforms:

```bash
~/flutter/bin/flutter doctor -v
```

List available devices:

```bash
~/flutter/bin/flutter devices
```

## Adding Flutter to PATH (Optional but Recommended)

Add this line to your `~/.zshrc` file:

```bash
export PATH="$PATH:$HOME/flutter/bin"
```

Then reload your shell:

```bash
source ~/.zshrc
```

After this, you can use `flutter` instead of `~/flutter/bin/flutter`

## Troubleshooting

### "No devices found"

- Make sure emulator/simulator is running
- For physical devices, check USB connection and enable debugging

### Android build errors

- Run: `~/flutter/bin/flutter clean`
- Then: `~/flutter/bin/flutter pub get`
- Try again: `~/flutter/bin/flutter run`

### iOS build errors

- Clean build: `~/flutter/bin/flutter clean`
- Delete ios/Pods folder and Podfile.lock
- Run: `cd ios && pod install && cd ..`
- Try again: `~/flutter/bin/flutter run -d ios`

### Web not working

- Ensure Chrome is installed
- Try: `~/flutter/bin/flutter run -d chrome --web-renderer html`

## Building for Release

### Android APK

```bash
~/flutter/bin/flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
~/flutter/bin/flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires Xcode and Apple Developer account)

```bash
~/flutter/bin/flutter build ios --release
# Then archive and distribute from Xcode
```

## Testing the App Features

Once running, test these features:

1. **Dashboard Tab**

   - View sales overview
   - Check totals for Products, Coffee, and Donations

2. **Products Tab**

   - Add a new product (tap + button)
   - Edit a product (tap edit icon)
   - Delete a product (long press)

3. **Sales Tab**

   - Select a product to sell
   - Enter quantity
   - Complete the sale
   - Verify stock is reduced

4. **Quick Sales**

   - From Sales tab, tap "New Sale" floating button
   - Test Coffee sale entry
   - Test Donation entry

5. **Verify Totals**
   - Return to Dashboard
   - Check that all totals update correctly
   - View recent sales history

## Performance Testing

- Test on both portrait and landscape orientations
- Try with many products (50+)
- Verify smooth scrolling
- Check responsiveness of buttons and forms
