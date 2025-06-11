// lib/core/config/app_config.dart

import '/core/import_core.dart';

enum Environment { dev, staging, prod }

final appConfig = AppConfig.instance;

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final String appName;
  final String? appVersion;
// Use the navigator key from NavigationService
//   final GlobalKey<NavigatorState> navigatorKey = NavigationService.instance.navigatorKey;

  final ThemeController? themeController;
  static AppConfig? _instance;
  factory AppConfig({
    required Environment environment,
    required String apiBaseUrl,
    bool enableLogging = false,
    String appName = 'My App',
    String appVersion = '1.0.0',
    ThemeController? themeController,
  }) {
    _instance ??= AppConfig._internal(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableLogging: enableLogging,
      appName: appName,
      appVersion: appVersion,
      themeController: themeController,
    );
    return _instance!;
  }

  AppConfig._internal({
    this.environment = Environment.dev,
    this.apiBaseUrl = '',
    this.themeController,
    this.enableLogging = false,
    this.appName = 'AbdoAnny',
    this.appVersion = '1.0.0',
  });

  static AppConfig get instance => _instance!;

  bool get isProduction => environment == Environment.prod;
  bool get isDevelopment => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
}
