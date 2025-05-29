import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = 'notes_database.db';
  static const int _dbVersion = 1;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const String _tableName = 'notes';

  final _log = Logger('DatabaseHelper');

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Operations

  Future<void> insertNote(Note note) async {
    _log.info("Inserting note ID: ${note.id}");
    final db = await database;
    try {
      await db.insert(
        _tableName,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _log.fine("Note ID ${note.id} inserted successfully.");
    } catch (e, stackTrace) {
      _log.severe("Error inserting note ID: ${note.id}", e, stackTrace);
    }
  }

  Future<void> insertMultipleNotes(List<Note> notes) async {
    _log.info("Inserting ${notes.length} notes...");
    final db = await database;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert(
        _tableName,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    try {
      await batch.commit(noResult: true);
      _log.info("Batch insert completed successfully.");
    } catch (e, stackTrace) {
      _log.severe("Error during batch insert", e, stackTrace);
    }
  }

  Future<List<Note>> getAllNotes() async {
    _log.finer("Fetching all notes...");
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      final notes = List.generate(maps.length, (i) => Note.fromMap(maps[i]));
      _log.info("Fetched ${notes.length} notes.");
      return notes;
    } catch (e, stackTrace) {
      _log.severe("Error fetching all notes", e, stackTrace);
      return [];
    }
  }

  Future<void> updateNote(Note note) async {
    _log.info("Updating note ID: ${note.id}");
    final db = await database;
    try {
      await db.update(
        _tableName,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      _log.fine("Note ID ${note.id} updated successfully.");
    } catch (e, stackTrace) {
      _log.severe("Error updating note ID: ${note.id}", e, stackTrace);
    }
  }

  Future<void> deleteNote(String id) async {
    _log.info("Deleting note ID: $id");
    final db = await database;
    try {
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      _log.fine("Note ID $id deleted successfully.");
    } catch (e, stackTrace) {
      _log.severe("Error deleting note ID: $id", e, stackTrace);
    }
  }

  Future<void> deleteAllNotes() async {
    _log.warning("Deleting ALL notes from the database!");
    final db = await database;
    try {
      await db.delete(_tableName);
      _log.info("All notes deleted successfully.");
    } catch (e, stackTrace) {
      _log.severe("Error deleting all notes", e, stackTrace);
    }
  }

  // Close the database when the app closes (use if issues arise)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _log.info("Database closed.");
  }

  Future<Database> _initDatabase() async {
    _log.info("Initializing database...");
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    try {
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        // onUpgrade: _onUpgrade, // If schema changes later
      );
    } catch (e, stackTrace) {
      _log.severe("Error initializing database", e, stackTrace);
      rethrow; // Rethrow to signal failure
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _log.info("Creating database table '$_tableName'...");
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastModified TEXT NOT NULL
      )
    ''');
    _log.info("Database table '$_tableName' created.");
  }
}
