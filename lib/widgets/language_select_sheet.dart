import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../utils/localization_utils.dart';

void showLanguageSelectionSheet(
  BuildContext context,
  Locale? currentLocale,
  AppLocalizations l10n,
  WidgetRef ref,
  Logger log,
) {
  final supportedLocales = AppLocalizations.supportedLocales;
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext bottomSheetContext) {
      return Consumer(
        builder: (context, sheetRef, child) {
          final Locale? currentLocaleInSheet = sheetRef.watch(localeProvider);

          void handleLocaleSelection(Locale? newLocale) {
            log.info(
              "Language selected in sheet: ${newLocale?.languageCode ?? 'System Default'}",
            );
            ref.read(localeProvider.notifier).setLocale(newLocale);
            Navigator.pop(bottomSheetContext);
          }

          var languageOptions = <Widget>[];

          languageOptions.add(
            ListTile(
              title: Text(l10n.languageSystemDefault),
              leading: Radio<Locale?>(
                value: null,
                groupValue: currentLocaleInSheet,
                onChanged: (Locale? val) => handleLocaleSelection(val),
                activeColor: theme.colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
              selected: currentLocaleInSheet == null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              visualDensity: VisualDensity.compact,
              onTap: () => handleLocaleSelection(null),
            ),
          );

          languageOptions.addAll(
            supportedLocales.map((locale) {
              final languageName = getLanguageName(locale, l10n);
              final bool isSelected = locale == currentLocaleInSheet;

              return ListTile(
                title: Text(languageName),
                leading: Radio<Locale?>(
                  value: locale,
                  groupValue: currentLocaleInSheet,
                  onChanged: (Locale? val) => handleLocaleSelection(val),
                  activeColor: theme.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                ),
                selected: isSelected,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                visualDensity: VisualDensity.compact,
                onTap: () => handleLocaleSelection(locale),
              );
            }).toList(),
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      l10n.languageSectionTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: languageOptions,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
