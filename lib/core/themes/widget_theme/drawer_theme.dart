import 'package:souq/core/import_core.dart';

DrawerThemeData get drawerTheme {
  return DrawerThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    elevation: 16.0,
    scrimColor: AppColorScheme.getColorScheme.shadow.withOpacity(0.6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(AppDimensions.borderRadius),
        bottomRight: Radius.circular(AppDimensions.borderRadius),
      ),
    ),
    width: 300.0,
  );
}
