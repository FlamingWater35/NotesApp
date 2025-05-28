import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/backup_service.dart';
import '../components/restore_service.dart';
import 'update_screen.dart';
import '../../providers/providers.dart';
import '../../models/note_model.dart';
import 'package:notes_app/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const Duration _settingAnimationDuration = Duration(milliseconds: 300);

  String _appVersion = '';
  bool _isBackupRestoreRunning = false;
  final _log = Logger('SettingsScreen');

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _appVersion = l10n.appVersionLoading;
      });
    });


    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _appVersion = l10n.appVersion(info.version, info.buildNumber);
        });
        _log.info("App version loaded: $_appVersion");
      }
    } catch (e, stackTrace) {
      _log.severe("Error getting package info", e, stackTrace);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _appVersion = l10n.errorLoadingVersion;
        });
      }
    }
  }

  Future<void> _handleBackup() async {
    if (_isBackupRestoreRunning) return;
    setState(() => _isBackupRestoreRunning = true);
    _log.info("Backup button tapped");
    final l10n = AppLocalizations.of(context);

    final notesAsync = ref.read(notesProvider);
    final List<Note> currentNotes = notesAsync.value ?? [];

    final bool success = await BackupService.backupNotes(currentNotes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.backupSuccessful : l10n.backupFailed),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _isBackupRestoreRunning = false);
    }
  }

  Future<void> _handleRestore() async {
    if (_isBackupRestoreRunning) return;
    setState(() => _isBackupRestoreRunning = true);
    _log.info("Restore button tapped");
    final l10n = AppLocalizations.of(context);

    final List<Note>? restoredNotes = await RestoreService.restoreNotes();

    if (mounted) {
      if (restoredNotes != null) {
        _log.info("Restore service returned ${restoredNotes.length} notes.");
        await ref.read(notesProvider.notifier).replaceAllNotes(restoredNotes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.restoreSuccessful),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.restoreFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isBackupRestoreRunning = false);
      _log.fine("Called final setState in _handleRestore.");
    } else {
      _log.warning("Skipped final setState in _handleRestore because widget was unmounted.");
    }
  }

  void _handleCheckForUpdates() {
    _log.info("Check for Updates button tapped - Navigating");
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const UpdateScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  String _getLanguageName(Locale? locale, AppLocalizations l10n) {
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

  void _showLanguageSelectionSheet(BuildContext context, Locale? currentLocale, AppLocalizations l10n, WidgetRef ref) {
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
              _log.info("Language selected in sheet: ${newLocale?.languageCode ?? 'System Default'}");
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
              )
            );

            languageOptions.addAll(
              supportedLocales.map((locale) {
                final languageName = _getLanguageName(locale, l10n);
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
              }).toList()
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building SettingsScreen widget");
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeProvider);
    final Locale? currentLocale = ref.watch(localeProvider);

    if (_appVersion.isEmpty && mounted) {
      _appVersion = l10n.appVersionLoading;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text(
            l10n.settingsScreenTitle,
            style: theme.textTheme.headlineMedium,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(l10n.languageSectionTitle, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: ListTile(
                      leading: Icon(Icons.language_outlined, color: theme.colorScheme.secondary),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(l10n.languageSectionTitle)
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          _getLanguageName(currentLocale, l10n),
                          style: TextStyle(color: theme.textTheme.bodySmall?.color?.withAlpha(200)),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      onTap: () {
                        _log.info("Language setting tapped - showing selection sheet");
                        _showLanguageSelectionSheet(context, currentLocale, l10n, ref);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: theme.dividerColor, width: 0.5)
                      ),
                      horizontalTitleGap: 8.0,
                      tileColor: theme.colorScheme.surfaceContainerHighest.withAlpha(64),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(l10n.appearanceSectionTitle, style: theme.textTheme.titleSmall),
                  ),
                  Padding(
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
                          _log.info("Theme mode changed to: ${newSelection.first}");
                          ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
                        }
                      },
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(l10n.dataManagementSectionTitle, style: theme.textTheme.titleSmall),
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text(l10n.backupNotesTitle),
                    subtitle: Text(l10n.backupNotesSubtitle),
                    enabled: !_isBackupRestoreRunning,
                    onTap: _handleBackup,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ).animate().fadeIn(duration: _settingAnimationDuration).flipV(duration: _settingAnimationDuration),
                  ListTile(
                    leading: const Icon(Icons.restore_page_outlined),
                    title: Text(l10n.restoreNotesTitle),
                    subtitle: Text(l10n.restoreNotesSubtitle),
                    enabled: !_isBackupRestoreRunning,
                    onTap: _handleRestore,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ).animate().fadeIn(duration: _settingAnimationDuration).flipV(duration: _settingAnimationDuration),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(l10n.applicationSectionTitle, style: theme.textTheme.titleSmall),
                  ),
                  ListTile(
                    leading: const Icon(Icons.system_update_alt_outlined),
                    title: Text(l10n.checkForUpdatesTitle),
                    onTap: _handleCheckForUpdates,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ).animate().fadeIn(duration: _settingAnimationDuration).slideX(duration: _settingAnimationDuration),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _appVersion, 
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );  
  }
}