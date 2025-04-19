import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import '../data/database_helper.dart';
import '../models/note_model.dart';

final _log = Logger('Providers');

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    _log.info("NotesNotifier: build() called - fetching initial notes.");
    final dbHelper = ref.read(databaseProvider);
    return await dbHelper.getAllNotes();
  }

  Future<void> addNote(Note note) async {
    _log.fine("NotesNotifier: addNote called for ID ${note.id}");
    state = const AsyncLoading();
    final dbHelper = ref.read(databaseProvider);

    state = await AsyncValue.guard(() async {
      await dbHelper.insertNote(note);
      return await dbHelper.getAllNotes();
      // Alternative (potentially faster for large lists, but less safe):
      // final currentNotes = state.value ?? [];
      // return [note, ...currentNotes]; // Add to beginning
    });
     _log.fine("NotesNotifier: addNote finished for ID ${note.id}");
  }

  Future<void> updateNote(Note note) async {
    _log.fine("NotesNotifier: updateNote called for ID ${note.id}");
    state = const AsyncLoading();
    final dbHelper = ref.read(databaseProvider);

    try {
      state = await AsyncValue.guard(() async {
        await dbHelper.updateNote(note);
        return await dbHelper.getAllNotes();
        // Alternative: Update locally
        // final currentNotes = state.value ?? [];
        // final index = currentNotes.indexWhere((n) => n.id == note.id);
        // if (index != -1) {
        //   final updatedList = List<Note>.from(currentNotes);
        //   updatedList[index] = note;
        //   return updatedList;
        // }
        // return currentNotes; // Should not happen if note exists
      });
    } catch (e, s) {
      _log.severe("Error updating note in provider", e, s);
      state = AsyncError(e, s);
      rethrow;
    } finally {
     _log.fine("NotesNotifier: updateNote finished for ID ${note.id}");
    }
  }

  Future<void> deleteNote(String id) async {
    _log.fine("NotesNotifier: deleteNote called for ID $id");
    state = const AsyncLoading();
    final dbHelper = ref.read(databaseProvider);

    state = await AsyncValue.guard(() async {
      await dbHelper.deleteNote(id);
      return await dbHelper.getAllNotes();
      // Alternative: Remove locally
      // final currentNotes = state.value ?? [];
      // final updatedList = currentNotes.where((n) => n.id != id).toList();
      // return updatedList;
    });
    _log.fine("NotesNotifier: deleteNote finished for ID $id");
  }

   Future<void> replaceAllNotes(List<Note> notes) async {
    _log.info("NotesNotifier: replaceAllNotes called with ${notes.length} notes.");
    state = const AsyncLoading();
    final dbHelper = ref.read(databaseProvider);

    state = await AsyncValue.guard(() async {
      await dbHelper.deleteAllNotes();
      await dbHelper.insertMultipleNotes(notes);
      return await dbHelper.getAllNotes();
    });
    _log.info("NotesNotifier: replaceAllNotes finished.");
  }

  Note? getNoteById(String id) {
    final notes = state.value;

    if (notes == null) {
      _log.warning("NotesNotifier: getNoteById called while state is not AsyncData or notes are null.");
      return null;
    }

    try {
      return notes.firstWhere((note) => note.id == id);
    } on StateError {
      _log.warning("NotesNotifier: getNoteById failed to find ID $id");
      return null;
    } catch (e, stackTrace) {
      _log.severe("NotesNotifier: Unexpected error in getNoteById for ID $id", e, stackTrace);
      return null;
    }
  }
}

const String _themePrefsKey = 'app_theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(SharedPreferences.getInstance());
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Future<SharedPreferences> _prefsFuture;
  SharedPreferences? _prefs;

  ThemeNotifier(this._prefsFuture) : super(ThemeMode.system) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _prefs = await _prefsFuture;
    try {
      final String? savedThemeName = _prefs?.getString(_themePrefsKey);
      ThemeMode loadedMode = ThemeMode.system;

      if (savedThemeName != null) {
        loadedMode = ThemeMode.values.firstWhere(
          (e) => e.name == savedThemeName,
          orElse: () => ThemeMode.system,
        );
        _log.info("Loaded theme preference: $loadedMode");
      } else {
        _log.info("No saved theme preference found, using system default.");
      }

      if (state != loadedMode) {
        state = loadedMode;
      }
    } catch (e, stackTrace) {
      _log.severe("Error loading theme preference", e, stackTrace);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      _log.info("Setting theme mode to: $mode");
      try {
        _prefs ??= await _prefsFuture;
        await _prefs?.setString(_themePrefsKey, mode.name);
        _log.info("Saved theme preference: $mode");
      } catch (e, stackTrace) {
        _log.severe("Error saving theme preference", e, stackTrace);
      }
    }
  }
}