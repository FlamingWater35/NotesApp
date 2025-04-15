import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../components/backup_service.dart';
import '../components/restore_service.dart';

class SettingsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final List<Map<String, String>> currentNotes;
  final Future<void> Function(List<Map<String, String>> restoredNotes) onNotesRestored;

  const SettingsScreen({
    super.key,
    required this.themeNotifier,
    required this.currentNotes,
    required this.onNotesRestored,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _log = Logger('SettingsScreen');
  String _appVersion = 'Loading...';
  bool _isBackupRestoreRunning = false;

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

    final bool success = await BackupService.backupNotes(widget.currentNotes);

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

    final List<Map<String, String>>? restoredNotes = await RestoreService.restoreNotes();

    if (mounted) {
      if (restoredNotes != null) {
        await widget.onNotesRestored(restoredNotes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
      setState(() => _isBackupRestoreRunning = false);
    }
  }

  void _handleCheckForUpdates() {
    _log.info("Check for Updates button tapped - (Not Implemented)");
    // TODO: Implement update check logic (e.g., check against a server/store)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update check not yet implemented.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    _log.finer("Building SettingsScreen widget");
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              'Settings',
              style: theme.textTheme.headlineMedium,
            ),
          ),

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
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: widget.themeNotifier,
                    builder: (context, currentMode, child) {

                      return SegmentedButton<ThemeMode>(
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
                            widget.themeNotifier.value = newSelection.first;
                          }
                        },
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                        ),
                      );
                    },
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
                  onTap: _handleBackup,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                 ListTile(
                  leading: const Icon(Icons.restore_page_outlined),
                  title: const Text('Restore Notes'),
                  subtitle: const Text('Load notes from a backup file'),
                  onTap: _handleRestore,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Application', style: theme.textTheme.titleSmall),
                ),
                ListTile(
                  leading: const Icon(Icons.system_update_alt_outlined),
                  title: const Text('Check for Updates'),
                  onTap: _handleCheckForUpdates,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    );
  }
}