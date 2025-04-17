import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

class RestoreService {
  static final _log = Logger('RestoreService');

  static Future<List<Map<String, String>>?> restoreNotes() async {
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
      final String? fileExtension = result.files.single.extension?.toLowerCase();

      _log.info("User selected file: $filePath");

      if (fileExtension != 'json') {
        _log.warning("Restore failed: Selected file is not a .json file (extension: $fileExtension).");
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

      final List<Map<String, String>> restoredNotes = [];
      bool needsResave = false;

      for (var item in decodedData) {
        if (item is Map) {
          try {
            final Map<String, String> noteMap = Map<String, String>.from(item);

            if (noteMap.containsKey('title') && noteMap.containsKey('content')) {
              if (noteMap['id'] == null || noteMap['id']!.isEmpty) {
                noteMap['id'] = DateTime.now().toIso8601String() + UniqueKey().toString();
                _log.warning("Assigned new ID during restore to note with title: ${noteMap['title']}");
                needsResave = true;
              }
              if (noteMap['date'] == null || noteMap['date']!.isEmpty) {
                noteMap['date'] = DateTime.now().toIso8601String();
                _log.warning("Assigned current date during restore to note ID: ${noteMap['id']}");
                needsResave = true;
              } else {
                try {
                  DateTime.parse(noteMap['date']!);
                } catch (_) {
                  _log.warning("Invalid date format found during restore for note ID: ${noteMap['id']}, assigning current date.");
                  noteMap['date'] = DateTime.now().toIso8601String();
                  needsResave = true;
                }
              }
              final String nowString = DateTime.now().toIso8601String();
              if (noteMap['createdAt'] == null || noteMap['createdAt']!.isEmpty) {
                noteMap['createdAt'] = nowString;
                _log.warning("Assigned current createdAt during restore to note ID: ${noteMap['id']}");
                needsResave = true;
              }
              if (noteMap['lastModified'] == null || noteMap['lastModified']!.isEmpty) {
                noteMap['lastModified'] = noteMap['createdAt']!;
                _log.warning("Assigned createdAt as lastModified during restore to note ID: ${noteMap['id']}");
                needsResave = true;
              }

              restoredNotes.add(noteMap);
            } else {
              _log.warning("Skipping item during restore: Missing 'title' or 'content' key. Item: $item");
            }
          } catch (e) {
            _log.warning("Skipping item during restore: Could not cast item to Map<String, String>. Item: $item, Error: $e");
          }
        } else {
          _log.warning("Skipping item during restore: Item is not a Map. Item: $item");
        }
      }

      _log.info("Restore successful. Loaded ${restoredNotes.length} notes. Needs resave for IDs: $needsResave");
      return restoredNotes;

    } on FileSystemException catch (e, stackTrace) {
      _log.severe("File system error during restore: ${e.message}", e, stackTrace);
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