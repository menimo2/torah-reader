import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_font.dart';
import '../../core/hand_signs.dart';
import '../../data/sign_settings.dart';
import '../reading/sign_pack_image.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Fixed when the screen opens so toggling does not jump cards.
  List<HandSign>? _openOrder;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(signSettingsProvider);
    if (ref.read(signSettingsProvider.notifier).hydrated) {
      _openOrder ??= settings.orderedSigns;
    }
    final signs = _openOrder ?? settings.orderedSigns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: settings.isAtDefaults
                  ? null
                  : () => _confirmRestore(),
              icon: const Icon(Icons.restore),
              label: const Text('שחזור הגדרות'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'סימן במסמיך',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<SignPack>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: SignPack.alephTaam,
                label: Text('א+טעם'),
              ),
              ButtonSegment(
                value: SignPack.name,
                label: Text('שם'),
              ),
              ButtonSegment(
                value: SignPack.image,
                label: Text('תמונה'),
              ),
            ],
            selected: {settings.pack},
            onSelectionChanged: (next) {
              ref.read(signSettingsProvider.notifier).setPack(next.first);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'כל טעם בשלוש הערכות, עם זמן הצבע. המתג = האם המסמיך מציג אותו. אפשר להחליף תמונה.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          for (final sign in signs)
            _TaamSettingsCard(
              sign: sign,
              shown: settings.isShown(sign.id),
              overrideBytes: settings.overrides[sign.id],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('שחזור הגדרות?'),
          content: const Text(
            'הערכה, הטעמים שמוצגים במסמיך, והתמונות שהוחלפו יחזרו לברירת המחדל.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('שחזור'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(signSettingsProvider.notifier).restoreDefaults();
    if (!mounted) return;
    setState(() {
      _openOrder = ref.read(signSettingsProvider).orderedSigns;
    });
  }
}

class _TaamSettingsCard extends ConsumerWidget {
  const _TaamSettingsCard({
    required this.sign,
    required this.shown,
    this.overrideBytes,
  });

  final HandSign sign;
  final bool shown;
  final Uint8List? overrideBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(sign.sephardiName),
              subtitle: Text(
                shown ? 'מוצג במסמיך' : 'לא מוצג במסמיך',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: shown,
              onChanged: (_) {
                ref.read(signSettingsProvider.notifier).toggleShown(sign.id);
              },
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledBox(
                    label: 'זמן',
                    child: Text(
                      '${sign.colorMs}\nמ״ש',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: _LabeledBox(
                    label: 'א+טעם',
                    child: Text(
                      sign.alephMark,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppFont.family,
                        fontSize: 36,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _LabeledBox(
                    label: 'שם',
                    child: Text(
                      sign.sephardiName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: _LabeledBox(
                    label: 'תמונה',
                    child: Column(
                      children: [
                        SizedBox(
                          height: 88,
                          child: SignPackImage(
                            asset: sign.imageAsset,
                            size: 88,
                            memoryBytes: overrideBytes,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _pickImage(ref),
                          child: const Text('החלף'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!shown)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'הצביעה במסמיך תמשיך. הסימן לא יופיע.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'gif', 'webp'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (bytes == null || bytes.isEmpty) return;
    await ref.read(signSettingsProvider.notifier).setOverride(sign.id, bytes);
  }
}

class _LabeledBox extends StatelessWidget {
  const _LabeledBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
