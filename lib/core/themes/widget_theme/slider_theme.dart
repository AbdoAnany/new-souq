import 'package:souq/core/import_core.dart';

SliderThemeData get sliderTheme {
  return SliderThemeData(
    activeTrackColor: AppColorScheme.primary,
    inactiveTrackColor: AppColorScheme.getColorScheme.surfaceVariant,
    thumbColor: AppColorScheme.primary,
    overlayColor: AppColorScheme.primary.withOpacity(0.2),
    valueIndicatorColor: AppColorScheme.primary,
    valueIndicatorTextStyle: AppTextStyles.textTheme.labelMedium?.copyWith(
      color: AppColorScheme.onPrimary,
    ),
    trackHeight: 4.0,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 10.0,
    ),
    overlayShape: const RoundSliderOverlayShape(
      overlayRadius: 20.0,
    ),
    trackShape: const RoundedRectSliderTrackShape(),
  );
}
