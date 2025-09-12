import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Base URL untuk API
  static const String localhostUrl = 'http://127.0.0.1:8000/api'; // Local Development
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  static const String iosSimulatorUrl = 'http://localhost:8000/api'; // iOS Simulator
  static const String prodBaseUrl = 'https://your-domain.com/api'; // Production
  
  // Pilih base URL berdasarkan platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform
      return localhostUrl;
    } else if (Platform.isAndroid) {
      // Android platform
      return androidEmulatorUrl;
    } else if (Platform.isIOS) {
      // iOS platform
      return iosSimulatorUrl;
    } else {
      // Desktop platform
      return localhostUrl;
    }
  }
  
  // Timeout untuk HTTP requests
  static const Duration httpTimeout = Duration(seconds: 10);
  
  // App version
  static const String appVersion = '1.0.0';
  
  // App name
  static const String appName = 'Finote';
}
