import 'package:day5/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteController {
  static final SqliteController _singleton = SqliteController._internal();
  factory SqliteController() => _singleton;
  SqliteController._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY , title TEXT, description TEXT)',
        );
      },
    );
  }

  Future<void> insert(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("notes");
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<void> update(Note note) async {
    final db = await database;
    await db.update('notes', note.toMap(), where: 'id=?', whereArgs: [note.id]);
  }

  Future<void> delete(int? id) async {
    final db = await database;
    db.delete('notes', where: 'id=?', whereArgs: [id]);
  }
}
