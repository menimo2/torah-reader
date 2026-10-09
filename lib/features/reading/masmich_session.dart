import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_font.dart';
import '../../core/hand_signs.dart';
import '../../data/models/torah_verse.dart';
import '../../data/models/torah_word.dart';
import '../../data/sign_settings.dart';
import 'hold_to_peek.dart';
import 'sign_pack_image.dart';
import 'word_playback.dart';

const _textStyle = TextStyle(
  fontFamily: AppFont.family,
  fontSize: 26,
  height: 2.0,
);

const _strut = StrutStyle(
  fontFamily: AppFont.family,
  fontSize: 26,
  height: 2.0,
  forceStrutHeight: true,
);

class MasmichScreen extends ConsumerStatefulWidget {
  const MasmichScreen({
    super.key,
    required this.title,
    required this.verses,
  });

  final String title;
  final List<TorahVerse> verses;

  @override
  ConsumerState<MasmichScreen> createState() => _MasmichScreenState();
}

class _MasmichScreenState extends ConsumerState<MasmichScreen> {
  late final WordPlaybackController _playback = WordPlaybackController();
  double _barScale = 1;

  List<TorahWord> get _words => WordPlaybackController.flatten(widget.verses);

  @override
  void initState() {
    super.initState();
    _playback.addListener(_onPlayback);
  }

  void _onPlayback() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _playback.removeListener(_onPlayback);
    _playback.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_playback.isActive) {
      _playback.stop();
    } else {
      _playback.start(_words);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(signSettingsProvider);
    _playback.shownSignIds = settings.shownIds;
    final counting = _playback.status == PlaybackStatus.countdown;
    final sign = _playback.displayedSign;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 88,
        leading: TextButton(
          onPressed: _words.isEmpty ? null : _toggle,
          child: Text(_playback.isActive ? 'עצור' : 'התחל'),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'חזרה',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Stack(
        children: [
          HoldToPeek(
            builder: (context, peeking) {
              return MasmichFlowText(
                verses: widget.verses,
                version: peeking ? TextVersion.full : TextVersion.bare,
                highlightIndex: _playback.status == PlaybackStatus.playing
                    ? _playback.currentIndex
                    : null,
              );
            },
          ),
          if (counting)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_playback.countdownRemaining}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.45),
                      ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: MasmichBottomBar(
        sign: sign,
        pack: settings.pack,
        imageBytes: sign == null ? null : settings.overrides[sign.id],
        scale: _barScale,
        onScaleDrag: (dy) {
          setState(() {
            _barScale = (_barScale - dy / 160).clamp(0.75, 2.0);
          });
        },
      ),
    );
  }
}

/// Bare flowing text. No verse refs, no overlay — the sign lives in the bar.
///
/// Each word keeps the wider of its bare and full forms, so a maqaf (the
/// hyphen-like ־) cannot change the line breaks when peeking.
class MasmichFlowText extends StatelessWidget {
  const MasmichFlowText({
    super.key,
    required this.verses,
    required this.version,
    this.highlightIndex,
  });

  final List<TorahVerse> verses;
  final TextVersion version;
  final int? highlightIndex;

  static const padding = EdgeInsets.fromLTRB(16, 16, 16, 32);

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(child: Text('אין פסוקים בקטע זה'));
    }

    final highlightStyle = _textStyle.copyWith(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);

    final words = [
      for (final verse in verses) ...verse.words,
    ];

    return SingleChildScrollView(
      padding: padding,
      child: Wrap(
        textDirection: TextDirection.rtl,
        spacing: _measure(' ', scaler, locale),
        children: [
          for (var i = 0; i < words.length; i++)
            _FixedWord(
              key: ValueKey('masmich-word-$i'),
              text: words[i].display(version),
              width: _slotWidth(
                words[i].display(TextVersion.bare),
                words[i].display(TextVersion.full),
                scaler,
                locale,
              ),
              style: highlightIndex == i ? highlightStyle : _textStyle,
            ),
        ],
      ),
    );
  }

  static double _slotWidth(
    String bare,
    String full,
    TextScaler scaler,
    Locale? locale,
  ) {
    final bareWidth = _measure(bare, scaler, locale);
    final fullWidth = _measure(full, scaler, locale);
    final width = bareWidth > fullWidth ? bareWidth : fullWidth;
    if (width <= 0) return 0;
    return width;
  }

  static double _measure(String text, TextScaler scaler, Locale? locale) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      textDirection: TextDirection.rtl,
      textScaler: scaler,
      locale: locale,
      strutStyle: _strut,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _FixedWord extends StatelessWidget {
  const _FixedWord({
    super.key,
    required this.text,
    required this.width,
    required this.style,
  });

  final String text;
  final double width;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: style,
        textDirection: TextDirection.rtl,
        softWrap: false,
        overflow: TextOverflow.visible,
        strutStyle: _strut,
      ),
    );
  }
}

/// Sticky footer: how-to + next-word sign on the visual left.
/// Drag the top edge to resize; the sign and the how-to text scale with it.
class MasmichBottomBar extends StatelessWidget {
  const MasmichBottomBar({
    super.key,
    this.sign,
    this.pack = SignPack.image,
    this.imageBytes,
    this.scale = 1,
    required this.onScaleDrag,
  });

  final HandSign? sign;
  final SignPack pack;
  final Uint8List? imageBytes;
  final double scale;
  final ValueChanged<double> onScaleDrag;

  static const _baseCircle = 160.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final circleSize = _baseCircle * scale;
    final howToStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.35,
          fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) *
              scale,
        );

    return Material(
      elevation: 8,
      color: scheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) => onScaleDrag(details.delta.dy),
            child: Container(
              height: 18,
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2.5),
                ),
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8 * scale, 12, 10),
              child: Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: sign == null
                        ? null
                        : TaamSign(
                            sign: sign!,
                            pack: pack,
                            size: circleSize,
                            imageBytes: imageBytes,
                          ),
                  ),
                  SizedBox(width: 12 * scale.clamp(0.8, 1.4)),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        'הסימן משמאל — עזרה לטעם של המילה הבאה.\n'
                        'החזקה ארוכה על המלל מציגה את הכל.',
                        style: howToStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaamSign extends StatelessWidget {
  const TaamSign({
    super.key,
    required this.sign,
    required this.pack,
    this.size = 120,
    this.imageBytes,
  });

  final HandSign sign;
  final SignPack pack;
  final double size;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final markSize = size * 0.5;
    return switch (pack) {
      SignPack.alephTaam => Center(
          child: Text(
            sign.alephMark,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AppFont.family,
              fontSize: markSize,
              height: 1,
            ),
          ),
        ),
      SignPack.name => Center(
          child: Text(
            sign.sephardiName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize:
                      (Theme.of(context).textTheme.titleMedium?.fontSize ??
                              16) *
                          (size / 120),
                ),
          ),
        ),
      SignPack.image => SignPackImage(
          asset: sign.imageAsset,
          size: size,
          memoryBytes: imageBytes,
        ),
    };
  }
}
