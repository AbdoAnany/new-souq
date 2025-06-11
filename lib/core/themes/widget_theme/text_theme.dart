import '/core/import_core.dart';

TextTheme get textTheme {
  TextTheme baseTextTheme = AppTextStyles.textTheme;

  return TextTheme(
    displayLarge: baseTextTheme.displayLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    displayMedium: baseTextTheme.displayMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    displaySmall: baseTextTheme.displaySmall?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    titleSmall: baseTextTheme.titleSmall?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    labelSmall: baseTextTheme.labelSmall?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
  );
}
