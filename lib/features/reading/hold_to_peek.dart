import 'dart:async';

import 'package:flutter/material.dart';

/// Hold still for [duration], then [peeking] is true until the pointer is released.
class HoldToPeek extends StatefulWidget {
  const HoldToPeek({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Duration duration;
  final Widget Function(BuildContext context, bool peeking) builder;

  @override
  State<HoldToPeek> createState() => _HoldToPeekState();
}

class _HoldToPeekState extends State<HoldToPeek> {
  static const _slop = 16.0;

  Timer? _timer;
  bool _peeking = false;
  Offset? _down;

  void _start(Offset position) {
    _timer?.cancel();
    _down = position;
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(() => _peeking = true);
    });
  }

  void _cancelTimerOnly() {
    _timer?.cancel();
    _timer = null;
    _down = null;
  }

  void _release() {
    _cancelTimerOnly();
    if (_peeking && mounted) {
      setState(() => _peeking = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _start(event.position),
      onPointerMove: (event) {
        if (_peeking || _down == null) return;
        if ((event.position - _down!).distance > _slop) {
          _cancelTimerOnly();
        }
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: widget.builder(context, _peeking),
    );
  }
}
