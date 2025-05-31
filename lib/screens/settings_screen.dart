import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/backup_service.dart';
import '../components/restore_service.dart';
import '../providers/locale_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/language_widget.dart';
import '../widgets/settings/thememode_widget.dart';
import 'update_screen.dart';
import '../../models/note_model.dart';
import '../l10n/app_localizations.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      _log.warning(
        "Skipped final setState in _handleRestore because widget was unmounted.",
      );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      l10n.languageSectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  languageOptions(
                    theme,
                    l10n,
                    currentLocale,
                    context,
                    ref,
                    _log,
                  ),
                  const SizedBox(height: 8),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      l10n.appearanceSectionTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  themeModeOptions(currentMode, l10n, _log, ref),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      l10n.dataManagementSectionTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  ListTile(
                        leading: const Icon(Icons.backup_outlined),
                        title: Text(l10n.backupNotesTitle),
                        subtitle: Text(l10n.backupNotesSubtitle),
                        enabled: !_isBackupRestoreRunning,
                        onTap: _handleBackup,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: _settingAnimationDuration)
                      .flipV(duration: _settingAnimationDuration),
                  ListTile(
                        leading: const Icon(Icons.restore_page_outlined),
                        title: Text(l10n.restoreNotesTitle),
                        subtitle: Text(l10n.restoreNotesSubtitle),
                        enabled: !_isBackupRestoreRunning,
                        onTap: _handleRestore,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: _settingAnimationDuration)
                      .flipV(duration: _settingAnimationDuration),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      l10n.applicationSectionTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  ListTile(
                        leading: const Icon(Icons.system_update_alt_outlined),
                        title: Text(l10n.checkForUpdatesTitle),
                        onTap: _handleCheckForUpdates,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: _settingAnimationDuration)
                      .slideX(duration: _settingAnimationDuration),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _appVersion,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
