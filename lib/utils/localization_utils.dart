import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String getLanguageName(Locale? locale, AppLocalizations l10n) {
  if (locale == null) {
    return l10n.languageSystemDefault;
  }
  switch (locale.languageCode) {
    case 'ar':
      return 'العربية';
    case 'en':
      return 'English';
    case 'es':
      return 'Español';
    case 'fi':
      return 'Suomi';
    case 'fr':
      return 'Français';
    case 'hi':
      return 'हिन्दी';
    case 'id':
      return 'Bahasa Indonesia';
    case 'ja':
      return '日本語';
    case 'pt':
      return 'Português';
    case 'ru':
      return 'Русский';
    case 'zh':
      return '简体中文';
    default:
      return locale.languageCode.toUpperCase();
  }
}
