import 'package:flutter/material.dart';

import '../../core/app_font.dart';
import '../../core/hebrew_numerals.dart';
import '../../data/models/torah_verse.dart';
import '../../data/models/torah_word.dart';

class TorahChapterView extends StatelessWidget {
  const TorahChapterView({
    super.key,
    required this.verses,
    required this.version,
    this.showVerseRefs = false,
    this.separateVerses = true,
    this.highlightIndex,
  });

  final List<TorahVerse> verses;
  final TextVersion version;

  /// Practice only — chumash-style פרק:פסוק. Never in masmich (reveals sof pasuk).
  final bool showVerseRefs;

  /// Practice: one block per verse. Masmich: one flowing paragraph, no verse breaks.
  final bool separateVerses;

  /// Flat word index to color. Used by masmich playback.
  final int? highlightIndex;

  static const _textStyle = TextStyle(
    fontFamily: AppFont.family,
    fontSize: 26,
    height: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(child: Text('אין פסוקים בקטע זה'));
    }

    final highlightStyle = _textStyle.copyWith(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );

    if (!separateVerses) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Text.rich(
          TextSpan(children: _wordSpans(verses, highlightStyle)),
          textDirection: TextDirection.rtl,
          style: _textStyle,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text.rich(
            TextSpan(
              children: [
                if (showVerseRefs)
                  TextSpan(
                    text: '${hebrewChapterVerse(verse.chapter, verse.verse)}  ',
                    style: _textStyle.copyWith(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ..._wordSpans([verse], highlightStyle),
              ],
            ),
            textDirection: TextDirection.rtl,
            style: _textStyle,
          ),
        );
      },
    );
  }

  List<InlineSpan> _wordSpans(
    List<TorahVerse> fromVerses,
    TextStyle highlightStyle,
  ) {
    final spans = <InlineSpan>[];
    var first = true;
    var i = 0;
    for (final verse in fromVerses) {
      for (final word in verse.words) {
        if (!first) {
          spans.add(const TextSpan(text: ' '));
        }
        first = false;
        spans.add(
          TextSpan(
            text: word.display(version),
            style: highlightIndex == i ? highlightStyle : null,
          ),
        );
        i++;
      }
    }
    return spans;
  }
}
