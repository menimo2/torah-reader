import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/data/models/torah_verse.dart';
import 'package:torah_reader/data/models/torah_word.dart';
import 'package:torah_reader/features/reading/masmich_session.dart';

void main() {
  testWidgets('peek does not move words when a maqaf is shown', (tester) async {
    final words = [
      for (var i = 0; i < 40; i++)
        TorahWord(
          fullText: i.isEven ? 'עַל־' : 'פְּנֵי',
          wordIndex: i,
        ),
    ];
    final verses = [
      TorahVerse(
        osisId: 'Gen.1.1',
        book: 'Gen',
        chapter: 1,
        verse: 1,
        words: words,
      ),
    ];

    Future<void> pump(TextVersion version) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 320,
              child: MasmichFlowText(verses: verses, version: version),
            ),
          ),
        ),
      );
    }

    await pump(TextVersion.bare);
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    scroll.position.jumpTo(80);
    await tester.pump();

    final before = tester.getRect(find.byKey(const ValueKey('masmich-word-8')));
    final offset = scroll.position.pixels;

    await pump(TextVersion.full);

    final after = tester.getRect(find.byKey(const ValueKey('masmich-word-8')));
    expect(scroll.position.pixels, offset);
    expect(after.top, closeTo(before.top, 0.1));
    expect(after.right, closeTo(before.right, 0.1));
  });

  testWidgets('first words run from the right', (tester) async {
    final texts = ['בראשית', 'ברא', 'אלהים', 'את', 'השמים', 'ואת'];
    final verses = [
      TorahVerse(
        osisId: 'Gen.1.1',
        book: 'Gen',
        chapter: 1,
        verse: 1,
        words: [
          for (var i = 0; i < texts.length; i++)
            TorahWord(fullText: texts[i], wordIndex: i),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 800,
            height: 200,
            child: MasmichFlowText(verses: verses, version: TextVersion.bare),
          ),
        ),
      ),
    );

    final first = tester.getRect(find.byKey(const ValueKey('masmich-word-0')));
    final second = tester.getRect(find.byKey(const ValueKey('masmich-word-1')));
    expect(find.text('בראשית'), findsOneWidget);
    expect(first.top, closeTo(second.top, 0.1));
    expect(first.left, greaterThan(second.right));
  });
}
