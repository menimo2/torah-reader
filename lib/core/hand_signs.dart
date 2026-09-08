import 'taamim.dart';

/// First sign pack: Sephardi names, Jerusalem (ירושלמי) hand style.
///
/// Every taam currently points at [defaultAsset] until filmed GIFs replace it.
class HandSign {
  const HandSign({
    required this.id,
    required this.taamName,
    required this.sephardiName,
    required this.conjunctive,
  });

  /// Latin filename stem for the future GIF (`etnachta.gif`).
  final String id;

  /// Matches [TaamInfo.name] / `TorahWord.taamName`.
  final String taamName;

  /// Name used in the Jerusalem/Sephardi pack.
  final String sephardiName;

  final bool conjunctive;

  String get asset => JerusalemHandSigns.assetFor(taamName);
}

class JerusalemHandSigns {
  JerusalemHandSigns._();

  static const packId = 'jerusalem';
  static const packName = 'ירושלמי';
  static const tradition = 'sephardi';
  static const defaultAsset = 'assets/signs/jerusalem/default.png';

  static const List<HandSign> all = [
    HandSign(
      id: 'sof_pasuq',
      taamName: Taamim.sofPasuqName,
      sephardiName: 'סוף פסוק',
      conjunctive: false,
    ),
    HandSign(
      id: 'etnachta',
      taamName: 'אתנחתא',
      sephardiName: 'אתנח',
      conjunctive: false,
    ),
    HandSign(
      id: 'segolta',
      taamName: 'סגולתא',
      sephardiName: 'סגול',
      conjunctive: false,
    ),
    HandSign(
      id: 'shalshelet',
      taamName: 'שלשלת',
      sephardiName: 'שלשלת',
      conjunctive: false,
    ),
    HandSign(
      id: 'zaqef_qatan',
      taamName: 'זקף קטן',
      sephardiName: 'זקף קטן',
      conjunctive: false,
    ),
    HandSign(
      id: 'zaqef_gadol',
      taamName: 'זקף גדול',
      sephardiName: 'זקף גדול',
      conjunctive: false,
    ),
    HandSign(
      id: 'tarha',
      taamName: 'טפחא',
      sephardiName: 'טרחא',
      conjunctive: false,
    ),
    HandSign(
      id: 'revia',
      taamName: 'רביע',
      sephardiName: 'רביע',
      conjunctive: false,
    ),
    HandSign(
      id: 'zarqa',
      taamName: 'זרקא',
      sephardiName: 'זרקא',
      conjunctive: false,
    ),
    HandSign(
      id: 'pashta',
      taamName: 'פשטא',
      sephardiName: 'פשטא',
      conjunctive: false,
    ),
    HandSign(
      id: 'yetiv',
      taamName: 'יתיב',
      sephardiName: 'יתיב',
      conjunctive: false,
    ),
    HandSign(
      id: 'tevir',
      taamName: 'תביר',
      sephardiName: 'תביר',
      conjunctive: false,
    ),
    HandSign(
      id: 'geresh',
      taamName: 'גרש',
      sephardiName: 'אזלא גרש',
      conjunctive: false,
    ),
    HandSign(
      id: 'geresh_muqdam',
      taamName: 'גרש מוקדם',
      sephardiName: 'אזלא גרש',
      conjunctive: false,
    ),
    HandSign(
      id: 'gershayim',
      taamName: 'גרשים',
      sephardiName: 'שני גרשין',
      conjunctive: false,
    ),
    HandSign(
      id: 'qarnei_parah',
      taamName: 'קרני פרה',
      sephardiName: 'קרני פרה',
      conjunctive: false,
    ),
    HandSign(
      id: 'telisha_gedola',
      taamName: 'תלישא גדולה',
      sephardiName: 'תלשא',
      conjunctive: false,
    ),
    HandSign(
      id: 'pazer',
      taamName: 'פזר',
      sephardiName: 'פזר',
      conjunctive: false,
    ),
    HandSign(
      id: 'munach',
      taamName: 'מונח',
      sephardiName: 'שופר הולך',
      conjunctive: true,
    ),
    HandSign(
      id: 'mahpach',
      taamName: 'מהפך',
      sephardiName: 'שופר מהופך',
      conjunctive: true,
    ),
    HandSign(
      id: 'mercha',
      taamName: 'מרכא',
      sephardiName: 'מאריך',
      conjunctive: true,
    ),
    HandSign(
      id: 'mercha_kefulah',
      taamName: 'מרכא כפולה',
      sephardiName: 'תרי טעמי',
      conjunctive: true,
    ),
    HandSign(
      id: 'darga',
      taamName: 'דרגא',
      sephardiName: 'דרגא',
      conjunctive: true,
    ),
    HandSign(
      id: 'azla',
      taamName: 'קדמא',
      sephardiName: 'אזלא',
      conjunctive: true,
    ),
    HandSign(
      id: 'telisha_qetana',
      taamName: 'תלישא קטנה',
      sephardiName: 'תילשא',
      conjunctive: true,
    ),
    HandSign(
      id: 'yerach_ben_yomo',
      taamName: 'ירח בן יומו',
      sephardiName: 'ירח בן יומו',
      conjunctive: true,
    ),
  ];

  static final Map<String, HandSign> byTaamName = {
    for (final sign in all) sign.taamName: sign,
  };

  static HandSign? of(String? taamName) =>
      taamName == null ? null : byTaamName[taamName];

  /// Shared placeholder until each `id` has its own GIF.
  static String assetFor(String? taamName) => defaultAsset;
}
