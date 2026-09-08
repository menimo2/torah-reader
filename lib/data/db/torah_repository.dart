import 'package:flutter/foundation.dart';

import '../memory/book_cache.dart';
import '../models/torah_verse.dart';
import '../models/torah_word.dart';
import 'app_database.dart';

class TorahRepository {
  TorahRepository(this._db, {BookCache? cache}) : _cache = cache ?? BookCache();
  final AppDatabase _db;
  final BookCache _cache;

  Future<List<TorahVerse>> chapter(String book, int chapter) async {
    final db = await _db.open();
    final verseRows = await db.query(
      'verses',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
      orderBy: 'verse ASC',
    );
    if (verseRows.isEmpty) return const [];

    final osisIds = verseRows.map((r) => r['osis_id'] as String).toList();
    final placeholders = List.filled(osisIds.length, '?').join(',');
    final wordRows = await db.rawQuery(
      'SELECT * FROM words WHERE osis_id IN ($placeholders) ORDER BY osis_id, word_index',
      osisIds,
    );

    final wordsByVerse = <String, List<TorahWord>>{};
    for (final row in wordRows) {
      final osis = row['osis_id'] as String;
      wordsByVerse.putIfAbsent(osis, () => []).add(TorahWord.fromDb(row));
    }

    return [
      for (final row in verseRows)
        TorahVerse(
          osisId: row['osis_id'] as String,
          book: row['book'] as String,
          chapter: row['chapter'] as int,
          verse: row['verse'] as int,
          words: wordsByVerse[row['osis_id'] as String] ?? const [],
        ),
    ];
  }

  Future<List<TorahVerse>> range({
    required String book,
    required int startChapter,
    required int startVerse,
    required int endChapter,
    required int endVerse,
  }) async {
    if (kIsWeb) {
      final verses = await _cache.versesFor(book);
      return _cache.range(
        verses: verses,
        startChapter: startChapter,
        startVerse: startVerse,
        endChapter: endChapter,
        endVerse: endVerse,
      );
    }
    final db = await _db.open();
    final verseRows = await db.rawQuery(
      '''
      SELECT * FROM verses
      WHERE book = ?
        AND (
          chapter > ? OR (chapter = ? AND verse >= ?)
        )
        AND (
          chapter < ? OR (chapter = ? AND verse <= ?)
        )
      ORDER BY chapter ASC, verse ASC
      ''',
      [
        book,
        startChapter,
        startChapter,
        startVerse,
        endChapter,
        endChapter,
        endVerse,
      ],
    );
    if (verseRows.isEmpty) return const [];

    final osisIds = verseRows.map((r) => r['osis_id'] as String).toList();
    final placeholders = List.filled(osisIds.length, '?').join(',');
    final wordRows = await db.rawQuery(
      'SELECT * FROM words WHERE osis_id IN ($placeholders) ORDER BY osis_id, word_index',
      osisIds,
    );

    final wordsByVerse = <String, List<TorahWord>>{};
    for (final row in wordRows) {
      final osis = row['osis_id'] as String;
      wordsByVerse.putIfAbsent(osis, () => []).add(TorahWord.fromDb(row));
    }

    return [
      for (final row in verseRows)
        TorahVerse(
          osisId: row['osis_id'] as String,
          book: row['book'] as String,
          chapter: row['chapter'] as int,
          verse: row['verse'] as int,
          words: wordsByVerse[row['osis_id'] as String] ?? const [],
        ),
    ];
  }

  Future<void> insertBook(List<TorahVerse> verses, {required int sortBase}) async {
    final db = await _db.open();
    const chunk = 80;
    for (var i = 0; i < verses.length; i += chunk) {
      final slice = verses.sublist(
        i,
        i + chunk > verses.length ? verses.length : i + chunk,
      );
      final batch = db.batch();
      for (var j = 0; j < slice.length; j++) {
        final verse = slice[j];
        batch.insert('verses', {
          'osis_id': verse.osisId,
          'book': verse.book,
          'chapter': verse.chapter,
          'verse': verse.verse,
          'sort_index': sortBase + i + j,
        });
        for (final word in verse.words) {
          batch.insert('words', {
            'osis_id': verse.osisId,
            'word_index': word.wordIndex,
            'full_text': word.fullText,
            'taam_name': word.taamName,
            'has_taam': word.hasTaam ? 1 : 0,
            'taam_time_bonus': word.taamTimeBonus,
          });
        }
      }
      await batch.commit(noResult: true);
    }
  }
}
