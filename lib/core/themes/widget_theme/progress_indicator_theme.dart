import 'package:souq/core/import_core.dart';

ProgressIndicatorThemeData get progressIndicatorTheme {
  return ProgressIndicatorThemeData(
    color: AppColorScheme.primary,
    linearTrackColor: AppColorScheme.getColorScheme.surfaceVariant,
    circularTrackColor: AppColorScheme.getColorScheme.surfaceVariant,
    refreshBackgroundColor: AppColorScheme.getColorScheme.surface,
  );
}
