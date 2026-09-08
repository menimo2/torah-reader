import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hebrew_numerals.dart';
import '../../core/parashot.dart';
import '../../core/reading_mode.dart';
import '../../data/models/torah_verse.dart';
import '../../data/models/torah_word.dart';
import '../../data/providers.dart';
import 'hold_to_peek.dart';

class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key, required this.mode});

  final ReadingMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(passageSelectionProvider);
    final catalog = ref.watch(parashaCatalogProvider);
    final version = ref.watch(textVersionProvider);
    final verses = ref.watch(passageVersesProvider);
    final isPractice = mode == ReadingMode.practice;
    final displayVersion = isPractice ? version : TextVersion.bare;

    final parashaName = catalog.maybeWhen(
      data: (c) =>
          (c.find(selection.parashaId) ?? c.byId(PassageSelection.initial.parashaId))
              .hebrewName,
      orElse: () => selection.parashaId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$parashaName · ${selection.aliyahLabel}'),
      ),
      body: Column(
        children: [
          if (isPractice)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'תצוגה',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TextVersion>(
                    isExpanded: true,
                    value: version,
                    items: const [
                      DropdownMenuItem(
                        value: TextVersion.bare,
                        child: Text('עירום'),
                      ),
                      DropdownMenuItem(
                        value: TextVersion.nikud,
                        child: Text('עם ניקוד'),
                      ),
                      DropdownMenuItem(
                        value: TextVersion.full,
                        child: Text('הכל ביחד'),
                      ),
                    ],
                    onChanged: (next) {
                      if (next != null) {
                        ref.read(textVersionProvider.notifier).setVersion(next);
                      }
                    },
                  ),
                ),
              ),
            ),
          Expanded(
            child: verses.when(
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('טוען את הקטע…'),
                  ],
                ),
              ),
              error: (error, _) => Center(child: Text('שגיאה: $error')),
              data: (data) => HoldToPeek(
                builder: (context, peeking) {
                  final shown = peeking ? TextVersion.full : displayVersion;
                  return TorahChapterView(
                    verses: data,
                    version: shown,
                    hebrewRefs: isPractice,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TorahChapterView extends StatelessWidget {
  const TorahChapterView({
    super.key,
    required this.verses,
    required this.version,
    this.hebrewRefs = false,
  });

  final List<TorahVerse> verses;
  final TextVersion version;
  final bool hebrewRefs;

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(child: Text('אין פסוקים בקטע זה'));
    }

    const textStyle = TextStyle(
      fontFamily: 'EzraSIL',
      fontSize: 26,
      height: 1.8,
    );

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
                TextSpan(
                  text: hebrewRefs
                      ? '${hebrewChapterVerse(verse.chapter, verse.verse)}  '
                      : '${verse.chapter}:${verse.verse}  ',
                  style: textStyle.copyWith(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'EzraSIL',
                  ),
                ),
                for (var i = 0; i < verse.words.length; i++)
                  TextSpan(
                    text: '${verse.words[i].display(version)}'
                        '${i == verse.words.length - 1 ? '' : ' '}',
                  ),
              ],
            ),
            textDirection: TextDirection.rtl,
            style: textStyle,
          ),
        );
      },
    );
  }
}
