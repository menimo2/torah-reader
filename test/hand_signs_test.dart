import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hand_signs.dart';
import 'package:torah_reader/core/taamim.dart';

void main() {
  test('every parsed taam has a Jerusalem sign', () {
    expect(JerusalemHandSigns.of(Taamim.sofPasuqName), isNotNull);
    for (final info in Taamim.byCode.values) {
      expect(
        JerusalemHandSigns.of(info.name),
        isNotNull,
        reason: 'missing sign for ${info.name}',
      );
    }
  });

  test('placeholder asset is shared until GIFs exist', () {
    for (final sign in JerusalemHandSigns.all) {
      expect(sign.asset, JerusalemHandSigns.defaultAsset);
    }
  });

  test('Sephardi display names for the common ones', () {
    expect(JerusalemHandSigns.of('טפחא')?.sephardiName, 'טרחא');
    expect(JerusalemHandSigns.of('מונח')?.sephardiName, 'שופר הולך');
    expect(JerusalemHandSigns.of('אתנחתא')?.sephardiName, 'אתנח');
    expect(JerusalemHandSigns.of('קדמא')?.sephardiName, 'אזלא');
  });
}
