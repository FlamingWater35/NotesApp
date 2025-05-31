import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

Padding themeModeOptions(
  ThemeMode currentMode,
  AppLocalizations l10n,
  Logger log,
  WidgetRef ref,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    child: SegmentedButton<ThemeMode>(
      selected: {currentMode},
      segments: <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text(l10n.themeLight),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text(l10n.themeDark),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text(l10n.themeSystem),
          icon: Icon(Icons.settings_suggest_outlined),
        ),
      ],

      onSelectionChanged: (Set<ThemeMode> newSelection) {
        if (newSelection.isNotEmpty) {
          log.info("Theme mode changed to: ${newSelection.first}");
          ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
        }
      },
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(),
    ),
  );
}
