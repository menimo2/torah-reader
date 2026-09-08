import 'package:flutter/services.dart';

import '../../core/books.dart';
import '../db/app_database.dart';
import '../db/torah_repository.dart';
import '../xml/morphhb_parser.dart';

class ImportProgress {
  const ImportProgress({
    required this.bookName,
    required this.bookIndex,
    required this.bookCount,
  });

  final String bookName;
  final int bookIndex;
  final int bookCount;

  double get fraction => bookCount == 0 ? 0 : bookIndex / bookCount;
}

class TextImporter {
  TextImporter({
    required this.database,
    required this.repository,
    this.parser = const MorphhbParser(),
  });

  final AppDatabase database;
  final TorahRepository repository;
  final MorphhbParser parser;

  Future<bool> needsImport() async {
    final version = await database.meta('wlc_import_version');
    return version != wlcImportVersion;
  }

  Future<void> importAll({
    required void Function(ImportProgress progress) onProgress,
  }) async {
    final db = await database.open();
    await db.delete('words');
    await db.delete('verses');

    var sortBase = 0;
    for (var i = 0; i < Books.chumash.length; i++) {
      final book = Books.chumash[i];
      onProgress(
        ImportProgress(
          bookName: book.hebrewName,
          bookIndex: i,
          bookCount: Books.chumash.length,
        ),
      );
      final xml = await rootBundle.loadString(book.assetFile);
      final verses = parser.parse(xml, bookOsis: book.osis);
      await repository.insertBook(verses, sortBase: sortBase);
      sortBase += verses.length;
    }

    await database.setMeta('wlc_import_version', wlcImportVersion);
    onProgress(
      ImportProgress(
        bookName: 'סיום',
        bookIndex: Books.chumash.length,
        bookCount: Books.chumash.length,
      ),
    );
  }
}
