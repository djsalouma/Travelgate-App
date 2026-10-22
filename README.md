# TravelGate Attendance - Cross-Platform Attendance Tracking System

A comprehensive location-based attendance tracking system for employees, designed to work on iOS, Android, and Windows desktop platforms.

## Features

### Employee Features
- **Location-Based Clock-In/Out**: Track attendance based on 1km radius around company building
- **Real-Time Location Monitoring**: Continuous tracking of employee location
- **Attendance History**: View complete attendance history with detailed statistics
- **Working Hours Tracking**: Automatic calculation of working hours, late arrivals, and early departures
- **Notifications**: Receive reminders for clock-in/out and notifications about attendance status
- **Excel Export**: Export personal attendance data to Excel

### Admin Features
- **Employee Management**: Add, edit, deactivate, and delete employees
- **Real-Time Dashboard**: View today's attendance status for all employees
- **Comprehensive Reports**: Generate daily, weekly, monthly, and yearly attendance reports
- **Detailed Analytics**: View attendance rates, absenteeism rates, and punctuality statistics
- **Excel Export**: Export company-wide or individual employee reports to Excel
- **Search & Filter**: Easily find employees and filter attendance data

### Technical Features
- **Cross-Platform**: Works on iOS, Android, and Windows Desktop
- **Offline Support**: Local storage using Hive database
- **Geofencing**: Automatic detection when entering/exiting company radius
- **Background Location Updates**: Continuous tracking even when app is in background
- **Push Notifications**: Local notifications for important events
- **State Management**: Provider pattern for efficient state handling

## Project Structure

```
travelgate_attendance/
├── lib/
│   ├── config/
│   │   └── app_config.dart          # Application configuration
│   ├── models/
│   │   ├── attendance_model.dart    # Attendance records
│   │   ├── employee_model.dart      # Employee data
│   │   ├── location_model.dart      # Location data
│   │   └── report_model.dart        # Report generation
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state
│   │   ├── attendance_provider.dart  # Attendance management
│   │   ├── employee_provider.dart    # Employee management
│   │   └── location_provider.dart   # Location tracking
│   ├── screens/
│   │   ├── auth/                    # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── employee/                # Employee screens
│   │   │   ├── employee_dashboard.dart
│   │   │   ├── clock_in_out_screen.dart
│   │   │   └── attendance_history_screen.dart
│   │   ├── admin/                    # Admin screens
│   │   │   ├── admin_dashboard.dart
│   │   │   ├── employee_management_screen.dart
│   │   │   ├── employee_detail_screen.dart
│   │   │   └── reports_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── settings_screen.dart
│   │   └── notifications_screen.dart
│   ├── services/
│   │   ├── notification_service.dart # Notification handling
│   │   └── excel_export_service.dart # Excel export functionality
│   ├── routes/
│   │   └── app_router.dart            # Navigation routing
│   └── widgets/
│       ├── common/                   # Common widgets
│       ├── employee/                # Employee-specific widgets
│       └── admin/                    # Admin-specific widgets
├── android/                         # Android platform files
├── ios/                            # iOS platform files
├── windows/                        # Windows platform files
├── assets/                         # Static assets
├── pubspec.yaml                    # Flutter dependencies
└── README.md                       # This file
```

## Getting Started

### Prerequisites

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0
- Android Studio or Xcode (for iOS development)
- Visual Studio (for Windows development)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/djsalouma/Travelgate-App.git
cd Travelgate-App
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate Hive type adapters:**
```bash
flutter pub run build_runner build
```

4. **Run the app:**
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Windows
flutter run -d windows
```

## Platform-Specific Setup

### Android Setup

1. **Update `android/app/build.gradle`:**
   - Set the correct `applicationId`
   - Configure signing for release builds

2. **Update `AndroidManifest.xml`:**
   - Add any additional permissions needed
   - Configure notification channels

3. **Location Services:**
   - The app requires `ACCESS_FINE_LOCATION` and `ACCESS_BACKGROUND_LOCATION` permissions
   - Users will be prompted to grant these permissions on first launch

### iOS Setup

1. **Update `ios/Runner/Info.plist`:**
   - Set the correct bundle identifier
   - Configure location usage descriptions

2. **Add Background Modes:**
   - Enable "Location updates" in Background Modes
   - Enable "Remote notifications" if using push notifications

3. **Location Permissions:**
   - Add `NSLocationWhenInUseUsageDescription`
   - Add `NSLocationAlwaysAndWhenInUseUsageDescription`

### Windows Setup

1. **Enable location capabilities:**
   - Add location capability to the app manifest

2. **Configure CMakeLists.txt:**
   - Update project name and version

## Configuration

### App Configuration

Edit `lib/config/app_config.dart` to customize:

```dart
// Company settings
static const double geofenceRadius = 1000.0; // 1 kilometer
static const int locationCheckInterval = 30; // seconds
static const int clockInGracePeriod = 15; // minutes
static const int clockOutGracePeriod = 15; // minutes

// Working hours
static const TimeOfDay defaultCheckInTime = TimeOfDay(hour: 9, minute: 0);
static const TimeOfDay defaultCheckOutTime = TimeOfDay(hour: 17, minute: 0);
```

### Firebase Setup (Optional)

For cloud-based data storage and authentication:

1. Create a Firebase project
2. Add Firebase configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
3. Enable Firebase Authentication and Firestore

## Usage

### For Employees

1. **Login**: Use your company email and password
2. **Clock In**: 
   - Ensure you're within 1km of the company location
   - Tap "Clock In" button
   - Your location will be verified
3. **Clock Out**:
   - Tap "Clock Out" button at the end of your shift
   - Location verification is performed
4. **View Attendance**: Check your attendance history and statistics

### For Admins

1. **Login**: Use admin credentials
2. **Dashboard**: View real-time attendance status for all employees
3. **Manage Employees**: Add, edit, or deactivate employees
4. **Generate Reports**: Create and export attendance reports
5. **View Details**: Access detailed information for individual employees

## Demo Credentials

The app includes mock data for testing:

- **Admin**: `admin@company.com` / `admin123`
- **Employee**: `employee@company.com` / `employee123`

## Dependencies

Key dependencies used in this project:

- **State Management**: `provider`, `go_router`
- **Local Storage**: `hive`, `shared_preferences`
- **Location Services**: `geolocator`, `geofencing`, `permission_handler`
- **Notifications**: `flutter_local_notifications`
- **Excel Export**: `excel`, `path_provider`, `share_plus`
- **UI Components**: `flutter_svg`, `flutter_spinkit`, `syncfusion_flutter_charts`
- **Forms**: `flutter_form_builder`, `form_builder_validators`

## Building for Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

### Windows

```bash
# Build Windows app
flutter build windows --release
```

## Troubleshooting

### Common Issues

1. **Location permissions not granted:**
   - Ensure location services are enabled on the device
   - Grant location permissions when prompted
   - For Android, check app permissions in Settings

2. **App not detecting location:**
   - Ensure GPS is enabled
   - Check that the app has location permissions
   - Try moving to a location with better GPS signal

3. **Hive initialization errors:**
   - Run `flutter pub run build_runner build` to generate type adapters
   - Ensure Hive is properly initialized in `main.dart`

4. **Excel export not working:**
   - Check storage permissions
   - Ensure the device has a file manager app installed

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure everything works
5. Submit a pull request

## License

This project is proprietary software. All rights reserved.

## Contact

For support and inquiries:
- Email: support@travelgate.com
- Phone: +1 (555) 123-4567

---

**TravelGate Attendance System** - Simplifying attendance tracking with location intelligence.
