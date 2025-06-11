import '/core/import_core.dart';

import 'input_decoration_theme.dart';

DropdownMenuThemeData get dropdownMenuTheme {
  return DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor:
          WidgetStateProperty.all(AppColorScheme.getColorScheme.surface),
      elevation: WidgetStateProperty.all(8.0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(vertical: AppDimensions.smallPadding),
      ),
    ),
    inputDecorationTheme: inputDecorationTheme,
    textStyle: AppTextStyles.textTheme.bodyMedium,
  );
}
