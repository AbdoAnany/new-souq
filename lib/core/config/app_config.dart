import 'package:flutter/foundation.dart';

/// App configuration that adapts based on environment and platform
class AppConfig {
  // Environment
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;
  
  // Platform
  static bool get isMobile => defaultTargetPlatform == TargetPlatform.android || 
                              defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => defaultTargetPlatform == TargetPlatform.windows ||
                               defaultTargetPlatform == TargetPlatform.macOS ||
                               defaultTargetPlatform == TargetPlatform.linux;
  
  // API Configuration
  static const String baseUrl = isDevelopment 
      ? 'https://api-dev.souq.com/v1/'
      : 'https://api.souq.com/v1/';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // UI Configuration
  static double get maxWidth => isWeb ? 1200.0 : double.infinity;
  static int get gridCrossAxisCount => isWeb ? 4 : 2;
  static double get imageQuality => isWeb ? 0.8 : 1.0;
  
  // Performance Configuration
  static int get itemsPerPage => isWeb ? 20 : 10;
  static bool get enableCaching => true;
  static Duration get cacheTimeout => const Duration(minutes: 30);
  
  // Feature Flags
  static bool get enableNotifications => !isWeb;
  static bool get enableBiometrics => isMobile;
  static bool get enableOfflineMode => isMobile;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 640.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  static bool isMobileLayout(double width) => width < mobileBreakpoint;
  static bool isTabletLayout(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  static bool isDesktopLayout(double width) => width >= tabletBreakpoint;
}
