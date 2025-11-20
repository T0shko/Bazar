# Bazar Sales Manager

A comprehensive Flutter mobile application for managing sales, products, coffee sales, and donations on both Android and iOS platforms.

## Features

### 📊 Dashboard

- Real-time overview of all sales
- Separate tracking for Products, Coffee, and Donations
- Recent sales history
- Beautiful stat cards with icons

### 🛍️ Products Management

- Add, edit, and delete products
- Set product name, price, and stock quantity
- Add optional product descriptions
- View available stock levels

### 💰 Sales Management

- Sell products with quantity selection
- Automatic calculation of totals
- Real-time inventory tracking
- Stock deduction upon sale

### ☕ Coffee Sales

- Quick entry for coffee sales
- Track coffee revenue separately
- View total coffee sales for the day

### ❤️ Donations

- Record donation amounts
- Track total donations separately
- Quick and easy donation entry

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for building

### Installation

1. Clone the repository or navigate to the project directory

2. Install dependencies:

```bash
~/flutter/bin/flutter pub get
```

3. Run the app:

```bash
# Quick test on Web (if Chrome is installed)
~/flutter/bin/flutter run -d chrome

# Or use the helper script
./run.sh

# For specific platforms (after setup - see TESTING_GUIDE.md)
~/flutter/bin/flutter run -d android  # Android
~/flutter/bin/flutter run -d ios      # iOS (macOS only)
~/flutter/bin/flutter run -d macos    # macOS Desktop

# List available devices
~/flutter/bin/flutter devices
```

**📱 For detailed mobile setup instructions, see [TESTING_GUIDE.md](TESTING_GUIDE.md)**

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── product.dart         # Product data model
│   └── sale_record.dart     # Sale record data model
├── providers/
│   └── sales_provider.dart  # State management
└── screens/
    ├── home_screen.dart      # Main dashboard
    ├── products_screen.dart  # Product management
    ├── product_form_screen.dart # Add/Edit product
    ├── sales_screen.dart     # Sales interface
    ├── coffee_screen.dart    # Coffee sales
    └── donation_screen.dart  # Donations
```

## Building for Production

### Android

```bash
~/flutter/bin/flutter build apk --release
# APK will be in: build/app/outputs/flutter-apk/app-release.apk

~/flutter/bin/flutter build appbundle --release
# AAB will be in: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
~/flutter/bin/flutter build ios --release
```

## Helper Scripts

- **./setup.sh** - Check Flutter setup and view installation instructions
- **./run.sh** - Interactive menu to run app on different platforms
- **TESTING_GUIDE.md** - Complete testing and setup documentation

## Testing

### Quick Test (No Additional Setup)

```bash
# Test on macOS Desktop
~/flutter/bin/flutter run -d macos

# Or use web browser
~/flutter/bin/flutter run -d chrome
```

### Mobile Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for complete instructions on:

1. **Setting up Android Studio** for Android testing
2. **Setting up Xcode** for iOS testing (macOS only)
3. **Physical device testing** for both platforms
4. **Troubleshooting** common issues

## Key Features Implementation

- **State Management**: Uses Provider pattern for efficient state management
- **Material Design 3**: Modern UI with Material Design 3 components
- **Cross-platform**: Single codebase for both Android and iOS
- **Real-time Updates**: All changes reflect immediately across the app
- **Intuitive Navigation**: Bottom navigation bar for easy access to main features

## Usage Tips

1. **Adding Products**: Tap the Products tab → Add button → Fill in product details
2. **Making a Sale**: Tap the Sales tab → Select a product → Enter quantity
3. **Coffee Sales**: From sales screen, use the New Sale button → Select Coffee
4. **Recording Donations**: From sales screen, use the New Sale button → Select Donation
5. **Viewing Totals**: Dashboard tab shows all totals and recent sales

## Dependencies

- `provider: ^6.1.1` - State management
- `intl: ^0.19.0` - Date formatting

## License

This project is open source and available for personal and commercial use.
