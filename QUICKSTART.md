# 🚀 Quick Start Guide

## ⚡ Fastest Way to Test the App

### Option 1: Web Browser (Recommended for Quick Testing)

```bash
~/flutter/bin/flutter run -d chrome
```

_Requires Chrome or Edge browser - no mobile setup needed!_

### Option 2: macOS Desktop

```bash
~/flutter/bin/flutter run -d macos
```

_Works immediately on your Mac!_

### Option 3: Use Interactive Script

```bash
./run.sh
```

_Choose your platform from a menu_

---

## 📱 Want to Test on Mobile?

### Android Setup (15-30 minutes)

1. Download Android Studio: https://developer.android.com/studio
2. Install it and open
3. Go to Tools > Device Manager > Create Device
4. Select a phone (e.g., Pixel 7) and download system image
5. Start the emulator
6. Run: `~/flutter/bin/flutter run`

### iOS Setup (20-40 minutes, macOS only)

1. Install Xcode from App Store (~15GB)
2. Run these commands:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   sudo gem install cocoapods
   ```
3. Open Simulator: `open -a Simulator`
4. Run: `~/flutter/bin/flutter run`

**Full mobile setup guide:** See [TESTING_GUIDE.md](TESTING_GUIDE.md)

---

## ✅ What You Can Do in the App

### 1. Manage Products

- Tap **Products** tab
- Tap **+** button to add products
- Set name, price, and stock quantity
- Edit by tapping the edit icon
- Delete by long-pressing

### 2. Make Product Sales

- Tap **Sales** tab
- Tap on a product
- Enter quantity to sell
- Stock automatically updates

### 3. Record Coffee Sales

- Tap **Sales** tab
- Tap **New Sale** button (bottom right)
- Select **Coffee Sale**
- Enter the total amount

### 4. Record Donations

- Tap **Sales** tab
- Tap **New Sale** button
- Select **Donation**
- Enter the donation amount

### 5. View Dashboard

- Tap **Dashboard** tab
- See total sales for all categories
- View recent sales history

---

## 🔧 Useful Commands

```bash
# Check what's available for testing
~/flutter/bin/flutter devices

# Check Flutter setup
~/flutter/bin/flutter doctor

# Run setup helper
./setup.sh

# Clean and rebuild
~/flutter/bin/flutter clean
~/flutter/bin/flutter pub get
~/flutter/bin/flutter run

# Build release APK (Android)
~/flutter/bin/flutter build apk --release
```

---

## 💡 Pro Tips

1. **Add Flutter to PATH** to use `flutter` instead of `~/flutter/bin/flutter`:

   ```bash
   echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Hot Reload**: When app is running, press `r` in terminal to reload changes instantly

3. **Hot Restart**: Press `R` for full restart

4. **Quit**: Press `q` to stop the app

5. **Test on Multiple Platforms**: The same code runs on Android, iOS, Web, and Desktop!

---

## 🆘 Need Help?

- **General issues**: See [README.md](README.md)
- **Mobile setup**: See [TESTING_GUIDE.md](TESTING_GUIDE.md)
- **Flutter problems**: Run `~/flutter/bin/flutter doctor -v`

---

## 🎯 Current Project Status

✅ App is **fully functional** and ready to test
✅ All features implemented:

- Product management
- Sales tracking
- Coffee sales
- Donations
- Dashboard with analytics

✅ **Ready to run on:**

- ✅ Web Browser (Chrome/Edge)
- ✅ macOS Desktop
- ⏳ Android (needs Android Studio)
- ⏳ iOS (needs Xcode, macOS only)

**Start testing now with web or desktop, set up mobile later!**
