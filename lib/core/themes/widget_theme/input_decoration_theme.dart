import '/core/import_core.dart';

InputDecorationTheme get inputDecorationTheme {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColorScheme.textFormFieldBackgroundColor,
    contentPadding: EdgeInsets.all(AppDimensions.cardBorderRadius),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      borderSide: BorderSide(color: AppColorScheme.getColorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      borderSide: BorderSide(color: AppColorScheme.getColorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      borderSide:
          BorderSide(color: AppColorScheme.getColorScheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      borderSide: BorderSide(color: AppColorScheme.getColorScheme.error),
    ),
    labelStyle: AppTextStyles.textTheme.bodyMedium,
    hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
    ),
  );
}
