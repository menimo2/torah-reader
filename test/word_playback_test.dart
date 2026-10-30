import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/data/models/torah_word.dart';
import 'package:torah_reader/features/reading/word_playback.dart';

void main() {
  final words = [
    const TorahWord(
      fullText: 'ראובן',
      wordIndex: 0,
      taamName: 'רביע',
      hasTaam: true,
    ),
    const TorahWord(
      fullText: 'שמעון',
      wordIndex: 1,
      taamName: 'גרשים',
      hasTaam: true,
    ),
  ];

  test('counts 3 to 0 then colors words by catalog ms', () {
    fakeAsync((async) {
      final playback = WordPlaybackController();
      playback.start(words);

      expect(playback.status, PlaybackStatus.countdown);
      expect(playback.countdownRemaining, 3);
      expect(playback.upcomingWord?.fullText, 'ראובן');
      expect(playback.upcomingIndex, 0);

      async.elapse(const Duration(seconds: 1));
      expect(playback.countdownRemaining, 2);
      async.elapse(const Duration(seconds: 1));
      expect(playback.countdownRemaining, 1);
      async.elapse(const Duration(seconds: 1));
      expect(playback.countdownRemaining, 0);
      async.elapse(const Duration(seconds: 1));

      expect(playback.status, PlaybackStatus.playing);
      expect(playback.currentIndex, 0);
      expect(playback.upcomingWord?.fullText, 'שמעון');
      expect(playback.upcomingIndex, 1);

      async.elapse(const Duration(milliseconds: 1100));
      expect(playback.currentIndex, 1);
      expect(playback.upcomingWord, isNull);

      async.elapse(const Duration(milliseconds: 1100));
      expect(playback.status, PlaybackStatus.finished);
      playback.dispose();
    });
  });

  test('settings color time replaces the catalog duration', () {
    fakeAsync((async) {
      final playback = WordPlaybackController()..colorMsById = {'revia': 250};
      playback.start(words);

      async.elapse(const Duration(seconds: 4));
      expect(playback.currentIndex, 0);

      async.elapse(const Duration(milliseconds: 250));
      expect(playback.currentIndex, 1);

      playback.dispose();
    });
  });

  test('sign is held for the upcoming taam colorMs', () {
    fakeAsync((async) {
      final playback = WordPlaybackController();
      const holdWords = [
        TorahWord(
          fullText: 'ראובן',
          wordIndex: 0,
          taamName: 'מונח',
          hasTaam: true,
        ),
        TorahWord(
          fullText: 'שמעון',
          wordIndex: 1,
          taamName: 'גרשים',
          hasTaam: true,
        ),
      ];
      playback.start(holdWords);

      expect(playback.displayedSign, isNull);
      async.elapse(const Duration(seconds: 4));

      expect(playback.status, PlaybackStatus.playing);
      expect(playback.currentIndex, 0);
      expect(playback.displayedSign?.taamName, 'גרשים');

      async.elapse(const Duration(milliseconds: 580));
      expect(playback.currentIndex, 1);
      expect(playback.displayedSign?.taamName, 'גרשים');

      async.elapse(const Duration(milliseconds: 519));
      expect(playback.displayedSign?.taamName, 'גרשים');

      async.elapse(const Duration(milliseconds: 1));
      expect(playback.displayedSign, isNull);

      playback.dispose();
    });
  });

  test('pause keeps the place and resume continues the rest', () {
    fakeAsync((async) {
      var now = DateTime(2026);
      final playback = WordPlaybackController(now: () => now);
      playback.start(words);
      for (var i = 0; i < 4; i++) {
        now = now.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      expect(playback.currentIndex, 0);
      expect(playback.highlightedIndex, 0);

      now = now.add(const Duration(milliseconds: 400));
      async.elapse(const Duration(milliseconds: 400));
      playback.pause();
      expect(playback.status, PlaybackStatus.paused);
      expect(playback.highlightedIndex, 0);

      now = now.add(const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 5));
      expect(playback.currentIndex, 0);

      playback.resume();
      now = now.add(const Duration(milliseconds: 699));
      async.elapse(const Duration(milliseconds: 699));
      expect(playback.currentIndex, 0);
      now = now.add(const Duration(milliseconds: 1));
      async.elapse(const Duration(milliseconds: 1));
      expect(playback.currentIndex, 1);

      playback.dispose();
    });
  });

  test('stop cancels countdown', () {
    fakeAsync((async) {
      final playback = WordPlaybackController();
      playback.start(words);
      async.elapse(const Duration(seconds: 1));
      playback.stop();
      expect(playback.status, PlaybackStatus.idle);
      async.elapse(const Duration(seconds: 5));
      expect(playback.status, PlaybackStatus.idle);
      expect(playback.currentIndex, -1);
      playback.dispose();
    });
  });
}
