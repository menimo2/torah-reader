import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/hand_signs.dart';
import '../../data/models/torah_verse.dart';
import '../../data/models/torah_word.dart';

enum PlaybackStatus { idle, countdown, playing, finished }

/// Word-by-word coloring. Shared by masmich (and later practice).
///
/// Uses [Timer], not [Future.delayed], so we can stop. Speed comes from
/// Settings later; [speedFactor] is 1 until then.
class WordPlaybackController extends ChangeNotifier {
  WordPlaybackController({
    this.speedFactor = 1,
    this.countdownStep = const Duration(seconds: 1),
    Set<String>? shownSignIds,
  }) : shownSignIds = shownSignIds ?? {
          for (final sign in JerusalemHandSigns.starterSet) sign.id,
        };

  final double speedFactor;
  final Duration countdownStep;

  /// Which masmich signs are on. From Settings.
  Set<String> shownSignIds;

  Timer? _timer;
  List<TorahWord> _words = const [];

  PlaybackStatus status = PlaybackStatus.idle;
  int? countdownRemaining;
  int currentIndex = -1;

  /// Sign in the masmich bar. Held for that taam's [HandSign.colorMs],
  /// even if coloring has already moved on.
  HandSign? displayedSign;

  Timer? _signTimer;
  int? _shownIndex;
  bool _holdingSign = false;

  List<TorahWord> get words => _words;

  bool get isActive =>
      status == PlaybackStatus.countdown || status == PlaybackStatus.playing;

  TorahWord? get currentWord {
    if (status != PlaybackStatus.playing) return null;
    if (currentIndex < 0 || currentIndex >= _words.length) return null;
    return _words[currentIndex];
  }

  /// The taam the masmich shows: the word that is about to be read.
  TorahWord? get upcomingWord {
    if (_words.isEmpty) return null;
    if (status == PlaybackStatus.countdown) return _words.first;
    if (status == PlaybackStatus.playing &&
        currentIndex + 1 < _words.length) {
      return _words[currentIndex + 1];
    }
    return null;
  }

  HandSign? get upcomingSign => JerusalemHandSigns.shownOf(
        upcomingWord?.taamName,
        enabledIds: shownSignIds,
      );

  int? get upcomingIndex {
    if (_words.isEmpty) return null;
    if (status == PlaybackStatus.countdown) return 0;
    if (status == PlaybackStatus.playing &&
        currentIndex + 1 < _words.length) {
      return currentIndex + 1;
    }
    return null;
  }

  static List<TorahWord> flatten(List<TorahVerse> verses) => [
        for (final verse in verses) ...verse.words,
      ];

  void start(List<TorahWord> words) {
    stop();
    _words = List.unmodifiable(words);
    if (_words.isEmpty) return;
    status = PlaybackStatus.countdown;
    countdownRemaining = 3;
    currentIndex = -1;
    _syncDisplayedSign();
    notifyListeners();
    _timer = Timer(countdownStep, _onCountdownTick);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _clearDisplayedSign();
    status = PlaybackStatus.idle;
    countdownRemaining = null;
    currentIndex = -1;
    notifyListeners();
  }

  void _onCountdownTick() {
    final remaining = countdownRemaining;
    if (remaining == null) return;
    if (remaining == 0) {
      countdownRemaining = null;
      _playIndex(0);
      return;
    }
    countdownRemaining = remaining - 1;
    notifyListeners();
    _timer = Timer(countdownStep, _onCountdownTick);
  }

  void _playIndex(int index) {
    status = PlaybackStatus.playing;
    currentIndex = index;
    _syncDisplayedSign();
    notifyListeners();
    final ms = JerusalemHandSigns.colorMsFor(_words[index].taamName);
    final scaled = (ms * speedFactor).round().clamp(1, 60000);
    _timer = Timer(Duration(milliseconds: scaled), _advance);
  }

  void _advance() {
    if (currentIndex + 1 >= _words.length) {
      status = PlaybackStatus.finished;
      _timer = null;
      _syncDisplayedSign();
      notifyListeners();
      return;
    }
    _playIndex(currentIndex + 1);
  }

  void _syncDisplayedSign() {
    final index = upcomingIndex;
    final sign = JerusalemHandSigns.shownOf(
      upcomingWord?.taamName,
      enabledIds: shownSignIds,
    );
    if (_holdingSign) return;
    if (index == _shownIndex && displayedSign?.id == sign?.id) return;
    _commitDisplayedSign(sign, index);
  }

  void _commitDisplayedSign(HandSign? sign, int? index) {
    _signTimer?.cancel();
    _signTimer = null;
    displayedSign = sign;
    _shownIndex = index;
    if (sign == null) {
      _holdingSign = false;
      return;
    }
    _holdingSign = true;
    final ms = (sign.colorMs * speedFactor).round().clamp(1, 60000);
    _signTimer = Timer(Duration(milliseconds: ms), _onSignHoldDone);
  }

  void _onSignHoldDone() {
    _signTimer = null;
    _holdingSign = false;
    _syncDisplayedSign();
    notifyListeners();
  }

  void _clearDisplayedSign() {
    _signTimer?.cancel();
    _signTimer = null;
    _holdingSign = false;
    _shownIndex = null;
    displayedSign = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _signTimer?.cancel();
    super.dispose();
  }
}
