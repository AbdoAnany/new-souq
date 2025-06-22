import '/core/import_core.dart';

ChipThemeData get chipTheme {
  return ChipThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surfaceContainerHighest,
    deleteIconColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    disabledColor:
        AppColorScheme.getColorScheme.onSurface.withValues(alpha: 0.12),
    selectedColor: AppColorScheme.primary,
    secondarySelectedColor: AppColorScheme.primary.withValues(alpha: 0.7),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    labelStyle: AppTextTheme.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
    ),
    secondaryLabelStyle: AppTextTheme.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
    ),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    ),
  );
}
