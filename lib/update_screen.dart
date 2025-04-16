import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'components/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus { idle, checking, available, downloading, error, installed }

class UpdateScreen extends StatefulWidget {
  final String heroTag;

  const UpdateScreen({super.key, required this.heroTag});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _log = Logger('UpdateScreen');
  UpdateStatus _status = UpdateStatus.idle;
  String _currentVersion = '';
  String _latestVersion = '';
  String? _updateUrl;
  String? _assetName;
  String _errorMessage = '';
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _performUpdateCheck();
  }

  Future<void> _performUpdateCheck() async {
    _log.info("Performing update check...");
    setState(() {
      _status = UpdateStatus.checking;
      _errorMessage = '';
    });

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _currentVersion = packageInfo.version);

      final UpdateInfo updateInfo = await UpdateService.checkForUpdate();
      if (!mounted) return;

      if (updateInfo.isUpdateAvailable) {
        setState(() {
          _status = UpdateStatus.available;
          _latestVersion = updateInfo.latestVersion ?? 'N/A';
          _updateUrl = updateInfo.updateUrl;
          _assetName = updateInfo.assetName;
        });
      } else {
        setState(() {
          _status = UpdateStatus.idle;
          _errorMessage = updateInfo.errorMessage ?? 'No new update available.';
          _latestVersion = updateInfo.latestVersion ?? _currentVersion;
        });
      }
    } catch (e, stackTrace) {
      _log.severe("Unhandled error during update check", e, stackTrace);
      if (mounted) {
        setState(() {
          _status = UpdateStatus.error;
          _errorMessage = 'An unexpected error occurred during check.';
        });
      }
    }
  }

  Future<void> _startDownloadAndInstall() async {
    if (_updateUrl == null || _assetName == null) {
      _log.severe("Download requested but URL or filename is missing.");
      setState(() {
        _status = UpdateStatus.error;
        _errorMessage = "Update information is incomplete.";
      });
      return;
    }

    _log.info("Starting download & install process...");
    setState(() {
      _status = UpdateStatus.downloading;
      _downloadProgress = -1.0;
      _errorMessage = '';
    });

    final String? downloadedPath = await UpdateService.downloadUpdate(
      _updateUrl!,
      _assetName!,
      _updateDownloadProgress,
    );

    if (!mounted) return;

    if (downloadedPath != null) {
      final bool installInitiated = await UpdateService.installUpdate(downloadedPath);
      if (!mounted) return;

      if (installInitiated) {
        _log.info("Install prompt likely shown. Waiting for user/OS action.");
        // App usually closes here, cleanup happens on next launch.
        // Maybe show a generic message
        // setState(() { _status = UpdateStatus.idle; _errorMessage = "Installation process initiated."});
      } else {
        _log.warning("Failed to initiate installation prompt.");
        setState(() {
          _status = UpdateStatus.error;
          _errorMessage = "Could not start installation. Check permissions.";
        });
      }
    } else {
      setState(() {
        _status = UpdateStatus.error;
        _errorMessage = "Download failed. Check connection and permissions.";
      });
    }
  }

  void _updateDownloadProgress(double progress) {
    if (mounted) {
      setState(() {
        _downloadProgress = progress;
      });
    }
  }

  Widget _buildContent() {
    switch (_status) {
      case UpdateStatus.checking:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Checking for updates..."),
          ],
        );
      case UpdateStatus.available:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.system_update_alt, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text("Update Available!", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("Current version: $_currentVersion"),
            Text("New version: $_latestVersion"),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.download_for_offline_outlined),
              label: const Text("Download & Install"),
              onPressed: _startDownloadAndInstall,
            ),
          ],
        );
      case UpdateStatus.downloading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Downloading update ($_latestVersion)..."),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _downloadProgress < 0 ? null : _downloadProgress,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            if (_downloadProgress >= 0)
              Text("${(_downloadProgress * 100).toStringAsFixed(0)}%"),
          ],
        );
      case UpdateStatus.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text("Update Failed", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry Check"),
              onPressed: _performUpdateCheck,
            ),
          ],
        );
      case UpdateStatus.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 60, color: Colors.blue),
            const SizedBox(height: 16),
            Text("You're up to date!", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("Current version: $_currentVersion"),
            if (_latestVersion != _currentVersion && _latestVersion.isNotEmpty)
              Text("(Latest available: $_latestVersion)"),
            const SizedBox(height: 8),
            if(_errorMessage.isNotEmpty && !_errorMessage.contains("No new update available"))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Check Again"),
              onPressed: _performUpdateCheck,
            ),
          ],
        );
      case UpdateStatus.installed: // Unlikely to be shown directly
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text("Update successful!"), // Placeholder
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building UpdateScreen widget with status: $_status");
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Update"),
      ),
      body: Hero(
        tag: widget.heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(),
              ),
             ),
          ),
        ),
      ),
    );
  }
}