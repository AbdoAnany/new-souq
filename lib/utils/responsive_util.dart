import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtil {
  // Screen breakpoints
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Check device type
  static bool isMobile(BuildContext context) {
    return ScreenUtil().screenWidth <= mobileMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    return ScreenUtil().screenWidth > mobileMaxWidth &&
        ScreenUtil().screenWidth <= tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return ScreenUtil().screenWidth > tabletMaxWidth;
  }

  static bool isWeb(BuildContext context) {
    return ScreenUtil().screenWidth > mobileMaxWidth;
  }

  // Get responsive values based on screen type
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Get responsive font sizes
  static double fontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (ScreenUtil().screenWidth > tabletMaxWidth) {
      return (desktop ?? tablet ?? mobile).sp;
    } else if (ScreenUtil().screenWidth > mobileMaxWidth) {
      return (tablet ?? mobile).sp;
    } else {
      return mobile.sp;
    }
  }

  // Get responsive spacing
  static double spacing({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (ScreenUtil().screenWidth > tabletMaxWidth) {
      return (desktop ?? tablet ?? mobile).w;
    } else if (ScreenUtil().screenWidth > mobileMaxWidth) {
      return (tablet ?? mobile).w;
    } else {
      return mobile.w;
    }
  }

  // Get responsive padding
  static EdgeInsets padding({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (ScreenUtil().screenWidth > tabletMaxWidth) {
      final p = desktop ?? tablet ?? mobile;
      return EdgeInsets.fromLTRB(p.left.w, p.top.h, p.right.w, p.bottom.h);
    } else if (ScreenUtil().screenWidth > mobileMaxWidth) {
      final p = tablet ?? mobile;
      return EdgeInsets.fromLTRB(p.left.w, p.top.h, p.right.w, p.bottom.h);
    } else {
      return EdgeInsets.fromLTRB(
          mobile.left.w, mobile.top.h, mobile.right.w, mobile.bottom.h);
    }
  }

  // Get responsive grid columns
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  // Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.w;
    } else if (isTablet(context)) {
      return 800.w;
    } else {
      return double.infinity;
    }
  }

  // Get responsive container width
  static double containerWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = ScreenUtil().screenWidth;
    if (maxWidth != null && screenWidth > maxWidth) {
      return maxWidth.w;
    }
    return screenWidth;
  }

  // Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 500.w;
    } else if (isTablet(context)) {
      return 400.w;
    } else {
      return ScreenUtil().screenWidth * 0.9;
    }
  }

  // Get responsive bottom sheet height
  static double bottomSheetHeight(BuildContext context) {
    if (isDesktop(context)) {
      return ScreenUtil().screenHeight * 0.7;
    } else if (isTablet(context)) {
      return ScreenUtil().screenHeight * 0.8;
    } else {
      return ScreenUtil().screenHeight * 0.9;
    }
  }

  // Get responsive app bar height
  static double appBarHeight(BuildContext context) {
    return responsive<double>(
      context,
      mobile: 56,
      tablet: 64,
      desktop: 72,
    ).h;
  }

  // Get responsive card elevation
  static double cardElevation(BuildContext context) {
    return responsive<double>(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 6,
    );
  }

  // Get responsive border radius
  static BorderRadius borderRadius({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (ScreenUtil().screenWidth > tabletMaxWidth) {
      return BorderRadius.circular((desktop ?? tablet ?? mobile).r);
    } else if (ScreenUtil().screenWidth > mobileMaxWidth) {
      return BorderRadius.circular((tablet ?? mobile).r);
    } else {
      return BorderRadius.circular(mobile.r);
    }
  }

  // Get responsive icon size
  static double iconSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (ScreenUtil().screenWidth > tabletMaxWidth) {
      return (desktop ?? tablet ?? mobile).w;
    } else if (ScreenUtil().screenWidth > mobileMaxWidth) {
      return (tablet ?? mobile).w;
    } else {
      return mobile.w;
    }
  }

  // Get responsive button height
  static double buttonHeight(BuildContext context) {
    return responsive<double>(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    ).h;
  }

  // Get responsive text field height
  static double textFieldHeight(BuildContext context) {
    return responsive<double>(
      context,
      mobile: 56,
      tablet: 60,
      desktop: 64,
    ).h;
  }
}

// Extension for responsive widgets
extension ResponsiveWidget on Widget {
  Widget responsiveCenter({double? maxWidth}) {
    return Builder(
      builder: (context) {
        final width =
            ResponsiveUtil.containerWidth(context, maxWidth: maxWidth);
        return Center(
          child: Container(
            width: width,
            child: this,
          ),
        );
      },
    );
  }

  Widget responsivePadding({
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return Builder(
      builder: (context) {
        final padding = ResponsiveUtil.padding(
          mobile: mobile ?? const EdgeInsets.all(16),
          tablet: tablet,
          desktop: desktop,
        );
        return Padding(
          padding: padding,
          child: this,
        );
      },
    );
  }
}
