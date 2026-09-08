import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/books.dart';
import '../../core/parashot.dart';
import '../../data/providers.dart';

Future<void> showPassagePicker(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PassagePickerPage(),
    ),
  );
}

class PassagePickerPage extends ConsumerStatefulWidget {
  const PassagePickerPage({super.key});

  @override
  ConsumerState<PassagePickerPage> createState() => _PassagePickerPageState();
}

class _PassagePickerPageState extends ConsumerState<PassagePickerPage> {
  int _step = 0;

  static const _titles = ['ספר', 'פרשה', 'עלייה'];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(parashaCatalogProvider);
    final selection = ref.watch(passageSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                tooltip: 'חזרה',
                onPressed: () => setState(() => _step -= 1),
                icon: const Icon(Icons.arrow_back),
              )
            : IconButton(
                tooltip: 'סגור',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
        title: Text(_titles[_step]),
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
        ],
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('לא ניתן לטעון פרשיות:\n$error')),
        data: (catalog) {
          final parasha = catalog.find(selection.parashaId) ??
              catalog.byId(PassageSelection.initial.parashaId);
          final parashot = catalog.forBook(parasha.bookOsis);

          Widget list;
          switch (_step) {
            case 0:
              list = ListView(
                children: [
                  for (final book in Books.chumash)
                    _PickerTile(
                      label: book.hebrewName,
                      selected: book.osis == parasha.bookOsis,
                      onTap: () async {
                        await ref
                            .read(passageSelectionProvider.notifier)
                            .setBook(book.osis, catalog);
                        setState(() => _step = 1);
                      },
                    ),
                ],
              );
            case 1:
              list = ListView(
                children: [
                  for (final item in parashot)
                    _PickerTile(
                      label: item.combined
                          ? '${item.hebrewName} (כפולה)'
                          : item.hebrewName,
                      selected: item.id == parasha.id,
                      onTap: () async {
                        await ref
                            .read(passageSelectionProvider.notifier)
                            .setParasha(item.id);
                        setState(() => _step = 2);
                      },
                    ),
                ],
              );
            default:
              list = ListView(
                children: [
                  for (final id in aliyahOrder)
                    if (parasha.aliyot.containsKey(id))
                      _PickerTile(
                        label: aliyahLabels[id]!,
                        selected: id == selection.aliyahId,
                        onTap: () async {
                          await ref
                              .read(passageSelectionProvider.notifier)
                              .setAliyah(id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                ],
              );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '${Books.byOsis(parasha.bookOsis).hebrewName} · ${parasha.hebrewName} · ${selection.aliyahLabel}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(child: list),
            ],
          );
        },
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      selected: selected,
      title: Text(label, style: const TextStyle(fontSize: 22)),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
