import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    var isDisposed = false;

    ref.onDispose(() {
      isDisposed = true;
    });

    _loadSavedTheme(() => isDisposed);

    return ThemeMode.system;
  }

  Future<void> _loadSavedTheme(bool Function() isDisposed) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (isDisposed()) return;

      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (error) {
      // Keep the system theme if loading preferences fails.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Update the UI immediately.
    state = mode;

    // Save the selected theme.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    unawaited(setThemeMode(newMode));
  }
}
