import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/parashot.dart';
import '../../core/reading_mode.dart';
import '../../data/models/torah_word.dart';
import '../../data/providers.dart';
import 'hold_to_peek.dart';
import 'masmich_session.dart';
import 'torah_chapter_view.dart';

export 'torah_chapter_view.dart';

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
    final title = '$parashaName · ${selection.aliyahLabel}';

    if (!isPractice) {
      return verses.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('טוען את הקטע…'),
              ],
            ),
          ),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text('שגיאה: $error')),
        ),
        data: (data) => MasmichScreen(title: title, verses: data),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
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
                    showVerseRefs: true,
                    separateVerses: true,
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
