import 'package:souq/core/import_core.dart';

import '../../app_config.dart';



class AppColorScheme {
  // Light theme colors - refined palette
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3A7BF7), // Vibrant blue
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBE6FF), // Light blue tint
    onPrimaryContainer: Color(0xFF0A2E63),
    secondary: Color(0xFF4D5D6A), // Slate blue-gray
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDAE4F3), // Light slate tint
    onSecondaryContainer: Color(0xFF1A2836),
    tertiary: Color(0xFF795AA3), // Rich purple
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEEE1FF), // Light purple tint
    onTertiaryContainer: Color(0xFF2E1D45),
    error: Color(0xFFE53935), // Vibrant red
    onError: Colors.white,
    errorContainer: Color(0xFFFFDBD7), // Light red tint
    onErrorContainer: Color(0xFF410002),
    surface: Colors.white,
    onSurface: Color(0xFF21272D), // Dark gray for text
    surfaceContainerHighest: Color(0xFFF8F8F8), // Very light gray
    onSurfaceVariant: Color(0xFF43484F), // Medium gray
    outline: Color(0xFFE7EBEF), // Light gray outline
    shadow: Color(0x40000000), // Semi-transparent shadow
    inverseSurface: Color(0xFF102A37), // Dark navy background
    onInverseSurface: Color(0xFFEBF8FF), // Light blue-white text
    inversePrimary: Color(0xFF9FC9FF), // Lighter blue
    surfaceTint: Color(0xFF3A7BF7),

    // Same as primary
  );

  // Dark theme colors - refined palette
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFf5f5f5),
    // Light blue
    onPrimary: Color(0xFF00315B), // Dark blue
    primaryContainer: Color(0xFF094380), // Medium blue
    onPrimaryContainer: Color(0xFFD3E5FF), // Very light blue
    secondary: Color(0xFFBDC8DB), // Light slate
    onSecondary: Color(0xFF273241), // Dark slate
    secondaryContainer: Color(0xFF3D4C5E), // Medium slate
    onSecondaryContainer: Color(0xFFDAE2F4), // Very light slate
    tertiary: Color(0xFFD8BBF0), // Light purple
    onTertiary: Color(0xFF382A4D), // Dark purple
    tertiaryContainer: Color(0xFF514165), // Medium purple
    onTertiaryContainer: Color(0xFFF2DAFF), // Very light purple
    error: Color(0xFFFF8A85), // Light red
    onError: Color(0xFF601410), // Dark red
    errorContainer: Color(0xFFB3261E), // Medium red
    onErrorContainer: Color(0xFFFFDAD5), // Very light red
    background: Color(0xFF1A1D21), // Very dark gray
    onBackground: Color(0xFFE2E4E9), // Very light gray text
    surface: Color(0xFF252A31), // Dark gray
    onSurface: Color(0xFFE2E4E9), // Very light gray text
    onSurfaceVariant: Color(0xFFBDC1C9), // Light gray text
    outline: Color(0xFF8C9199), // Medium gray outline
    shadow: Color(0x77000000), // Semi-transparent shadow
    inverseSurface: Color(0xFFE2E4E9), // Very light gray
    onInverseSurface: Color(0xFF1A1D21), // Very dark gray text
    inversePrimary: Color(0xFF3A7BF7), // Same as light theme primary
    surfaceTint: Color(0xFF8ABDFF), // Same as primary
  );

  // Almond/AMOLED theme colors - refined palette
  static const ColorScheme _almondColorScheme = ColorScheme(
    brightness: Brightness.dark,
    background: Colors.black,
    onBackground: Color(0xFFE0E0E0), // Light gray text
    surface: Color(0xFF121212), // Near-black surface
    onSurface: Color(0xFFE0E0E0), // Light gray text
    primary: Color(0xFFFFBE18), // Soft purple
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF3C3047), // Dark purple
    onPrimaryContainer: Color(0xFFE8D8FF), // Light purple
    secondary: Color(0xFF03DAC6), // Teal accent
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF003731), // Dark teal
    onSecondaryContainer: Color(0xFFBDFFF7), // Light teal
    tertiary: Color(0xFFCF6679), // Rose
    onTertiary: Colors.black,
    tertiaryContainer: Color(0xFF632B3A), // Dark rose
    onTertiaryContainer: Color(0xFFFFD8DF), // Light rose
    error: Color(0xFFCF6679), // Rose as error too
    onError: Colors.black,
    errorContainer: Color(0xFF632B3A), // Dark rose
    onErrorContainer: Color(0xFFFFD8DF), // Light rose
    surfaceVariant: Color(0xFF1C1C1C), // Slightly lighter than surface
    onSurfaceVariant: Color(0xFFBBBBBB), // Medium gray text
    outline: Color(0xFF444444), // Dark gray outline
    shadow: Color(0x99000000), // Semi-transparent shadow
    inverseSurface: Color(0xFFE0E0E0), // Light gray
    onInverseSurface: Colors.black,
    inversePrimary: Color(0xFF6A36B3), // Medium purple
    surfaceTint: Color(0xFFBB86FC), // Same as primary
  );

  // Get ColorScheme based on AppThemeMode
  static ColorScheme get getColorScheme {
    AppThemeMode mode = AppConfig.instance.themeController!.value;
    switch (mode) {
      case AppThemeMode.light:
        return _lightColorScheme;
      case AppThemeMode.dark:
        return _darkColorScheme;
      case AppThemeMode.amoled:
        return _almondColorScheme;
    }
  }

  // Comprehensive helper methods for all color scheme properties
