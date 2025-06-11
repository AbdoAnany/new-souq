import '/core/import_core.dart';

TimePickerThemeData get timePickerTheme {
  return TimePickerThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    hourMinuteTextColor: AppColorScheme.getColorScheme.onSurface,
    hourMinuteColor: AppColorScheme.getColorScheme.surfaceVariant,
    dayPeriodTextColor: AppColorScheme.getColorScheme.onSurface,
    dayPeriodColor: AppColorScheme.getColorScheme.surfaceVariant,
    dialHandColor: AppColorScheme.primary,
    dialBackgroundColor: AppColorScheme.getColorScheme.surfaceVariant,
    dialTextColor: AppColorScheme.getColorScheme.onSurface,
    entryModeIconColor: AppColorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
  );
}
