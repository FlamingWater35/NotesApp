import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _log = Logger('SettingsScreen');
  String _appVersion = 'Loading...';

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

  void _handleBackup() {
    _log.info("Backup button tapped - (Not Implemented)");
    // TODO: Implement backup logic (e.g., pick file location, save JSON)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup feature not yet implemented.')),
    );
  }

  void _handleRestore() {
    _log.info("Restore button tapped - (Not Implemented)");
    // TODO: Implement restore logic (e.g., pick file, read JSON, load notes)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore feature not yet implemented.')),
    );
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
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup Notes'),
                  subtitle: const Text('Save notes to a file'),
                  onTap: _handleBackup,
                ),
                 ListTile(
                  leading: const Icon(Icons.restore_page_outlined),
                  title: const Text('Restore Notes'),
                  subtitle: const Text('Load notes from a backup file'),
                  onTap: _handleRestore,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.system_update_alt_outlined),
                  title: const Text('Check for Updates'),
                  onTap: _handleCheckForUpdates,
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