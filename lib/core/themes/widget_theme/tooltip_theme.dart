import 'package:souq/core/import_core.dart';

TooltipThemeData get tooltipTheme {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColorScheme.getColorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    ),
    textStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
      color: AppColorScheme.getColorScheme.onInverseSurface,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.mediumPadding,
      vertical: AppDimensions.smallPadding,
    ),
    preferBelow: true,
    showDuration: const Duration(seconds: 2),
    waitDuration: const Duration(milliseconds: 500),
  );
}
