import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hebrew_text.dart';
import 'package:torah_reader/data/models/torah_verse.dart';
import 'package:torah_reader/data/models/torah_word.dart';
import 'package:torah_reader/features/reading/reading_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renders a verse in RTL with Ezra SIL', (tester) async {
    const verses = [
      TorahVerse(
        osisId: 'Gen.1.1',
        book: 'Gen',
        chapter: 1,
        verse: 1,
        words: [
          TorahWord(fullText: 'בְּרֵאשִׁ֖ית', wordIndex: 0),
          TorahWord(fullText: 'בָּרָ֣א', wordIndex: 1),
        ],
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: TorahChapterView(
            verses: verses,
            version: TextVersion.bare,
          ),
        ),
      ),
    );

    expect(find.textContaining('בראשית'), findsOneWidget);
    expect(HebrewText.bare('בְּרֵאשִׁ֖ית'), 'בראשית');
  });

  testWidgets('masmich text has no verse numbers', (tester) async {
    const verses = [
      TorahVerse(
        osisId: 'Gen.1.1',
        book: 'Gen',
        chapter: 1,
        verse: 1,
        words: [TorahWord(fullText: 'בְּרֵאשִׁ֖ית', wordIndex: 0)],
      ),
      TorahVerse(
        osisId: 'Gen.1.2',
        book: 'Gen',
        chapter: 1,
        verse: 2,
        words: [TorahWord(fullText: 'וְהָאָ֗רֶץ', wordIndex: 0)],
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: TorahChapterView(
            verses: verses,
            version: TextVersion.bare,
            showVerseRefs: false,
            separateVerses: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('1:1'), findsNothing);
    expect(find.textContaining('1:2'), findsNothing);
    expect(find.textContaining('א:א'), findsNothing);
    expect(find.textContaining('בראשית'), findsOneWidget);
    expect(find.textContaining('והארץ'), findsOneWidget);
  });
}
