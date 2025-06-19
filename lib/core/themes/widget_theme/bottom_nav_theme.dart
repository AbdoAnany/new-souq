
import '/core/import_core.dart';

BottomNavigationBarThemeData get bottomNavigationBarTheme {
  return BottomNavigationBarThemeData(
    backgroundColor: AppColorScheme.getColorScheme.surface,
    selectedItemColor: AppColorScheme.primary,
    unselectedItemColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    selectedIconTheme: IconThemeData(
      color: AppColorScheme.primary,
      size: AppDimensions.mediumIconSize,
    ),
    unselectedIconTheme: IconThemeData(
      color: AppColorScheme.getColorScheme.onSurfaceVariant,
      size: AppDimensions.mediumIconSize,
    ),
    selectedLabelStyle: AppTextTheme.textTheme.labelSmall,
    unselectedLabelStyle: AppTextTheme.textTheme.labelSmall,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8.0,
  );
}
