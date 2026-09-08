import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'db_factory.dart';

const wlcImportVersion = '1';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  static void init() => initDatabaseFactory();

  Future<Database> open() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not used on web; verses load in memory.');
    }
    final existing = _db;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'torah_reader.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
            CREATE TABLE verses (
              osis_id TEXT PRIMARY KEY,
              book TEXT NOT NULL,
              chapter INTEGER NOT NULL,
              verse INTEGER NOT NULL,
              sort_index INTEGER NOT NULL
            )
          ''');
        await db.execute('''
            CREATE TABLE words (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              osis_id TEXT NOT NULL,
              word_index INTEGER NOT NULL,
              full_text TEXT NOT NULL,
              taam_name TEXT,
              has_taam INTEGER NOT NULL,
              taam_time_bonus REAL NOT NULL
            )
          ''');
        await db.execute(
          'CREATE INDEX idx_words_osis ON words(osis_id, word_index)',
        );
        await db.execute(
          'CREATE INDEX idx_verses_ref ON verses(book, chapter, verse)',
        );
        await db.execute('''
            CREATE TABLE meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
      },
    );
    _db = db;
    return db;
  }

  Future<String?> meta(String key) async {
    final db = await open();
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await open();
    await db.insert(
      'meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
