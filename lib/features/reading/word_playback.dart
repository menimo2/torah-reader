import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/hand_signs.dart';
import '../../data/models/torah_verse.dart';
import '../../data/models/torah_word.dart';

enum PlaybackStatus { idle, countdown, playing, paused, finished }

/// Word-by-word coloring. Shared by masmich (and later practice).
///
/// Uses [Timer], not [Future.delayed], so we can stop. Speed comes from
/// Settings later; [speedFactor] is 1 until then.
class WordPlaybackController extends ChangeNotifier {
  WordPlaybackController({
    this.speedFactor = 1,
    this.countdownStep = const Duration(seconds: 1),
    DateTime Function()? now,
    Set<String>? shownSignIds,
  })  : now = now ?? DateTime.now,
        shownSignIds = shownSignIds ?? {
          for (final sign in JerusalemHandSigns.starterSet) sign.id,
        };

  final DateTime Function() now;

  final double speedFactor;
  final Duration countdownStep;

  /// Which masmich signs are on. From Settings.
  Set<String> shownSignIds;

  /// Color durations changed in Settings, keyed by sign id.
  Map<String, int> colorMsById = {};

  Timer? _timer;
  DateTime? _segmentStarted;
  int? _segmentBudgetMs;
  DateTime? _signStarted;
  int? _signBudgetMs;
  int? _pausedSegmentLeft;
  int? _pausedSignLeft;
  PlaybackStatus? _pausedStatus;
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

  bool get isPaused => status == PlaybackStatus.paused;

  /// Countdown number stays on screen while that countdown is paused.
  bool get showCountdown =>
      status == PlaybackStatus.countdown ||
      (status == PlaybackStatus.paused &&
          _pausedStatus == PlaybackStatus.countdown);

  /// Word color stays while playback is paused on that word.
  int? get highlightedIndex {
    if (status == PlaybackStatus.playing) return currentIndex;
    if (status == PlaybackStatus.paused &&
        _pausedStatus == PlaybackStatus.playing &&
        currentIndex >= 0) {
      return currentIndex;
    }
    return null;
  }

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
    _arm(countdownStep.inMilliseconds, _onCountdownTick);
  }

  /// Freeze the countdown or the current word. The place is kept.
  void pause() {
    if (!isActive) return;
    _pausedSegmentLeft = _remaining(_segmentStarted, _segmentBudgetMs);
    _pausedSignLeft =
        _holdingSign ? _remaining(_signStarted, _signBudgetMs) : null;
    _timer?.cancel();
    _timer = null;
    _signTimer?.cancel();
    _signTimer = null;
    _pausedStatus = status;
    status = PlaybackStatus.paused;
    notifyListeners();
  }

  /// Continue from [pause]. Does not go back to the beginning.
  void resume() {
    if (status != PlaybackStatus.paused) return;
    final back = _pausedStatus ?? PlaybackStatus.playing;
    final segmentLeft = _pausedSegmentLeft ?? 1;
    final signLeft = _pausedSignLeft;
    _pausedStatus = null;
    _pausedSegmentLeft = null;
    _pausedSignLeft = null;
    status = back;
    if (back == PlaybackStatus.countdown) {
      _arm(segmentLeft, _onCountdownTick);
    } else {
      _arm(segmentLeft, _advance);
    }
    if (_holdingSign && signLeft != null) {
      _armSign(signLeft);
    }
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _segmentStarted = null;
    _segmentBudgetMs = null;
    _pausedSegmentLeft = null;
    _pausedSignLeft = null;
    _pausedStatus = null;
    _clearDisplayedSign();
    status = PlaybackStatus.idle;
    countdownRemaining = null;
    currentIndex = -1;
    notifyListeners();
  }

  void _arm(int milliseconds, void Function() onFire) {
    final ms = milliseconds < 1 ? 1 : milliseconds;
    _segmentBudgetMs = ms;
    _segmentStarted = now();
    _timer = Timer(Duration(milliseconds: ms), onFire);
  }

  void _armSign(int milliseconds) {
    final ms = milliseconds < 1 ? 1 : milliseconds;
    _signBudgetMs = ms;
    _signStarted = now();
    _signTimer = Timer(Duration(milliseconds: ms), _onSignHoldDone);
  }

  int _remaining(DateTime? started, int? budget) {
    if (started == null || budget == null) return 1;
    final used = now().difference(started).inMilliseconds;
    final left = budget - used;
    return left < 1 ? 1 : left;
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
    _arm(countdownStep.inMilliseconds, _onCountdownTick);
  }

  void _playIndex(int index) {
    status = PlaybackStatus.playing;
    currentIndex = index;
    _syncDisplayedSign();
    notifyListeners();
    final ms = _colorMs(_words[index].taamName);
    final scaled = (ms * speedFactor).round().clamp(1, 60000);
    _arm(scaled, _advance);
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
    final ms = (_colorMs(sign.taamName) * speedFactor).round().clamp(1, 60000);
    _armSign(ms);
  }

  int _colorMs(String? taamName) {
    final sign = JerusalemHandSigns.of(taamName);
    if (sign == null) return JerusalemHandSigns.noTaamColorMs;
    return colorMsById[sign.id] ?? sign.colorMs;
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
    _signStarted = null;
    _signBudgetMs = null;
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