// Primary colors
  /// Main brand color used for prominent buttons, FABs, active elements.
  static Color get primary => getColorScheme.primary;

  /// Text/icons displayed on top of primary color backgrounds (e.g., button labels).
  static Color get onPrimary => getColorScheme.onPrimary;

  /// Subtle containers/cards that use the primary tone (e.g., filled cards).
  static Color get primaryContainer => getColorScheme.primaryContainer;

  /// Text/icons displayed on primaryContainer background.
  static Color get onPrimaryContainer => getColorScheme.onPrimaryContainer;

// Secondary colors
  /// Accent color for less important actions (e.g., secondary buttons, chips).
  static Color get secondary => getColorScheme.secondary;

  /// Text/icons displayed on top of secondary backgrounds.
  static Color get onSecondary => getColorScheme.onSecondary;

  /// Secondary-tinted cards, containers, banners.
  static Color get secondaryContainer => getColorScheme.secondaryContainer;

  /// Text/icons on top of secondaryContainer.
  static Color get onSecondaryContainer => getColorScheme.onSecondaryContainer;

// Tertiary colors
  /// Optional third color for complementary UI elements, badges, highlights.
  static Color get tertiary => getColorScheme.tertiary;

  /// Text/icons on tertiary backgrounds.
  static Color get onTertiary => getColorScheme.onTertiary;

  /// Tertiary-tinted backgrounds for cards, modals.
  static Color get tertiaryContainer => getColorScheme.tertiaryContainer;

  /// Text/icons on tertiaryContainer.
  static Color get onTertiaryContainer => getColorScheme.onTertiaryContainer;

// Error colors
  /// Indicate errors (form validation, error banners, snackbars).
  static Color get error => getColorScheme.error;

  /// Text/icons shown on error backgrounds.
  static Color get onError => getColorScheme.onError;

  /// Background color for softer error displays (e.g., warning cards).
  static Color get errorContainer => getColorScheme.errorContainer;

  /// Text/icons for errorContainer background.
  static Color get onErrorContainer => getColorScheme.onErrorContainer;

// Background colors
// Surface colors
  /// Base color for cards, sheets, menus (typically white or near-white).
  static Color get surface => getColorScheme.surface;

  /// Text/icons shown on surface backgrounds.
  static Color get onSurface => getColorScheme.onSurface;

  /// Text/icons displayed on surfaceVariant.
  static Color get onSurfaceVariant => getColorScheme.onSurfaceVariant;

  /// Deepest elevated surface (e.g., popups, modals).
  /// Alternate surface color for different card types (e.g., filled vs outlined).
  static Color get surfaceContainerHighest =>
      getColorScheme.surfaceContainerHighest;

  /// Tint applied during material surface transitions and interactions.
  static Color get surfaceTint => getColorScheme.surfaceTint;

