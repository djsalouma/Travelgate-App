# TravelGate Attendance - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Flutter

Make sure you have Flutter SDK installed:

```bash
# Check Flutter version
flutter --version

# Should show: Flutter >=3.0.0
```

If not installed, follow: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

### Step 2: Clone the Repository

```bash
git clone https://github.com/djsalouma/Travelgate-App.git
cd Travelgate-App
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Generate Type Adapters

```bash
flutter pub run build_runner build
```

### Step 5: Run the App

Choose your platform:

```bash
# Android (requires Android Studio or connected device)
flutter run -d android

# iOS (requires Xcode and Mac)
flutter run -d ios

# Windows (requires Windows 10+ and Visual Studio)
flutter run -d windows
```

## 📱 Demo Credentials

Use these to test the app immediately:

### Admin Account
- **Email**: `admin@company.com`
- **Password**: `admin123`

### Employee Account
- **Email**: `employee@company.com`
- **Password**: `employee123`

## 🎯 Key Features to Try

### For Employees:
1. **Clock In**: Make sure you're "within radius" (mock location)
2. **Clock Out**: At the end of your shift
3. **View History**: Check your attendance history
4. **Export Data**: Export your attendance to Excel

### For Admins:
1. **Dashboard**: View today's attendance for all employees
2. **Manage Employees**: Add, edit, or deactivate employees
3. **Generate Reports**: Create and export attendance reports
4. **View Details**: Check individual employee attendance

## 📁 Project Structure

```
Travelgate-App/
├── lib/
│   ├── config/              # App configuration
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── services/            # Business logic
│   ├── routes/              # Navigation
│   ├── screens/             # UI screens
│   └── widgets/             # Reusable components
├── android/                 # Android platform
├── ios/                    # iOS platform
├── windows/                # Windows platform
├── pubspec.yaml            # Dependencies
└── README.md               # Full documentation
```

## 🔧 Configuration

Edit `lib/config/app_config.dart` to customize:

```dart
// Change these values to match your requirements
static const double geofenceRadius = 1000.0; // meters
static const int locationCheckInterval = 30; // seconds
static const int clockInGracePeriod = 15; // minutes
static const int clockOutGracePeriod = 15; // minutes

// Default working hours
static const TimeOfDay defaultCheckInTime = TimeOfDay(hour: 9, minute: 0);
static const TimeOfDay defaultCheckOutTime = TimeOfDay(hour: 17, minute: 0);
```

## 📦 Building for Release

### Android APK
```bash
flutter build apk --release
# APK will be in: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle
```bash
flutter build appbundle --release
# Bundle will be in: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Open in Xcode: ios/Runner.xcworkspace
```

### Windows
```bash
flutter build windows --release
# Executable will be in: build/windows/runner/Release/
```

## 🎨 Customization

### Add Your Company Location

Edit the default company location in `lib/providers/location_provider.dart`:

```dart
final CompanyLocation _defaultCompanyLocation = CompanyLocation(
  id: 'location_001',
  name: 'Your Company Name',
  address: 'Your Company Address',
  latitude: 37.7749,  // Update with your coordinates
  longitude: -122.4194,
  radius: AppConfig.geofenceRadius,
  companyId: 'company_001',
);
```

### Add Your Employees

The system includes mock employees. To add real employees:
1. Log in as admin
2. Go to "Manage Employees"
3. Tap the + button to add new employees

### Customize Working Hours

Each employee can have custom working hours. Edit in the employee management screen or directly in the employee model.

## 🐛 Troubleshooting

### Common Issues

**1. Location permissions not granted**
- On Android: Check app permissions in Settings
- On iOS: Go to Settings > Privacy > Location Services
- Enable location access for the app

**2. App not detecting location**
- Ensure GPS is enabled on your device
- Make sure you're outdoors or in a location with GPS signal
- Check that location permissions are granted

**3. Hive initialization errors**
```bash
flutter pub run build_runner build
```

**4. Excel export not working**
- Check storage permissions
- Ensure you have a file manager app installed
- On iOS, use the share sheet to save to Files

**5. Flutter command not found**
- Make sure Flutter is in your PATH
- Run: `export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"`

## 📚 Documentation

- **Full Documentation**: See `README.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **Customization Options**: See `ANALYSIS_OPTIONS.md`

## 💬 Support

For questions or issues:
- Check the documentation files
- Review the code comments
- Create an issue in the repository

## 🔒 Security Notes

- This is a demo app with mock authentication
- For production, implement proper authentication with Firebase or custom backend
- All location data is stored locally on the device
- No data is sent to external servers without your configuration

## ✅ Checklist Before Production

- [ ] Configure real authentication backend
- [ ] Set up your company location coordinates
- [ ] Add your employees to the system
- [ ] Configure working hours for each employee
- [ ] Test on all target platforms
- [ ] Set up proper code signing for release builds
- [ ] Configure app icons and splash screens
- [ ] Review and update privacy policy
- [ ] Test offline functionality
- [ ] Test Excel export on all platforms

---

**Happy Tracking! 🎯**

The TravelGate Attendance system is now ready for use. With its comprehensive features and cross-platform support, you can efficiently track employee attendance based on location across all your devices.
