import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _themeModeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
    state = themeMode;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
  bool get isLightMode => state == ThemeMode.light;
  bool get isSystemMode => state == ThemeMode.system;
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
