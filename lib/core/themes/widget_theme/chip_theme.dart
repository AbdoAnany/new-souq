import '/core/import_core.dart';

ChipThemeData get chipTheme {
  return ChipThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surfaceVariant,
    deleteIconColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    disabledColor: AppColorScheme.getColorScheme.onSurface.withOpacity(0.12),
    selectedColor: AppColorScheme.primary,
    secondarySelectedColor: AppColorScheme.primary.withOpacity(0.7),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    labelStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
    ),
    secondaryLabelStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
    ),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    ),
  );
}
