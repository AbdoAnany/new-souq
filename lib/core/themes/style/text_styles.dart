// lib/core/config/themes/text_styles.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:souq/core/import_core.dart';

class AppTextTheme {
  const AppTextTheme._();
  // static const String fontFamily='';
  static final fontFamily = GoogleFonts.notoSans().fontFamily;

  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 57,
      letterSpacing: -0.25,
      color: AppColorScheme.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 45,
      color: AppColorScheme.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 36,
      color: AppColorScheme.onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 32,
      color: AppColorScheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      color: AppColorScheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: AppColorScheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      color: AppColorScheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.15,
      color: AppColorScheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
      color: AppColorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      letterSpacing: 0.15,
      color: AppColorScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: 0.25,
      color: AppColorScheme.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      letterSpacing: 0.4,
      color: AppColorScheme.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
      color: AppColorScheme.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.5,
      color: AppColorScheme.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
      color: AppColorScheme.textSecondary,
    ),
  );

  // Light theme text colors - using Material 3 conventions
  static TextTheme get textThemeLight => textTheme.apply(
        bodyColor: AppColorScheme.onSurface,
        displayColor: AppColorScheme.onSurface,
      );

  // Dark theme text colors
  static TextTheme get textThemeDark => textTheme.apply(
        bodyColor: AppColorScheme.onSurface,
        displayColor: AppColorScheme.onSurface,
      );

  // Theme-aware text colors that automatically adjust based on current theme
  static TextTheme get adaptiveTextTheme {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        color: AppColorScheme.textSecondary,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        color: AppColorScheme.onSurface,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        color: AppColorScheme.textSecondary,
      ),
    );
  }

  // Helper methods for specific text scenarios

  /// Text style for primary action buttons
  static TextStyle get primaryButtonText => textTheme.labelLarge!.copyWith(
        color: AppColorScheme.onPrimary,
        fontWeight: FontWeight.w600,
      );

  /// Text style for secondary action buttons
  static TextStyle get secondaryButtonText => textTheme.labelLarge!.copyWith(
        color: AppColorScheme.primary,
        fontWeight: FontWeight.w600,
      );

  /// Text style for disabled buttons
  static TextStyle get disabledButtonText => textTheme.labelLarge!.copyWith(
        color: AppColorScheme.textDisabled,
        fontWeight: FontWeight.w600,
      );

  /// Text style for error messages
  static TextStyle get errorText => textTheme.bodyMedium!.copyWith(
        color: AppColorScheme.error,
      );

  /// Text style for success messages
  static TextStyle get successText => textTheme.bodyMedium!.copyWith(
        color: AppColorScheme.success,
      );

  /// Text style for warning messages
  static TextStyle get warningText => textTheme.bodyMedium!.copyWith(
        color: AppColorScheme.warning,
      );

  /// Text style for info messages
  static TextStyle get infoText => textTheme.bodyMedium!.copyWith(
        color: AppColorScheme.info,
      );

  /// Text style for placeholder/hint text
  static TextStyle get hintText => textTheme.bodyMedium!.copyWith(
        color: AppColorScheme.textHint,
      );

  /// Text style for captions and metadata
  static TextStyle get captionText => textTheme.bodySmall!.copyWith(
        color: AppColorScheme.textSecondary,
      );
}
