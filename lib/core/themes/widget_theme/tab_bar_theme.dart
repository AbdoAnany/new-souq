import 'package:souq/core/import_core.dart';

TabBarTheme get tabBarTheme {
  return TabBarTheme(
    labelColor: AppColorScheme.primary,
    unselectedLabelColor: AppColorScheme.getColorScheme.onSurfaceVariant,
    indicatorColor: AppColorScheme.primary,
    labelStyle: AppTextStyles.textTheme.labelLarge,
    unselectedLabelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w400,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    dividerColor: AppColorScheme.getColorScheme.surfaceVariant,
  );
}
