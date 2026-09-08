import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/parashot.dart';
import '../../core/reading_mode.dart';
import '../../data/providers.dart';
import '../reading/passage_picker.dart';
import '../reading/reading_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(passageSelectionProvider);
    final catalog = ref.watch(parashaCatalogProvider);
    final parashaName = catalog.maybeWhen(
      data: (c) =>
          (c.find(selection.parashaId) ?? c.byId(PassageSelection.initial.parashaId))
              .hebrewName,
      orElse: () => '…',
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'הגדרות',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ההגדרות עדיין לא מוכנות')),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton.tonal(
                onPressed: () => showPassagePicker(context),
                child: Text(
                  '$parashaName · ${selection.aliyahLabel}',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => _openReading(context, ReadingMode.practice),
                child: const Text('אימון קריאה', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => _openReading(context, ReadingMode.masmich),
                child: const Text('מסמיך', style: TextStyle(fontSize: 20)),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  void _openReading(BuildContext context, ReadingMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReadingScreen(mode: mode),
      ),
    );
  }
}
