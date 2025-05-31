import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('ThemeProvider');
const String _themePrefsKey = 'app_theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(SharedPreferences.getInstance());
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefsFuture) : super(ThemeMode.system) {
    _loadThemePreference();
  }

  SharedPreferences? _prefs;
  final Future<SharedPreferences> _prefsFuture;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      _log.info("Setting theme mode to: $mode");
      try {
        _prefs ??= await _prefsFuture;
        await _prefs?.setString(_themePrefsKey, mode.name);
        _log.info("Saved theme preference: $mode");
      } catch (e, stackTrace) {
        _log.severe("Error saving theme preference", e, stackTrace);
      }
    }
  }

  Future<void> _loadThemePreference() async {
    _prefs = await _prefsFuture;
    try {
      final String? savedThemeName = _prefs?.getString(_themePrefsKey);
      ThemeMode loadedMode = ThemeMode.system;

      if (savedThemeName != null) {
        loadedMode = ThemeMode.values.firstWhere(
          (e) => e.name == savedThemeName,
          orElse: () => ThemeMode.system,
        );
        _log.info("Loaded theme preference: $loadedMode");
      } else {
        _log.info("No saved theme preference found, using system default.");
      }

      if (state != loadedMode) {
        state = loadedMode;
      }
    } catch (e, stackTrace) {
      _log.severe("Error loading theme preference", e, stackTrace);
    }
  }
}
