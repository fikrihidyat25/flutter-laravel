# Cihuy User App - Flutter Mobile Application

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.0%2B-blue.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Aplikasi mobile Cihuy yang memungkinkan pengguna untuk mengakses layanan dan fitur platform Cihuy melalui perangkat mobile.

## Daftar Isi

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Integration](#api-integration)
- [Development](#development)
- [Build & Deployment](#build--deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

Cihuy User App adalah aplikasi mobile cross-platform yang dibangun dengan Flutter, memberikan pengalaman pengguna yang optimal untuk:

- Mengakses konten dan layanan Cihuy
- Berinteraksi dengan komunitas
- Mengelola profil dan preferensi
- Menerima notifikasi real-time
- Menggunakan fitur-fitur platform secara mobile

### Arsitektur
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider/Riverpod/Bloc
- **Backend Integration**: REST API
- **Local Storage**: SQLite/Hive/SharedPreferences
- **Authentication**: JWT Token

## Features

### Authentication & Security
- Secure login/logout
- Biometric authentication (Fingerprint/Face ID)
- Auto-login dengan token refresh
- Password reset functionality
- Session management

### User Interface
- Material Design 3 / Cupertino
- Dark/Light theme support
- Responsive design untuk berbagai ukuran layar
- Smooth animations dan transitions
- Offline-first architecture

### Connectivity
- Real-time data synchronization
- Offline mode dengan local caching
- Background sync
- Network status monitoring
- Retry mechanism untuk failed requests

### Content & Media
- Rich content display
- Image/video viewer
- File download/upload
- Media compression
- Caching untuk media files

### Notifications
- Push notifications
- In-app notifications
- Notification preferences
- Deep linking support

### Personalization
- Customizable themes
- User preferences
- Language selection
- Accessibility features

## Requirements

### Development Requirements
- **Flutter SDK**: 3.0.0 atau lebih tinggi
- **Dart SDK**: 3.0.0 atau lebih tinggi
- **Android Studio**: 2022.1+ atau VS Code
- **Xcode**: 14.0+ (untuk iOS development)
- **Git**: 2.0+

### Platform Requirements

#### Android
- **API Level**: 21+ (Android 5.0)
- **Architecture**: arm64-v8a, armeabi-v7a, x86_64
- **RAM**: Minimum 2GB
- **Storage**: 100MB free space

#### iOS
- **iOS Version**: 11.0+
- **Architecture**: arm64, x86_64 (simulator)
- **RAM**: Minimum 2GB
- **Storage**: 100MB free space

#### Web
- **Browser**: Chrome 90+, Firefox 88+, Safari 14+
- **JavaScript**: ES6+ support
- **RAM**: Minimum 4GB

### Hardware Requirements
- **CPU**: 64-bit processor
- **RAM**: 4GB+ recommended
- **Storage**: 2GB+ free space
- **Network**: Internet connection untuk sync

## Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd cihuy/user
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install Platform Dependencies

#### Android
```bash
# Set up Android SDK
flutter doctor --android-licenses

# Install Android Studio atau VS Code dengan Flutter extension
```

#### iOS
```bash
# Install Xcode dari App Store
# Install CocoaPods
sudo gem install cocoapods

# Install iOS dependencies
cd ios && pod install && cd ..
```

### 4. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file dengan konfigurasi yang sesuai
```

### 5. Generate Code (jika menggunakan code generation)
```bash
# Generate models, services, dll
flutter packages pub run build_runner build

# Watch mode untuk development
flutter packages pub run build_runner watch
```

### 6. Run Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Configuration

### Environment Variables (.env)
```env
# API Configuration
API_BASE_URL=https://api.cihuy.com
API_VERSION=v1
API_TIMEOUT=30000

# Authentication
JWT_SECRET=your-jwt-secret
TOKEN_REFRESH_THRESHOLD=300

# Features
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_PUSH_NOTIFICATIONS=true

# Third-party Services
SENTRY_DSN=https://your-sentry-dsn
FIREBASE_PROJECT_ID=your-firebase-project
GOOGLE_MAPS_API_KEY=your-google-maps-key

# Debug
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Flutter Configuration (pubspec.yaml)
```yaml
name: cihuy_user_app
description: Cihuy User Mobile Application
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # HTTP Client
  dio: ^5.0.0
  
  # Local Storage
  shared_preferences: ^2.0.0
  sqflite: ^2.0.0
  
  # UI Components
  cupertino_icons: ^1.0.0
  material_design_icons_flutter: ^7.0.0
  
  # Utils
  intl: ^0.18.0
  url_launcher: ^6.0.0
  image_picker: ^1.0.0
```

### Platform-Specific Configuration

#### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>LSRequiresIPhoneOS</key>
<true/>
```

## Usage

### First Time Setup
1. **Download & Install**: Install aplikasi dari Play Store/App Store
2. **Launch App**: Buka aplikasi Cihuy
3. **Permissions**: Berikan izin yang diperlukan (kamera, lokasi, notifikasi)
4. **Login**: Masukkan kredensial atau daftar akun baru
5. **Onboarding**: Ikuti panduan setup awal

### Main Navigation
- **Home**: Dashboard utama dengan konten terbaru
- **Search**: Pencarian konten dan pengguna
- **Profile**: Kelola profil dan pengaturan
- **Notifications**: Lihat notifikasi dan pesan
- **Settings**: Konfigurasi aplikasi

### Core Features

#### Content Browsing
1. Scroll melalui feed konten
2. Tap untuk melihat detail
3. Like, comment, atau share
4. Bookmark konten favorit

#### User Profile
1. Navigasi ke **Profile** tab
2. Edit informasi personal
3. Upload foto profil
4. Kelola preferensi

#### Search & Discovery
1. Gunakan search bar di atas
2. Filter berdasarkan kategori
3. Sort berdasarkan relevansi/waktu
4. Save search queries

#### Notifications
1. Buka **Notifications** tab
2. Tap notifikasi untuk melihat detail
3. Mark as read/unread
4. Configure notification preferences

### Advanced Features

#### Offline Mode
- Konten tersimpan tersedia offline
- Sync otomatis saat koneksi tersedia
- Indikator status koneksi

#### Dark Mode
1. Buka **Settings** → **Appearance**
2. Pilih **Dark Mode**
3. Aplikasi akan restart dengan tema baru

#### Language Selection
1. Buka **Settings** → **Language**
2. Pilih bahasa yang diinginkan
3. Restart aplikasi untuk menerapkan

## API Integration

### Authentication Flow
```dart
// Login
final response = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Token management
await tokenManager.saveToken(response.token);
await tokenManager.saveRefreshToken(response.refreshToken);
```

### API Service Example
```dart
class ApiService {
  final Dio _dio = Dio();
  
  Future<List<Content>> getContent({int page = 1}) async {
    final response = await _dio.get(
      '/api/content',
      queryParameters: {'page': page},
    );
    
    return (response.data['data'] as List)
        .map((json) => Content.fromJson(json))
        .toList();
  }
}
```

### Error Handling
```dart
try {
  final content = await apiService.getContent();
  // Handle success
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Handle unauthorized
    await authService.logout();
  } else {
    // Handle other errors
    showErrorSnackBar(e.message);
  }
}
```

### Offline Support
```dart
class OfflineService {
  Future<List<Content>> getCachedContent() async {
    final box = await Hive.openBox('content');
    return box.values.cast<Content>().toList();
  }
  
  Future<void> cacheContent(List<Content> content) async {
    final box = await Hive.openBox('content');
    await box.clear();
    await box.addAll(content);
  }
}
```

## Development

### Project Structure
```
user/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── routes/
│   │   ├── themes/
│   │   └── constants/
│   ├── core/
│   │   ├── services/
│   │   ├── utils/
│   │   └── errors/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── home/
│   │   ├── profile/
│   │   └── settings/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   └── generated/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/
├── ios/
├── web/
└── integration_test/
```

### State Management (Provider Example)
```dart
class ContentProvider extends ChangeNotifier {
  List<Content> _content = [];
  bool _isLoading = false;
  
  List<Content> get content => _content;
  bool get isLoading => _isLoading;
  
  Future<void> loadContent() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _content = await apiService.getContent();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Testing
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Code Quality
```bash
# Format code
dart format .

# Analyze code
dart analyze

# Fix issues
dart fix --apply
```

### Debugging
```dart
// Debug prints
debugPrint('Debug message');

// Flutter Inspector
// Use Flutter Inspector in IDE

// Performance profiling
// Use Flutter DevTools
```

## Build & Deployment

### Development Build
```bash
# Debug build
flutter build apk --debug
flutter build ios --debug

# Profile build (untuk testing performance)
flutter build apk --profile
flutter build ios --profile
```

### Production Build

#### Android
```bash
# Generate signed APK
flutter build apk --release

# Generate App Bundle (untuk Play Store)
flutter build appbundle --release

# Build dengan flavor
flutter build apk --release --flavor production
```

#### iOS
```bash
# Build untuk simulator
flutter build ios --simulator

# Build untuk device
flutter build ios --release

# Archive untuk App Store
# Gunakan Xcode untuk archive dan upload
```

#### Web
```bash
# Build untuk web
flutter build web --release

# Deploy ke server
# Copy build/web/ ke web server
```

### Code Signing

#### Android
```bash
# Generate keystore
keytool -genkey -v -keystore ~/cihuy-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cihuy

# Configure signing di android/app/build.gradle
```

#### iOS
```bash
# Generate certificates di Apple Developer Portal
# Configure di Xcode
```

### CI/CD Pipeline (GitHub Actions Example)
```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Common Issues

#### 1. Build Errors
```bash
# Clean build
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor -v

# Update dependencies
flutter pub upgrade
```

#### 2. Android Build Issues
```bash
# Check Android SDK
flutter doctor --android-licenses

# Clean Gradle cache
cd android
./gradlew clean
cd ..
```

#### 3. iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Check Xcode version
xcodebuild -version
```

#### 4. Runtime Errors
- Check device logs: `flutter logs`
- Enable debug mode: `flutter run --debug`
- Use Flutter Inspector untuk UI debugging

#### 5. Performance Issues
- Use Flutter DevTools untuk profiling
- Check memory usage
- Optimize images dan assets
- Use `const` constructors

### Debug Commands
```bash
# Verbose logging
flutter run -v

# Check dependencies
flutter pub deps

# Analyze app size
flutter build apk --analyze-size

# Check for unused code
flutter analyze --no-fatal-infos
```

### Platform-Specific Issues

#### Android
- **Gradle sync issues**: Update Android Studio dan Gradle
- **Permission errors**: Check AndroidManifest.xml
- **ProGuard issues**: Update proguard-rules.pro

#### iOS
- **CocoaPods issues**: Update CocoaPods dan run `pod install`
- **Code signing**: Check certificates di Apple Developer Portal
- **Simulator issues**: Reset simulator atau restart Xcode

## Contributing

### Development Workflow
1. Fork repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes dan test thoroughly
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open Pull Request

### Code Standards
- Follow Dart/Flutter style guide
- Write comprehensive tests
- Add documentation untuk public APIs
- Use meaningful commit messages

### Testing Requirements
- Unit tests untuk business logic
- Widget tests untuk UI components
- Integration tests untuk critical flows
- Maintain minimum 80% code coverage

### Pull Request Process
- Provide detailed description
- Include screenshots untuk UI changes
- Ensure all tests pass
- Request review dari maintainers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs.cihuy.com](https://docs.cihuy.com)
- **Issues**: [GitHub Issues](https://github.com/cihuy/user/issues)
- **Email**: support@cihuy.com
- **Discord**: [Cihuy Community](https://discord.gg/cihuy)

---

**Made with love by Cihuy Team**
