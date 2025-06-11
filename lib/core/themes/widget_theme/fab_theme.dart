import '/core/import_core.dart';

FloatingActionButtonThemeData get floatingActionButtonTheme {
  return FloatingActionButtonThemeData(
    backgroundColor: AppColorScheme.primary,
    foregroundColor: AppColorScheme.onPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    elevation: 6.0,
    focusElevation: 8.0,
    hoverElevation: 10.0,
    splashColor: AppColorScheme.getColorScheme.primaryContainer,
    enableFeedback: true,
    sizeConstraints: const BoxConstraints.tightFor(
      width: 56.0,
      height: 56.0,
    ),
    smallSizeConstraints: const BoxConstraints.tightFor(
      width: 40.0,
      height: 40.0,
    ),
    largeSizeConstraints: const BoxConstraints.tightFor(
      width: 96.0,
      height: 96.0,
    ),
  );
}
