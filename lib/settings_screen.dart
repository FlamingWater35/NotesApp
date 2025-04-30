import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/backup_service.dart';
import 'components/restore_service.dart';
import 'update_screen.dart';
import '../providers/providers.dart';
import '../models/note_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _log = Logger('SettingsScreen');
  String _appVersion = 'Loading...';
  bool _isBackupRestoreRunning = false;
  final String _updateHeroTag = 'update-hero-tag';

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'Version ${info.version} (${info.buildNumber})';
        });
        _log.info("App version loaded: $_appVersion");
      }
    } catch (e, stackTrace) {
      _log.severe("Error getting package info", e, stackTrace);
      if (mounted) {
        setState(() {
          _appVersion = 'Error loading version';
        });
      }
    }
  }

  Future<void> _handleBackup() async {
    if (_isBackupRestoreRunning) return;
    setState(() => _isBackupRestoreRunning = true);
    _log.info("Backup button tapped");

    final notesAsync = ref.read(notesProvider);
    final List<Note> currentNotes = notesAsync.value ?? [];

    final bool success = await BackupService.backupNotes(currentNotes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Backup successful!' : 'Backup failed or cancelled (no notes added?).'),
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

    final List<Note>? restoredNotes = await RestoreService.restoreNotes();

    if (mounted) {
      if (restoredNotes != null) {
        _log.info("Restore service returned ${restoredNotes.length} notes.");
        await ref.read(notesProvider.notifier).replaceAllNotes(restoredNotes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(  // TODO: Fix this useless bar not showing up
            const SnackBar(
              content: Text('Restore successful!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore failed or cancelled (invalid file format?)'),
            duration: Duration(seconds: 2),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateScreen(heroTag: _updateHeroTag),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    _log.finer("Building SettingsScreen widget");
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text(
            'Settings',
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
                    child: Text('Appearance', style: theme.textTheme.titleSmall),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: SegmentedButton<ThemeMode>(
                      selected: {currentMode},
                      segments: const <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
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
                    child: Text('Data Management', style: theme.textTheme.titleSmall),
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup Notes'),
                    subtitle: const Text('Save notes to a file'),
                    enabled: !_isBackupRestoreRunning,
                    onTap: _handleBackup,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_page_outlined),
                    title: const Text('Restore Notes'),
                    subtitle: const Text('Load notes from a backup file'),
                    enabled: !_isBackupRestoreRunning,
                    onTap: _handleRestore,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  if (_isBackupRestoreRunning)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                    ),
                  const Divider(indent: 16, endIndent: 16, height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Application', style: theme.textTheme.titleSmall),
                  ),
                  Hero(
                    tag: _updateHeroTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        leading: const Icon(Icons.system_update_alt_outlined),
                        title: const Text('Check for Updates'),
                        onTap: _handleCheckForUpdates,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
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