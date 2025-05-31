import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('LocaleProvider');
const String _localePrefsKey = 'selected_locale_language_code';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  Future<void> setLocale(Locale? newLocale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (newLocale == null) {
        await prefs.remove(_localePrefsKey);
        _log.info('Locale set to System Default and preference removed.');
      } else {
        await prefs.setString(_localePrefsKey, newLocale.languageCode);
        _log.info(
          'Locale set to ${newLocale.languageCode} and preference saved.',
        );
      }
      state = newLocale;
    } catch (e, stackTrace) {
      _log.severe('Error saving locale preference: $e', e, stackTrace);
    }
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localePrefsKey);

      if (languageCode != null && languageCode.isNotEmpty) {
        state = Locale(languageCode);
        _log.info('Loaded saved locale: $languageCode');
      } else {
        state = null;
        _log.info(
          'No saved locale found or saved as system default. Using system default.',
        );
      }
    } catch (e, stackTrace) {
      _log.severe(
        'Error loading saved locale, falling back to system default: $e',
        e,
        stackTrace,
      );
      state = null;
    }
  }
}
