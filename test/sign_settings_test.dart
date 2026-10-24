import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torah_reader/core/hand_signs.dart';
import 'package:torah_reader/data/sign_settings.dart';
import 'package:torah_reader/features/settings/settings_screen.dart';

void main() {
  test('first run shows the starter set', () {
    expect(
      SignSettings.defaultShownIds,
      JerusalemHandSigns.starterSet.map((s) => s.id).toSet(),
    );
    expect(SignSettings.defaultShownIds.contains('etnachta'), isTrue);
    expect(SignSettings.defaultShownIds.contains('munach'), isFalse);
  });

  test('toggle adds and removes a taam from masmich', () {
    var settings = SignSettings(
      pack: SignPack.image,
      shownIds: SignSettings.defaultShownIds,
    );
    expect(settings.isShown('munach'), isFalse);
    settings = settings.toggleShown('munach');
    expect(settings.isShown('munach'), isTrue);
    settings = settings.toggleShown('munach');
    expect(settings.isShown('munach'), isFalse);
    settings = settings.toggleShown('etnachta');
    expect(settings.isShown('etnachta'), isFalse);
  });

  test('override replaces only that taam image', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final settings = SignSettings(
      pack: SignPack.image,
      shownIds: SignSettings.defaultShownIds,
    ).withOverride('zarqa', bytes);
    expect(settings.overrides['zarqa'], bytes);
    expect(settings.overrides['etnachta'], isNull);
  });

  test('defaults match first-run pack, starter taamim, no overrides', () {
    final settings = SignSettings.defaults;
    expect(settings.pack, SignPack.image);
    expect(settings.shownIds, SignSettings.defaultShownIds);
    expect(settings.overrides, isEmpty);
    expect(settings.isAtDefaults, isTrue);
  });

  test('changed settings are not at defaults', () {
    expect(
      SignSettings.defaults.copyWith(pack: SignPack.name).isAtDefaults,
      isFalse,
    );
    expect(
      SignSettings.defaults.toggleShown('munach').isAtDefaults,
      isFalse,
    );
    expect(
      SignSettings.defaults
          .withOverride('zarqa', Uint8List.fromList([1]))
          .isAtDefaults,
      isFalse,
    );
    expect(
      SignSettings.defaults.withColorMs('revia', 1500).isAtDefaults,
      isFalse,
    );
  });

  test('color time is stored per taam and catalog value clears it', () {
    final changed = SignSettings.defaults.withColorMs('revia', 1500);
    expect(changed.colorMs['revia'], 1500);
    expect(changed.colorMsOf(JerusalemHandSigns.byId('revia')!), 1500);
    expect(changed.colorMs.containsKey('etnachta'), isFalse);
    final cleared = changed.withColorMs('revia', 1100);
    expect(cleared.colorMs.containsKey('revia'), isFalse);
    expect(SignSettings.defaults.withColorMs('revia', 0).colorMs, isEmpty);
  });

  test('restoreDefaults clears persisted pack, shown set, and overrides',
      () async {
    SharedPreferences.setMockInitialValues({
      'sign_pack': 'name',
      'sign_shown_ids': jsonEncode(['munach']),
      'sign_override_ids': ['zarqa'],
      'sign_override_zarqa': base64Encode([1, 2, 3]),
      'sign_color_ms': jsonEncode({'revia': 1500}),
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(signSettingsProvider.notifier);
    for (var i = 0; i < 40; i++) {
      if (container.read(signSettingsProvider).pack == SignPack.name) break;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(container.read(signSettingsProvider).pack, SignPack.name);
    expect(container.read(signSettingsProvider).colorMs['revia'], 1500);

    await notifier.restoreDefaults();

    expect(container.read(signSettingsProvider).isAtDefaults, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sign_pack'), isNull);
    expect(prefs.getString('sign_shown_ids'), isNull);
    expect(prefs.getStringList('sign_override_ids'), isNull);
    expect(prefs.getString('sign_override_zarqa'), isNull);
    expect(prefs.getString('sign_color_ms'), isNull);
  });

  test('orderedSigns puts shown taamim first, catalog order inside groups', () {
    final settings = SignSettings.defaults.toggleShown('munach');
    final ids = settings.orderedSigns.map((s) => s.id).toList();
    expect(ids.first, 'sof_pasuq');
    expect(ids.contains('munach'), isTrue);
    final munachAt = ids.indexOf('munach');
    final etnachtaAt = ids.indexOf('etnachta');
    final tarhaAt = ids.indexOf('tarha');
    expect(etnachtaAt, lessThan(munachAt));
    expect(munachAt, lessThan(tarhaAt));
    expect(
      ids.where((id) => settings.isShown(id)).toList(),
      ids.take(settings.shownIds.length).toList(),
    );
  });

  testWidgets('saving a taam time updates the settings card', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('color-ms-sof_pasuq')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1500');
    await tester.tap(find.text('שמירה'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1500'), findsWidgets);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sign_color_ms'), contains('1500'));
  });
}
