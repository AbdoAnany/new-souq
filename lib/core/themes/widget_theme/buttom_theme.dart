import 'package:souq/core/import_core.dart';

ButtonThemeData get buttonTheme {
  return ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppDimensions.buttonBorderRadius),
      ),
    ),

    buttonColor: AppColorScheme.primary,
    // textTheme: ButtonTextTheme.primary,
  );
}

ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.primary,
        foregroundColor: AppColorScheme.onPrimary,
        textStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
          color: AppColorScheme.onPrimary,
        ),
        padding: EdgeInsets.symmetric(
            vertical: AppDimensions.buttonVerticalPadding,
            horizontal: AppDimensions.buttonHorizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
      ),
    );
