import 'package:souq/core/import_core.dart';

CardTheme get cardTheme {
  return CardTheme(
    elevation: AppDimensions.cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    ),
    color: AppColorScheme.getColorScheme.surface,
    shadowColor: AppColorScheme.getColorScheme.shadow,
    margin: EdgeInsets.all(AppDimensions.smallMargin),
  );
}
