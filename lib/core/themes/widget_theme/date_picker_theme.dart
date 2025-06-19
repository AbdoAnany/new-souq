import '/core/import_core.dart';

DatePickerThemeData get datePickerTheme {
  return DatePickerThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    headerBackgroundColor: AppColorScheme.primary,
    headerForegroundColor: AppColorScheme.onPrimary,
    dayBackgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary;
      }
      return Colors.transparent;
    }),
    dayForegroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.onPrimary;
      }
      return AppColorScheme.getColorScheme.onSurface;
    }),
    todayBackgroundColor:
        MaterialStateProperty.all(AppColorScheme.primary.withOpacity(0.15)),
    todayForegroundColor: MaterialStateProperty.all(AppColorScheme.primary),
    yearBackgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary;
      }
      return Colors.transparent;
    }),
    yearForegroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
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
