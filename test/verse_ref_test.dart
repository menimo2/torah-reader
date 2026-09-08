import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/verse_ref.dart';

void main() {
  test('inclusive range across chapters', () {
    const start = VerseRef(chapter: 1, verse: 1);
    const end = VerseRef(chapter: 2, verse: 3);
    expect(
      verseInInclusiveRange(chapter: 1, verse: 1, start: start, end: end),
      isTrue,
    );
    expect(
      verseInInclusiveRange(chapter: 2, verse: 3, start: start, end: end),
      isTrue,
    );
    expect(
      verseInInclusiveRange(chapter: 2, verse: 4, start: start, end: end),
      isFalse,
    );
  });
}
