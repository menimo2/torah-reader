import 'torah_word.dart';

class TorahVerse {
  const TorahVerse({
    required this.osisId,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.words,
  });

  final String osisId;
  final String book;
  final int chapter;
  final int verse;
  final List<TorahWord> words;
}
