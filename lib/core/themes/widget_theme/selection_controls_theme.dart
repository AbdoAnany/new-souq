import '/core/import_core.dart';

SwitchThemeData get switchTheme {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColorScheme.getColorScheme.onSurface.withOpacity(0.38);
      }
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary;
      }
      return AppColorScheme.getColorScheme.outline;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColorScheme.getColorScheme.onSurface.withOpacity(0.12);
      }
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary.withOpacity(0.5);
      }
      return AppColorScheme.getColorScheme.surfaceVariant;
    }),
    overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.pressed)) {
        return AppColorScheme.primary.withOpacity(0.12);
      }
      return Colors.transparent;
    }),
    splashRadius: 24.0,
  );
}

CheckboxThemeData get checkboxTheme {
  return CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColorScheme.getColorScheme.onSurface.withOpacity(0.38);
      }
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColorScheme.getColorScheme.surface;
      }
      return AppColorScheme.onPrimary;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    side: BorderSide(
      color: AppColorScheme.getColorScheme.outline,
      width: 2.0,
    ),
    splashRadius: 24.0,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

RadioThemeData get radioTheme {
  return RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return AppColorScheme.getColorScheme.onSurface.withOpacity(0.38);
      }
      if (states.contains(MaterialState.selected)) {
        return AppColorScheme.primary;
      }
      return AppColorScheme.getColorScheme.outline;
    }),
    splashRadius: 24.0,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
  );
}
