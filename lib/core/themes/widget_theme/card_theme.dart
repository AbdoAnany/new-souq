import '/core/import_core.dart';

CardThemeData get cardTheme {
  return CardThemeData(
    elevation: AppDimensions.cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    ),
    color: AppColorScheme.getColorScheme.surface,
    shadowColor: AppColorScheme.getColorScheme.shadow,
    margin: EdgeInsets.all(AppDimensions.smallMargin),
  );
}
