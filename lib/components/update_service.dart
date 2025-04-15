import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateInfo {
  final bool isUpdateAvailable;
  final String? latestVersion;
  final String? updateUrl;
  final String? assetName;
  final String? errorMessage;

  UpdateInfo({
    required this.isUpdateAvailable,
    this.latestVersion,
    this.updateUrl,
    this.assetName,
    this.errorMessage,
  });
}

class UpdateService {
  static final _log = Logger('UpdateService');

  static const String _githubOwner = 'FlamingWater35';
  static const String _githubRepo = 'notes_app';
  static const String _updateFilePrefsKey = 'downloaded_update_path';

  static Future<UpdateInfo> checkForUpdate() async {
    _log.info("Checking for updates...");

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      _log.fine("Current version: $currentVersion");

      final Uri uri = Uri.parse('https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        _log.warning("Failed to fetch release info: ${response.statusCode} ${response.body}");
        return UpdateInfo(isUpdateAvailable: false, errorMessage: "Failed to fetch update info (${response.statusCode})");
      }

      final Map<String, dynamic> releaseData = jsonDecode(response.body);
      final String latestVersion = (releaseData['tag_name'] as String?)?.replaceFirst('v', '') ?? ''; // Remove leading 'v' if present
      _log.info("Latest version found on GitHub: $latestVersion");

      // 3. Compare versions using simple string comparison, (in the future pub_semver for robustness)
      if (latestVersion.isEmpty || latestVersion == currentVersion || _isVersionLower(latestVersion, currentVersion)) {
        _log.info("No new update available.");
        return UpdateInfo(isUpdateAvailable: false, latestVersion: latestVersion);
      }

      _log.info("Update available: $latestVersion");

      String? abi;
      if (Platform.isAndroid) {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        abi = _getPrimaryAbi(androidInfo.supportedAbis);
        _log.info("Device ABI detected: $abi");
      } else {
        _log.warning("Update check/download only supported on Android for this implementation.");
        return UpdateInfo(isUpdateAvailable: false, errorMessage: "Updates only supported on Android.");
      }

      if (abi == null) {
        return UpdateInfo(isUpdateAvailable: false, errorMessage: "Could not determine device architecture.");
      }

      final List<dynamic>? assets = releaseData['assets'] as List<dynamic>?;
      if (assets == null || assets.isEmpty) {
        return UpdateInfo(isUpdateAvailable: false, errorMessage: "Latest release has no assets.");
      }

      String? downloadUrl;
      String? assetName;
      for (var asset in assets) {
        if (asset is Map<String, dynamic>) {
          final String name = asset['name'] as String? ?? '';
          if (name.endsWith('.apk') && name.contains(abi)) {
            downloadUrl = asset['browser_download_url'] as String?;
            assetName = name;
            _log.info("Found matching asset: $assetName with URL: $downloadUrl");
            break;
          }
        }
      }

      if (downloadUrl == null) {
        return UpdateInfo(isUpdateAvailable: false, errorMessage: "No suitable APK found for architecture '$abi'.");
      }

      return UpdateInfo(
        isUpdateAvailable: true,
        latestVersion: latestVersion,
        updateUrl: downloadUrl,
        assetName: assetName,
      );

    } catch (e, stackTrace) {
      _log.severe("Error checking for update", e, stackTrace);
      return UpdateInfo(isUpdateAvailable: false, errorMessage: "An error occurred: ${e.toString()}");
    }
  }

  static bool _isVersionLower(String v1, String v2) {
    return v1.compareTo(v2) < 0;
  }

  static String? _getPrimaryAbi(List<String> supportedAbis) {
    if (supportedAbis.contains('arm64-v8a')) return 'arm64-v8a';
    if (supportedAbis.contains('x86_64')) return 'x86_64';
    if (supportedAbis.contains('armeabi-v7a')) return 'armeabi-v7a';
    if (supportedAbis.contains('x86')) return 'x86';
    return supportedAbis.isNotEmpty ? supportedAbis.first : null; // Fallback
  }


  static Future<String?> downloadUpdate(String url, String fileName, Function(double) onProgress) async {
    _log.info("Starting download: $url");

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      final String downloadPath = '${appDocDir.path}/$fileName';
      final File file = File(downloadPath);
      _log.fine("Download path: $downloadPath");

      await file.parent.create(recursive: true);

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        _log.warning("Download failed: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}");
        client.close();
        return null;
      }

      final totalBytes = streamedResponse.contentLength ?? -1;
      int receivedBytes = 0;
      final List<int> buffer = [];

      final sink = file.openWrite();

      await streamedResponse.stream.listen((List<int> chunk) {
        receivedBytes += chunk.length;
        buffer.addAll(chunk);
        sink.add(chunk);
        if (totalBytes != -1) {
          final double progress = receivedBytes / totalBytes;
          onProgress(progress.clamp(0.0, 1.0));
        } else {
          onProgress(-1.0);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();
      client.close();

      _log.info("Download complete: $downloadPath");

      // Add file to cleanup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_updateFilePrefsKey, downloadPath);

      return downloadPath;

    } catch (e, stackTrace) {
      _log.severe("Error during download", e, stackTrace);
      return null;
    }
  }

  static Future<bool> installUpdate(String filePath) async {
    _log.info("Requesting installation for: $filePath");
    try {
      if (Platform.isAndroid) {
        var status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          _log.warning("Install permission not granted. Opening request...");
          // Attempt 2
          status = await Permission.requestInstallPackages.request();
          if (!status.isGranted) {
            _log.severe("Install permission denied after second attempt.");
            return false;
          }
        }
      }

      final OpenResult result = await OpenFilex.open(filePath, type: "application/vnd.android.package-archive");

      if (result.type == ResultType.error || result.type == ResultType.permissionDenied) {
        _log.severe("Failed to open APK for install: ${result.message}");
        return false;
      }
      _log.info("OS install prompt initiated.");
      return true;
    } catch (e, stackTrace) {
      _log.severe("Error initiating install", e, stackTrace);
      return false;
    }
  }

  static Future<void> cleanUpUpdateFile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? filePath = prefs.getString(_updateFilePrefsKey);

    if (filePath != null && filePath.isNotEmpty) {
      _log.info("Checking for leftover update file: $filePath");
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _log.info("Deleted leftover update file.");
        } else {
          _log.info("Leftover update file not found (already deleted?).");
        }
        await prefs.remove(_updateFilePrefsKey);
      } catch (e, stackTrace) {
        _log.severe("Error deleting leftover update file", e, stackTrace);
        await prefs.remove(_updateFilePrefsKey);
      }
    } else {
      _log.fine("No leftover update file path found in preferences.");
    }
  }
}