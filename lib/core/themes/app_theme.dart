import '/core/themes/widget_theme/app_bar_theme.dart';

import '/core/themes/widget_theme/bottom_nav_theme.dart';
import '/core/themes/widget_theme/buttom_theme.dart';
import '/core/themes/widget_theme/card_theme.dart';
import '/core/themes/widget_theme/fab_theme.dart';
import '/core/themes/widget_theme/icon_theme.dart';
import '/core/themes/widget_theme/input_decoration_theme.dart';
import '/core/themes/widget_theme/selection_controls_theme.dart';
import '/core/themes/widget_theme/tab_bar_theme.dart';
import 'package:souq/core/import_core.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  light,
  dark,
  amoled,
}

class AppTheme {
  AppTheme._();
  static final fontFamily = GoogleFonts.sofia().fontFamily;
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColorScheme.scaffoldBackgroundColor,
      iconTheme: iconTheme,
      colorScheme: AppColorScheme.getColorScheme,
      textTheme: AppTextStyles.textTheme,
      fontFamily: fontFamily,
      appBarTheme: appBarTheme,
      buttonTheme: buttonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      tabBarTheme: tabBarTheme,
      switchTheme: switchTheme,
      checkboxTheme: checkboxTheme,
      radioTheme: radioTheme,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColorScheme.scaffoldBackgroundColor,
      iconTheme: iconTheme,
      fontFamily: fontFamily,
      colorScheme: AppColorScheme.getColorScheme,
      textTheme: AppTextStyles.textTheme,
      appBarTheme: appBarTheme,
      buttonTheme: buttonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      tabBarTheme: tabBarTheme,
      switchTheme: switchTheme,
      checkboxTheme: checkboxTheme,
      radioTheme: radioTheme,
    );
  }

  static ThemeData getAmoledTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColorScheme.scaffoldBackgroundColor,
      iconTheme: iconTheme,
      fontFamily: fontFamily,
      colorScheme: AppColorScheme.getColorScheme,
      textTheme: AppTextStyles.textTheme,
      appBarTheme: appBarTheme,
      buttonTheme: buttonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      tabBarTheme: tabBarTheme,
      switchTheme: switchTheme,
      checkboxTheme: checkboxTheme,
      radioTheme: radioTheme,
    );
  }
}

class ThemeController extends ValueNotifier<AppThemeMode> {
  static const _themeKey = 'app_theme_mode';

  ThemeController._(AppThemeMode mode) : super(mode);

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.light.index;
    final mode = AppThemeMode.values[themeIndex];
    return ThemeController._(mode);
  }

  void nextTheme() async {
    value = AppThemeMode.values[(value.index + 1) % AppThemeMode.values.length];
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeKey, value.index);
  }

  ValueNotifier<ThemeData> get mapThemeData {
    final notifier = ValueNotifier<ThemeData>(_getThemeData());

    addListener(() {
      notifier.value = _getThemeData();
    });

    return notifier;
  }

  ThemeData _getThemeData() {
    switch (value) {
      case AppThemeMode.light:
        return AppTheme.getLightTheme();
      case AppThemeMode.dark:
        return AppTheme.getDarkTheme();
      case AppThemeMode.amoled:
        return AppTheme.getAmoledTheme();
    }
  }
}

class AppAnimatedTheme extends StatelessWidget {
  final ThemeData? themeData;
  final ValueListenable<ThemeData>? themeListenable;
  final Widget Function(BuildContext context, ThemeData theme) builder;

  const AppAnimatedTheme({
    super.key,
    this.themeData,
    this.themeListenable,
    required this.builder,
  }) : assert(
          themeData != null || themeListenable != null,
          'You must provide either themeData or themeListenable!',
        );

  @override
  Widget build(BuildContext context) {
    if (themeListenable != null) {
      return ValueListenableBuilder<ThemeData>(
        valueListenable: themeListenable!,
        builder: (context, theme, _) {
          return _buildAnimatedTheme(context, theme);
        },
      );
    } else {
      return _buildAnimatedTheme(context, themeData!);
    }
  }

  Widget _buildAnimatedTheme(BuildContext context, ThemeData theme) {
    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: builder(context, theme), // Pass context and theme to the builder
    );
  }
}