// Other UI colors
  /// Borders, dividers, outlines around components.
  static Color get outline => getColorScheme.outline;

  /// Shadows under cards, floating elements.
  static Color get shadow => getColorScheme.shadow;

  /// Background when reversed (e.g., dark-on-light surfaces).
  static Color get inverseSurface => getColorScheme.inverseSurface;

  /// Text/icons for inverseSurface background.
  static Color get onInverseSurface => getColorScheme.onInverseSurface;

  /// Primary color when surfaces are inverted (used in dark mode).
  static Color get inversePrimary => getColorScheme.inversePrimary;

// Common UI element colors
  /// Card background (defaulted to surface).
  static Color get cardColor => surface;

  /// Line dividers between list items, sections.
  static Color get dividerColor => outline.withOpacity(0.5);

  /// Disabled state color for buttons, fields, etc.
  static Color get disabledColor => onSurface.withOpacity(0.38);

  /// Placeholder text, hint text in inputs.
  static Color get hintColor => onSurface.withOpacity(0.6);

// Text colors
  /// Primary text color on normal surfaces.
  static Color get textPrimary => onSurface;

  /// Less important text (e.g., subtitles, secondary info).
  static Color get textSecondary => onSurface.withOpacity(0.7);

  /// Hint text in form fields, search bars.
  static Color get textHint => onSurface.withOpacity(0.5);

  /// Disabled text (inactive fields, buttons).
  static Color get textDisabled => onSurface.withOpacity(0.38);

// Button colors
  /// Button background color (main action buttons).
  static Color get buttonColor => primary;

  /// Text color for enabled buttons.
  static Color get buttonTextColor => onPrimary;

  /// Background for disabled buttons.
  static Color get buttonDisabledColor => disabledColor;

  /// Text color for disabled buttons.
  static Color get buttonDisabledTextColor => onSurface.withOpacity(0.38);

// Icon colors
  /// Default active icon color.
  static Color get iconPrimary => onSurface;

  /// Less important icons (e.g., inactive states).
  static Color get iconSecondary => onSurface.withOpacity(0.7);

  /// Disabled icons.
  static Color get iconDisabled => onSurface.withOpacity(0.38);

  /// Highlighted/selected icons.
  static Color get iconActive => primary;

// Status colors
  /// Indicate success, completion (e.g., checkmarks, status bars).
  static Color get success => const Color(0xFF4CAF50);

  /// Indicate warnings (e.g., unsaved changes, caution).
  static Color get warning => const Color(0xFFFFC107);

  /// Informational messages (e.g., notices, tips).
  static Color get info => const Color(0xFF2196F3);

// Custom UI element colors
  /// Background color of AppBar.
  static Color get appBarColor => surface;

  /// Background color for Bottom Navigation Bar.
  static Color get bottomNavBarColor => surface;

  /// Background color for TabBar.
  static Color get tabBarColor => surface;

  /// Main page background (scaffold).
  static Color get scaffoldBackgroundColor => surface;

  /// Background color for dialogs, popups.
  static Color get dialogBackgroundColor => surface;

  /// Background color for TextFormField.
  static Color get textFormFieldBackgroundColor => surfaceContainerHighest;
  static Color get black => Colors.black;
  static Color get white => Colors.white;

  // Helper methods for color opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Helper methods for color brightness
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // Get a color with specific alpha
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }

  // Helper for gradient colors
  static List<Color> getPrimaryGradient() {
    return [primary, darken(primary, 0.2)];
  }

  static List<Color> getSecondaryGradient() {
    return [secondary, darken(secondary, 0.2)];
  }

  // Get appropriate text color for a background color
  static Color getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  // Theme brightness detection
  static bool get isDarkMode {
    return getColorScheme.brightness == Brightness.dark;
  }

  // Material state color
  static WidgetStateProperty<Color> getMaterialStateColor(Color defaultColor,
      {Color? hoverColor, Color? pressedColor}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return pressedColor ?? darken(defaultColor, 0.1);
      }
      if (states.contains(MaterialState.hovered)) {
        return hoverColor ?? lighten(defaultColor, 0.1);
      }
      return defaultColor;
    });
  }
}
