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
}
