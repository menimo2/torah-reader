import 'package:xml/xml.dart';

import '../../core/hebrew_text.dart';
import '../models/torah_verse.dart';
import '../models/torah_word.dart';

class MorphhbParser {
  const MorphhbParser();

  List<TorahVerse> parse(String xml, {required String bookOsis}) {
    final document = XmlDocument.parse(xml);
    final verses = <TorahVerse>[];

    for (final verseEl in document.descendants.whereType<XmlElement>()) {
      if (verseEl.localName != 'verse') continue;
      final osisId = verseEl.getAttribute('osisID');
      if (osisId == null) continue;

      final parsedId = _parseOsisId(osisId);
      if (parsedId == null) continue;
      if (parsedId.book != bookOsis) continue;

      final words = _parseWords(verseEl);
      if (words.isEmpty) continue;

      verses.add(
        TorahVerse(
          osisId: osisId,
          book: parsedId.book,
          chapter: parsedId.chapter,
          verse: parsedId.verse,
          words: words,
        ),
      );
    }

    return verses;
  }

  List<TorahWord> _parseWords(XmlElement verseEl) {
    final built = <_WordDraft>[];

    for (final node in verseEl.children) {
      if (node is! XmlElement) continue;
      switch (node.localName) {
        case 'w':
          final raw = node.innerText;
          final cleaned = HebrewText.stripSlash(raw).trim();
          if (cleaned.isEmpty) continue;
          built.add(_WordDraft(cleaned));
        case 'seg':
          final type = node.getAttribute('type');
          if (type == 'x-sof-pasuq') {
            if (built.isNotEmpty) {
              built.last.endsVerse = true;
            }
          } else if (type == 'x-paseq') {
            if (built.isNotEmpty) {
              built.last.hasPaseq = true;
            }
          } else if (type == 'x-maqqef') {
            if (built.isNotEmpty) {
              built.last.text = '${built.last.text}\u05BE';
            }
          }
        default:
          break;
      }
    }

    return [
      for (var i = 0; i < built.length; i++)
        TorahWord.fromParsed(
          fullText: built[i].text,
          wordIndex: i,
          endsVerse: built[i].endsVerse,
          hasPaseq: built[i].hasPaseq,
        ),
    ];
  }

  _OsisRef? _parseOsisId(String osisId) {
    final parts = osisId.split('.');
    if (parts.length != 3) return null;
    final chapter = int.tryParse(parts[1]);
    final verse = int.tryParse(parts[2]);
    if (chapter == null || verse == null) return null;
    return _OsisRef(book: parts[0], chapter: chapter, verse: verse);
  }
}

class _WordDraft {
  _WordDraft(this.text);
  String text;
  bool endsVerse = false;
  bool hasPaseq = false;
}

class _OsisRef {
  const _OsisRef({
    required this.book,
    required this.chapter,
    required this.verse,
  });
  final String book;
  final int chapter;
  final int verse;
}
