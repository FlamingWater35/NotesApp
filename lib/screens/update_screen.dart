import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../components/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  downloading,
  preparingInstall,
  error,
  installed,
}

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  String? _assetName;
  String _currentVersion = '';
  double _downloadProgress = 0.0;
  String _errorMessage = '';
  String _latestVersion = '';
  final _log = Logger('UpdateScreen');
  UpdateStatus _status = UpdateStatus.idle;
  String? _updateUrl;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _performUpdateCheck();
      }
    });
  }

  AppLocalizations get l10n => AppLocalizations.of(context);

  Future<void> _performUpdateCheck() async {
    _log.info("Performing update check...");
    if (!mounted) return;
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
          _latestVersion = updateInfo.latestVersion ?? l10n.versionNotAvailable;
          _updateUrl = updateInfo.updateUrl;
          _assetName = updateInfo.assetName;
        });
      } else {
        setState(() {
          _status = UpdateStatus.idle;
          _errorMessage =
              updateInfo.errorMessage ?? l10n.updateErrorNoNewUpdate;
          _latestVersion = updateInfo.latestVersion ?? _currentVersion;
        });
      }
    } catch (e, stackTrace) {
      _log.severe("Unhandled error during update check", e, stackTrace);
      if (mounted) {
        setState(() {
          _status = UpdateStatus.error;
          _errorMessage = l10n.updateErrorUnexpected;
        });
      }
    }
  }

  Future<void> _startDownloadAndInstall() async {
    if (_updateUrl == null || _assetName == null) {
      _log.severe("Download requested but URL or filename is missing.");
      if (!mounted) return;
      setState(() {
        _status = UpdateStatus.error;
        _errorMessage = l10n.updateErrorIncompleteInfo;
      });
      return;
    }

    _log.info("Starting download & install process...");
    if (!mounted) return;
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
      _log.info("Download complete. Preparing for installation...");
      setState(() {
        _status = UpdateStatus.preparingInstall;
      });
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      _log.info("Initiating installation...");
      final bool installInitiated = await UpdateService.installUpdate(
        downloadedPath,
      );
      if (!mounted) return;

      if (installInitiated) {
        _log.info("Install prompt likely shown. Waiting for user/OS action.");
        setState(() {
          _status = UpdateStatus.installed;
        });
      } else {
        _log.warning("Failed to initiate installation prompt.");
        setState(() {
          _status = UpdateStatus.error;
          _errorMessage = l10n.updateErrorCouldNotStartInstall;
        });
      }
    } else {
      setState(() {
        _status = UpdateStatus.error;
        _errorMessage = l10n.updateErrorDownloadFailed;
      });
    }
  }

  void _updateDownloadProgress(double progress) {
    if (mounted) {
      final clampedProgress = progress.clamp(0.0, 1.0);
      setState(() {
        _downloadProgress = clampedProgress;
      });
    }
  }

  Widget _buildContent() {
    final statusTextStyle = Theme.of(context).textTheme.titleMedium;

    switch (_status) {
      case UpdateStatus.checking:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              l10n.updateStatusChecking,
              style: statusTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        );

      case UpdateStatus.available:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.system_update_alt, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              l10n.updateStatusAvailableTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.updateStatusCurrentVersion(_currentVersion),
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.updateStatusNewVersion(_latestVersion),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.download_for_offline_outlined),
              label: Text(
                l10n.updateDownloadInstallButton,
                textAlign: TextAlign.center,
              ),
              onPressed: _startDownloadAndInstall,
            ),
          ],
        );

      case UpdateStatus.downloading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.updateStatusDownloading(_latestVersion),
              style: statusTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: _downloadProgress < 0 ? null : _downloadProgress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            if (_downloadProgress >= 0)
              Text(
                l10n.updateProgressPercent(
                  (_downloadProgress * 100).toStringAsFixed(0),
                ),
              ),
          ],
        );

      case UpdateStatus.preparingInstall:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.updateStatusStartingInstall,
              style: statusTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(value: null, minHeight: 8),
            ),
          ],
        );

      case UpdateStatus.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.updateStatusFailedTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(
                l10n.updateTryAgainButton,
                textAlign: TextAlign.center,
              ),
              onPressed: _performUpdateCheck,
            ),
          ],
        );

      case UpdateStatus.idle:
        final bool isJustNoUpdateMessage =
            _errorMessage == l10n.updateErrorNoNewUpdate;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.updateStatusUpToDateTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.updateStatusCurrentVersion(_currentVersion),
              textAlign: TextAlign.center,
            ),
            if (_latestVersion != _currentVersion && _latestVersion.isNotEmpty)
              Text(
                l10n.updateStatusLatestAvailable(_latestVersion),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            if (_errorMessage.isNotEmpty && !isJustNoUpdateMessage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(
                l10n.updateCheckAgainButton,
                textAlign: TextAlign.center,
              ),
              onPressed: _performUpdateCheck,
            ),
          ],
        );

      case UpdateStatus.installed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text(
              l10n.updateStatusInstalled,
              style: statusTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building UpdateScreen widget with status: $_status");
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.updateScreenTitle)),
      body: Material(
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
    );
  }
}
