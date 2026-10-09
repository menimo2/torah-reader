import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/hand_signs.dart';

class SignSettings {
  const SignSettings({
    required this.pack,
    required this.shownIds,
    this.overrides = const {},
  });

  final SignPack pack;
  final Set<String> shownIds;
  final Map<String, Uint8List> overrides;

  static Set<String> get defaultShownIds => {
        for (final sign in JerusalemHandSigns.starterSet) sign.id,
      };

  static SignSettings get defaults => SignSettings(
        pack: SignPack.image,
        shownIds: defaultShownIds,
      );

  bool isShown(String id) => shownIds.contains(id);

  bool get isAtDefaults =>
      pack == SignPack.image &&
      overrides.isEmpty &&
      shownIds.length == defaultShownIds.length &&
      shownIds.containsAll(defaultShownIds);

  SignSettings copyWith({
    SignPack? pack,
    Set<String>? shownIds,
    Map<String, Uint8List>? overrides,
  }) {
    return SignSettings(
      pack: pack ?? this.pack,
      shownIds: shownIds ?? this.shownIds,
      overrides: overrides ?? this.overrides,
    );
  }

  SignSettings toggleShown(String id) {
    final next = {...shownIds};
    if (!next.add(id)) next.remove(id);
    return copyWith(shownIds: next);
  }

  SignSettings withOverride(String id, Uint8List bytes) {
    return copyWith(overrides: {...overrides, id: bytes});
  }

  /// Shown taamim first, catalog order inside each group.
  List<HandSign> get orderedSigns {
    final on = <HandSign>[];
    final off = <HandSign>[];
    for (final sign in JerusalemHandSigns.all) {
      if (shownIds.contains(sign.id)) {
        on.add(sign);
      } else {
        off.add(sign);
      }
    }
    return [...on, ...off];
  }
}

class SignSettingsNotifier extends Notifier<SignSettings> {
  static const _packKey = 'sign_pack';
  static const _shownKey = 'sign_shown_ids';
  static const _overrideIdsKey = 'sign_override_ids';
  static String _overrideKey(String id) => 'sign_override_$id';

  @override
  SignSettings build() {
    _load();
    return SignSettings.defaults;
  }

  var hydrated = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var pack = SignPack.image;
    final packRaw = prefs.getString(_packKey);
    if (packRaw != null) {
      final match = SignPack.values.where((p) => p.name == packRaw);
      if (match.isNotEmpty) pack = match.first;
    }

    var shown = SignSettings.defaultShownIds;
    final shownRaw = prefs.getString(_shownKey);
    if (shownRaw != null) {
      final decoded = jsonDecode(shownRaw);
      if (decoded is List) {
        shown = {
          for (final item in decoded)
            if (item is String) item,
        };
      }
    }

    final overrides = <String, Uint8List>{};
    final overrideIds = prefs.getStringList(_overrideIdsKey) ?? const [];
    for (final id in overrideIds) {
      final b64 = prefs.getString(_overrideKey(id));
      if (b64 == null) continue;
      try {
        overrides[id] = Uint8List.fromList(base64Decode(b64));
      } catch (_) {}
    }

    hydrated = true;
    state = SignSettings(pack: pack, shownIds: shown, overrides: overrides);
  }

  Future<void> setPack(SignPack pack) async {
    state = state.copyWith(pack: pack);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_packKey, pack.name);
  }

  Future<void> toggleShown(String id) async {
    state = state.toggleShown(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shownKey, jsonEncode(state.shownIds.toList()));
  }

  Future<void> setOverride(String id, Uint8List bytes) async {
    state = state.withOverride(id, bytes);
    final prefs = await SharedPreferences.getInstance();
    final ids = state.overrides.keys.toList();
    await prefs.setStringList(_overrideIdsKey, ids);
    await prefs.setString(_overrideKey(id), base64Encode(bytes));
  }

  Future<void> restoreDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final overrideIds = {
      ...state.overrides.keys,
      ...?prefs.getStringList(_overrideIdsKey),
    };
    for (final id in overrideIds) {
      await prefs.remove(_overrideKey(id));
    }
    await prefs.remove(_packKey);
    await prefs.remove(_shownKey);
    await prefs.remove(_overrideIdsKey);
    state = SignSettings.defaults;
  }
}

final signSettingsProvider =
    NotifierProvider<SignSettingsNotifier, SignSettings>(
      SignSettingsNotifier.new,
    );
