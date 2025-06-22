import '/core/import_core.dart';

DatePickerThemeData get datePickerTheme {
  return DatePickerThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    headerBackgroundColor: AppColorScheme.primary,
    headerForegroundColor: AppColorScheme.onPrimary,
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorScheme.primary;
      }
      return Colors.transparent;
    }),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorScheme.onPrimary;
      }
      return AppColorScheme.getColorScheme.onSurface;
    }),
    todayBackgroundColor:
        WidgetStateProperty.all(AppColorScheme.primary.withValues(alpha: 0.15)),
    todayForegroundColor: WidgetStateProperty.all(AppColorScheme.primary),
    yearBackgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorScheme.primary;
      }
      return Colors.transparent;
    }),
    yearForegroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorScheme.onPrimary;
      }
      return AppColorScheme.getColorScheme.onSurface;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
    headerHeadlineStyle: AppTextTheme.textTheme.headlineSmall?.copyWith(
      color: AppColorScheme.onPrimary,
    ),
    headerHelpStyle: AppTextTheme.textTheme.labelLarge?.copyWith(
      color: AppColorScheme.onPrimary,
    ),
    dayStyle: AppTextTheme.textTheme.bodyMedium,
    yearStyle: AppTextTheme.textTheme.bodyMedium,
  );
}
