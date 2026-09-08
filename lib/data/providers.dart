import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/parashot.dart';
import 'db/app_database.dart';
import 'db/torah_repository.dart';
import 'import/text_importer.dart';
import 'models/torah_verse.dart';
import 'models/torah_word.dart';

final databaseProvider = Provider<AppDatabase>((_) => AppDatabase.instance);

final repositoryProvider = Provider<TorahRepository>(
  (ref) => TorahRepository(ref.watch(databaseProvider)),
);

final importerProvider = Provider<TextImporter>(
  (ref) => TextImporter(
    database: ref.watch(databaseProvider),
    repository: ref.watch(repositoryProvider),
  ),
);

final importProgressProvider = StateProvider<ImportProgress?>((_) => null);

final importReadyProvider = FutureProvider<void>((ref) async {
  if (kIsWeb) return;
  final importer = ref.watch(importerProvider);
  if (!await importer.needsImport()) return;
  await importer.importAll(
    onProgress: (progress) {
      ref.read(importProgressProvider.notifier).state = progress;
    },
  );
});

final parashaCatalogProvider = FutureProvider<ParashaCatalog>((ref) async {
  final raw = await rootBundle.loadString('assets/data/parashot.json');
  return ParashaCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

class PassageSelectionNotifier extends Notifier<PassageSelection> {
  static const _parashaKey = 'passage_parasha_id';
  static const _aliyahKey = 'passage_aliyah_id';

  @override
  PassageSelection build() {
    _load();
    return PassageSelection.initial;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final parashaId = prefs.getString(_parashaKey);
    final aliyahId = prefs.getString(_aliyahKey);
    if (parashaId == null && aliyahId == null) return;
    state = PassageSelection(
      parashaId: parashaId ?? PassageSelection.initial.parashaId,
      aliyahId: aliyahId ?? PassageSelection.initial.aliyahId,
    );
  }

  Future<void> setBook(String bookOsis, ParashaCatalog catalog) async {
    final first = catalog.forBook(bookOsis).first;
    state = PassageSelection(parashaId: first.id, aliyahId: '1');
    await _save();
  }

  Future<void> setParasha(String parashaId) async {
    state = PassageSelection(parashaId: parashaId, aliyahId: '1');
    await _save();
  }

  Future<void> setAliyah(String aliyahId) async {
    state = state.copyWith(aliyahId: aliyahId);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_parashaKey, state.parashaId);
    await prefs.setString(_aliyahKey, state.aliyahId);
  }
}

final passageSelectionProvider =
    NotifierProvider<PassageSelectionNotifier, PassageSelection>(
      PassageSelectionNotifier.new,
    );

final passageVersesProvider = FutureProvider<List<TorahVerse>>((ref) async {
  await ref.watch(importReadyProvider.future);
  final catalog = await ref.watch(parashaCatalogProvider.future);
  final selection = ref.watch(passageSelectionProvider);
  final parasha = catalog.find(selection.parashaId) ??
      catalog.byId(PassageSelection.initial.parashaId);
  final aliyah = parasha.aliyot[selection.aliyahId] ?? parasha.aliyot['1']!;
  return ref.watch(repositoryProvider).range(
        book: parasha.bookOsis,
        startChapter: aliyah.start.chapter,
        startVerse: aliyah.start.verse,
        endChapter: aliyah.end.chapter,
        endVerse: aliyah.end.verse,
      );
});

class TextVersionNotifier extends Notifier<TextVersion> {
  static const _prefsKey = 'text_version';

  @override
  TextVersion build() {
    _load();
    return TextVersion.full;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    final match = TextVersion.values.where((v) => v.name == raw);
    if (match.isNotEmpty) {
      state = match.first;
    }
  }

  Future<void> setVersion(TextVersion version) async {
    state = version;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, version.name);
  }
}

final textVersionProvider =
    NotifierProvider<TextVersionNotifier, TextVersion>(TextVersionNotifier.new);
