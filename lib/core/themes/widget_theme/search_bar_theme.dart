import '/core/import_core.dart';

SearchBarThemeData get searchBarTheme {
  return SearchBarThemeData(
    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.pressed)) {
        return AppColorScheme.getColorScheme.surfaceVariant;
      }
      return AppColorScheme.getColorScheme.surface;
    }),
    elevation: WidgetStateProperty.all(2.0),
    shadowColor: WidgetStateProperty.all(AppColorScheme.getColorScheme.shadow),
    overlayColor:
        WidgetStateProperty.all(AppColorScheme.primary.withOpacity(0.1)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        side: BorderSide(
            color: AppColorScheme.getColorScheme.outline.withOpacity(0.3)),
      ),
    ),
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(horizontal: AppDimensions.mediumPadding),
    ),
    textStyle: MaterialStateProperty.all(AppTextStyles.textTheme.bodyMedium),
    hintStyle: MaterialStateProperty.all(
      AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorScheme.getColorScheme.onSurfaceVariant,
      ),
    ),
  );
}
