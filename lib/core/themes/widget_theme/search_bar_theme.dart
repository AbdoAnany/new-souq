import '/core/import_core.dart';

SearchBarThemeData get searchBarTheme {
  return SearchBarThemeData(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColorScheme.getColorScheme.surfaceContainerHighest;
      }
      return AppColorScheme.getColorScheme.surface;
    }),
    elevation: WidgetStateProperty.all(2.0),
    shadowColor: WidgetStateProperty.all(AppColorScheme.getColorScheme.shadow),
    overlayColor:
        WidgetStateProperty.all(AppColorScheme.primary.withOpacity( 0.1)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        side: BorderSide(
            color:
                AppColorScheme.getColorScheme.outline.withOpacity( 0.3)),
      ),
    ),
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(horizontal: AppDimensions.mediumPadding),
    ),
    textStyle: WidgetStateProperty.all(AppTextTheme.textTheme.bodyMedium),
    hintStyle: WidgetStateProperty.all(
      AppTextTheme.textTheme.bodyMedium?.copyWith(
        color: AppColorScheme.getColorScheme.onSurfaceVariant,
      ),
    ),
  );
}
