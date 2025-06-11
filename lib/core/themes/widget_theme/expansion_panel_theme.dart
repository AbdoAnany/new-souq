import 'package:souq/core/import_core.dart';

ExpansionTileThemeData get expansionTileTheme {
  return ExpansionTileThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    collapsedBackgroundColor: AppColorScheme.getColorScheme.surface,
    tilePadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    childrenPadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    expandedAlignment: Alignment.centerLeft,
    iconColor: AppColorScheme.primary,
    collapsedIconColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    textColor: AppColorScheme.primary,
    collapsedTextColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    shape: RoundedRectangleBorder(
      side: BorderSide(
          color: AppColorScheme.getColorScheme.outline.withOpacity(0.2)),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
    collapsedShape: RoundedRectangleBorder(
      side: BorderSide(
          color: AppColorScheme.getColorScheme.outline.withOpacity(0.2)),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
  );
}
