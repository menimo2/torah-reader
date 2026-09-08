import 'package:flutter/services.dart';

import '../../core/books.dart';
import '../../core/verse_ref.dart';
import '../models/torah_verse.dart';
import '../xml/morphhb_parser.dart';

/// In-memory book cache (used on web so Chrome does not need SQLite).
class BookCache {
  BookCache({this.parser = const MorphhbParser()});

  final MorphhbParser parser;
  final Map<String, List<TorahVerse>> _books = {};

  Future<List<TorahVerse>> versesFor(String bookOsis) async {
    final existing = _books[bookOsis];
    if (existing != null) return existing;
    final book = Books.byOsis(bookOsis);
    final xml = await rootBundle.loadString(book.assetFile);
    final verses = parser.parse(xml, bookOsis: bookOsis);
    _books[bookOsis] = verses;
    return verses;
  }

  List<TorahVerse> range({
    required List<TorahVerse> verses,
    required int startChapter,
    required int startVerse,
    required int endChapter,
    required int endVerse,
  }) {
    final start = VerseRef(chapter: startChapter, verse: startVerse);
    final end = VerseRef(chapter: endChapter, verse: endVerse);
    return [
      for (final verse in verses)
        if (verseInInclusiveRange(
          chapter: verse.chapter,
          verse: verse.verse,
          start: start,
          end: end,
        ))
          verse,
    ];
  }
}
