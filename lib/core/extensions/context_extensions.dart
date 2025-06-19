import 'package:flutter/material.dart';

// Context extensions for easier access to common properties
extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  
  // Text theme
  TextTheme get textTheme => theme.textTheme;
  
  // Color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  // Screen size
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  
  // Padding
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  
  // Scaffold messenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  
  // Show snackbar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  // Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.error,
    );
  }
  
  // Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }
  
  // Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;
  
  // Safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  
  // Check if device is tablet
  bool get isTablet => screenWidth > 600;
  
  // Check if device is mobile
  bool get isMobile => screenWidth <= 600;
}
