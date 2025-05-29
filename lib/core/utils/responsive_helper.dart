import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Responsive helper class for building adaptive layouts
class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static bool isMobile(BuildContext context) {
    return AppConfig.isMobileLayout(getScreenWidth(context));
  }
  
  static bool isTablet(BuildContext context) {
    return AppConfig.isTabletLayout(getScreenWidth(context));
  }
  
  static bool isDesktop(BuildContext context) {
    return AppConfig.isDesktopLayout(getScreenWidth(context));
  }
  
  /// Get appropriate grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < AppConfig.mobileBreakpoint) {
      return 2;
    } else if (width < AppConfig.tabletBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }
  
  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  /// Get constrained width for content on larger screens
  static double getConstrainedWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return screenWidth > AppConfig.maxWidth ? AppConfig.maxWidth : screenWidth;
    }
    return screenWidth;
  }
  
  /// Responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }
  
  /// Get font size that adapts to screen size
  static double getAdaptiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }
  
  /// Get icon size that adapts to screen size
  static double getAdaptiveIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize;
    } else if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.5;
    }
  }
}

/// Responsive widget that rebuilds when screen size changes
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return builder(context, isMobile, isTablet, isDesktop);
  }
}
