import '/core/import_core.dart';

ProgressIndicatorThemeData get progressIndicatorTheme {
  return ProgressIndicatorThemeData(
    color: AppColorScheme.primary,
    linearTrackColor: AppColorScheme.getColorScheme.surfaceContainerHighest,
    circularTrackColor: AppColorScheme.getColorScheme.surfaceContainerHighest,
    refreshBackgroundColor: AppColorScheme.getColorScheme.surface,
  );
}
