import '/core/import_core.dart';

DialogTheme get dialogTheme {
  return DialogTheme(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    elevation: AppDimensions.dialogElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
    titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurface,
    ),
    actionsPadding: EdgeInsets.all(AppDimensions.mediumPadding),
    iconColor: AppColorScheme.primary,
  );
}
