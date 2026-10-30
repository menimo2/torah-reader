import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_font.dart';
import '../../data/providers.dart';

/// Aliyot 1–7, shown inside both reading windows.
const aliyahQuickIds = ['1', '2', '3', '4', '5', '6', '7'];

const aliyahQuickMarks = {
  '1': 'א',
  '2': 'ב',
  '3': 'ג',
  '4': 'ד',
  '5': 'ה',
  '6': 'ו',
  '7': 'ז',
};

class AliyahQuickBar extends ConsumerWidget {
  const AliyahQuickBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(passageSelectionProvider).aliyahId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          for (final id in aliyahQuickIds)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _AliyahButton(
                  mark: aliyahQuickMarks[id]!,
                  selected: id == selected,
                  onPressed: () {
                    ref.read(passageSelectionProvider.notifier).setAliyah(id);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AliyahButton extends StatelessWidget {
  const _AliyahButton({
    required this.mark,
    required this.selected,
    required this.onPressed,
  });

  final String mark;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 40),
      textStyle: const TextStyle(
        fontFamily: AppFont.family,
        fontSize: 20,
        height: 1,
      ),
    );
    final child = Text(mark);
    if (selected) {
      return FilledButton(style: style, onPressed: onPressed, child: child);
    }
    return OutlinedButton(style: style, onPressed: onPressed, child: child);
  }
}
