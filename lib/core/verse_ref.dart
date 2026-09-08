class VerseRef implements Comparable<VerseRef> {
  const VerseRef({required this.chapter, required this.verse});

  final int chapter;
  final int verse;

  factory VerseRef.fromJson(Map<String, dynamic> json) {
    return VerseRef(
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
    );
  }

  @override
  int compareTo(VerseRef other) {
    final byChapter = chapter.compareTo(other.chapter);
    if (byChapter != 0) return byChapter;
    return verse.compareTo(other.verse);
  }

  bool get isValid => chapter > 0 && verse > 0;
}

bool verseInInclusiveRange({
  required int chapter,
  required int verse,
  required VerseRef start,
  required VerseRef end,
}) {
  final point = VerseRef(chapter: chapter, verse: verse);
  return point.compareTo(start) >= 0 && point.compareTo(end) <= 0;
}
