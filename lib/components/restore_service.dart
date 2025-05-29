import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../models/note_model.dart';

class RestoreService {
  static final _log = Logger('RestoreService');

  static Future<List<Note>?> restoreNotes() async {
    _log.info("Starting notes restore process...");
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Select Notes Backup File (.json)',
      );

      if (result == null || result.files.single.path == null) {
        _log.info("Restore cancelled by user or file path missing.");
        return null;
      }

      final String filePath = result.files.single.path!;
      final String? fileExtension =
          result.files.single.extension?.toLowerCase();

      _log.info("User selected file: $filePath");

      if (fileExtension != 'json') {
        _log.warning(
          "Restore failed: Selected file is not a .json file (extension: $fileExtension).",
        );
        // Possibly show a specific user message here
        return null;
      }

      final File file = File(filePath);
      _log.info("Attempting to restore notes from JSON file: $filePath");

      final String jsonString = await file.readAsString();
      final dynamic decodedData = jsonDecode(jsonString);

      if (decodedData is! List) {
        _log.warning("Restore failed: Backup file content is not a JSON list.");
        return null;
      }

      final List<Note> restoredNotes = [];
      for (final item in decodedData) {
        if (item is Map<String, dynamic>) {
          try {
            if (item['id'] != null &&
                item['title'] != null &&
                item['content'] != null &&
                item['date'] != null &&
                item['createdAt'] != null &&
                item['lastModified'] != null) {
              restoredNotes.add(Note.fromMap(item));
            } else {
              _log.warning(
                "Skipping invalid note data during restore: Missing required fields. Data: $item",
              );
            }
          } catch (e, stackTrace) {
            _log.warning(
              "Error converting map to Note during restore. Skipping item. Data: $item",
              e,
              stackTrace,
            );
          }
        } else {
          _log.warning(
            "Skipping non-map item found in backup file during restore. Item: $item",
          );
        }
      }

      if (restoredNotes.isEmpty && decodedData.isNotEmpty) {
        _log.warning(
          "Restore resulted in an empty list, possibly due to format errors in all entries.",
        );
        return null;
      }

      _log.info(
        "Restore successful! Read ${restoredNotes.length} notes from: $filePath",
      );
      return restoredNotes;
    } on FileSystemException catch (e, stackTrace) {
      _log.severe(
        "File system error during restore: ${e.message}",
        e,
        stackTrace,
      );
      return null;
    } on FormatException catch (e, stackTrace) {
      _log.severe("JSON format error during restore", e, stackTrace);
      return null;
    } catch (e, stackTrace) {
      _log.severe("Error during restore process", e, stackTrace);
      return null;
    }
  }
}
