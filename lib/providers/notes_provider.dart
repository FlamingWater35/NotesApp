import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../models/note_model.dart';
import 'database_provider.dart';

final _log = Logger('NotesProvider');

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  Future<void> addNote(Note note) async {
    _log.fine("NotesNotifier: addNote called for ID ${note.id}");
    state = const AsyncLoading();
    final dbHelper = ref.read(databaseProvider);

    state = await AsyncValue.guard(() async {
      await dbHelper.insertNote(note);
      return await dbHelper.getAllNotes();
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
    });
    _log.fine("NotesNotifier: deleteNote finished for ID $id");
  }

  Future<void> replaceAllNotes(List<Note> notes) async {
    _log.info(
      "NotesNotifier: replaceAllNotes called with ${notes.length} notes.",
    );
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
      _log.warning(
        "NotesNotifier: getNoteById called while state is not AsyncData or notes are null.",
      );
      return null;
    }

    try {
      return notes.firstWhere((note) => note.id == id);
    } on StateError {
      _log.warning("NotesNotifier: getNoteById failed to find ID $id");
      return null;
    } catch (e, stackTrace) {
      _log.severe(
        "NotesNotifier: Unexpected error in getNoteById for ID $id",
        e,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<List<Note>> build() async {
    _log.info("NotesNotifier: build() called - fetching initial notes.");
    final dbHelper = ref.read(databaseProvider);
    return await dbHelper.getAllNotes();
  }
}
