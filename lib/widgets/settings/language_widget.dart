import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/localization_utils.dart';
import '../language_select_sheet.dart';

Padding languageOptions(
  ThemeData theme,
  AppLocalizations l10n,
  Locale? currentLocale,
  BuildContext context,
  WidgetRef ref,
  Logger log,
) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
    child: ListTile(
      leading: Icon(
        Icons.language_outlined,
        color: theme.colorScheme.secondary,
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(l10n.languageSectionTitle),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          getLanguageName(currentLocale, l10n),
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color?.withAlpha(200),
          ),
        ),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () {
        log.info("Language setting tapped - showing selection sheet");
        showLanguageSelectionSheet(context, currentLocale, l10n, ref, log);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      horizontalTitleGap: 8.0,
      tileColor: theme.colorScheme.surfaceContainerHighest.withAlpha(64),
    ),
  );
}
