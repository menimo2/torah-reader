import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hand_signs.dart';
import 'package:torah_reader/core/taamim.dart';

void main() {
  test('every parsed taam has a Jerusalem sign', () {
    expect(JerusalemHandSigns.of(Taamim.sofPasuqName), isNotNull);
    expect(JerusalemHandSigns.of(Taamim.paseqName), isNotNull);
    for (final info in Taamim.byCode.values) {
      expect(
        JerusalemHandSigns.of(info.name),
        isNotNull,
        reason: 'missing sign for ${info.name}',
      );
    }
  });

  test('each taam has all three appearances and a color duration', () {
    for (final sign in JerusalemHandSigns.all) {
      expect(sign.alephMark, isNotEmpty);
      expect(sign.sephardiName, isNotEmpty);
      expect(
        sign.imageAsset,
        switch (sign.id) {
          'etnachta' => 'assets/signs/jerusalem/etnachta.png',
          'zaqef_gadol' => 'assets/signs/jerusalem/zaqef_gadol.png',
          'revia' => 'assets/signs/jerusalem/revia.png',
          'zarqa' => 'assets/signs/jerusalem/zarqa.gif',
          'geresh' => 'assets/signs/jerusalem/geresh.gif',
          'geresh_muqdam' => 'assets/signs/jerusalem/geresh.gif',
          'azla' => 'assets/signs/jerusalem/azla.gif',
          'trei_kadma' => 'assets/signs/jerusalem/trei_kadma.png',
          'segolta' => 'assets/signs/jerusalem/segolta.png',
          'tevir' => 'assets/signs/jerusalem/tevir.gif',
          'gershayim' => 'assets/signs/jerusalem/gershayim.png',
          'pazer' => 'assets/signs/jerusalem/pazer.png',
          'zaqef_qatan' => 'assets/signs/jerusalem/zaqef_qatan.png',
          'paseq' => 'assets/signs/jerusalem/paseq.png',
          'telisha_gedola' => 'assets/signs/jerusalem/telisha_gedola.gif',
          'darga' => 'assets/signs/jerusalem/darga.gif',
          _ => JerusalemHandSigns.defaultAsset,
        },
      );
      expect(sign.colorMs, greaterThan(0));
      expect(sign.appearance(SignPack.alephTaam), sign.alephMark);
      expect(sign.appearance(SignPack.name), sign.sephardiName);
      expect(sign.appearance(SignPack.image), sign.imageAsset);
    }
  });

  test('starter signs color for 1100ms', () {
    for (final sign in JerusalemHandSigns.starterSet) {
      expect(sign.colorMs, 1100, reason: sign.id);
    }
    expect(JerusalemHandSigns.of('מונח')?.colorMs, 580);
    expect(JerusalemHandSigns.of('טפחא')?.colorMs, 680);
  });

  test('Sephardi display names for the common ones', () {
    expect(JerusalemHandSigns.of('טפחא')?.sephardiName, 'טרחא');
    expect(JerusalemHandSigns.of('מונח')?.sephardiName, 'שופר הולך');
    expect(JerusalemHandSigns.of('אתנחתא')?.sephardiName, 'אתנח');
    expect(JerusalemHandSigns.of('קדמא')?.sephardiName, 'אזלא');
    expect(JerusalemHandSigns.of('תרי קדמין')?.sephardiName, 'תרי קדמין');
    expect(JerusalemHandSigns.of('תרי קדמין')?.id, 'trei_kadma');
    expect(JerusalemHandSigns.of('סוף פסוק')?.alephMark, 'א׃');
  });

  test('starter set is the user list of signs to show', () {
    const on = {
      'sof_pasuq',
      'paseq',
      'etnachta',
      'segolta',
      'zaqef_qatan',
      'zaqef_gadol',
      'revia',
      'zarqa',
      'tevir',
      'geresh',
      'geresh_muqdam',
      'gershayim',
      'qarnei_parah',
      'telisha_gedola',
      'pazer',
      'darga',
      'azla',
      'trei_kadma',
      'telisha_qetana',
    };
    expect(
      JerusalemHandSigns.starterSet.map((s) => s.id).toSet(),
      on,
    );
    expect(JerusalemHandSigns.shownOf('אתנחתא'), isNotNull);
    expect(JerusalemHandSigns.shownOf('גרשים'), isNotNull);
    expect(JerusalemHandSigns.shownOf('פסק'), isNotNull);
    expect(JerusalemHandSigns.shownOf('קדמא'), isNotNull);
    expect(JerusalemHandSigns.shownOf('תרי קדמין'), isNotNull);
    expect(JerusalemHandSigns.shownOf('טפחא'), isNull);
    expect(JerusalemHandSigns.shownOf('פשטא'), isNull);
    expect(JerusalemHandSigns.shownOf('מונח'), isNull);
    expect(
      JerusalemHandSigns.shownOf('מונח', enabledIds: {'munach'}),
      isNotNull,
    );
    expect(
      JerusalemHandSigns.shownOf('אתנחתא', enabledIds: {}),
      isNull,
    );
  });
}
