import 'taamim.dart';

const kJerusalemDefaultHandAsset = 'assets/signs/jerusalem/default.png';

/// Pack 3 file for this taam: still photo (`etnachta.png`) or motion (`zarqa.gif`).
String jerusalemSignAsset(String id, {bool gif = false}) =>
    'assets/signs/jerusalem/$id.${gif ? 'gif' : 'png'}';

/// Which of the three masmich packs is showing.
/// Chosen in Settings, not in the masmich window.
enum SignPack {
  /// א + cantillation mark (Ezra SIL).
  alephTaam,

  /// Sephardi name only.
  name,

  /// Photo / GIF. Placeholder hand until filmed.
  image,
}

/// One taam: how it looks in all three packs, and how long its word stays colored.
class HandSign {
  const HandSign({
    required this.id,
    required this.taamName,
    required this.sephardiName,
    required this.conjunctive,
    required this.alephMark,
    required this.colorMs,
    this.imageAsset = kJerusalemDefaultHandAsset,
    this.shownByDefault = false,
  });

  /// Latin filename stem (`etnachta.png` / `etnachta.gif`).
  final String id;

  /// Matches [TaamInfo.name] / `TorahWord.taamName`.
  final String taamName;

  /// Pack 2 — Sephardi name.
  final String sephardiName;

  /// Pack 1 — letter א with this taam (Ezra SIL).
  final String alephMark;

  /// Pack 3 — PNG still or GIF. Until the real file is in
  /// `assets/signs/jerusalem/{id}.png` / `.gif`, this is the placeholder hand.
  final String imageAsset;

  /// How long this word stays colored, in milliseconds.
  /// Speed from Settings will scale this later. Not chosen in the masmich window.
  final int colorMs;

  final bool conjunctive;

  /// Masmich shows this sign on first run. Settings will toggle per taam later.
  final bool shownByDefault;

  String get asset => imageAsset;

  String appearance(SignPack pack) {
    switch (pack) {
      case SignPack.alephTaam:
        return alephMark;
      case SignPack.name:
        return sephardiName;
      case SignPack.image:
        return imageAsset;
    }
  }
}

class JerusalemHandSigns {
  JerusalemHandSigns._();

  static const packId = 'jerusalem';
  static const packName = 'ירושלמי';
  static const tradition = 'sephardi';
  static const defaultAsset = kJerusalemDefaultHandAsset;

  /// Word with no parsed taam. Draft — same ballpark as a conjunctive.
  static const noTaamColorMs = 580;

  static const List<HandSign> all = [
    HandSign(
      id: 'sof_pasuq',
      taamName: Taamim.sofPasuqName,
      sephardiName: 'סוף פסוק',
      alephMark: '\u05D0\u05C3', // א׃
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'paseq',
      taamName: Taamim.paseqName,
      sephardiName: 'פסק',
      alephMark: '\u05D0\u05C0', // א׀
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'etnachta',
      taamName: 'אתנחתא',
      sephardiName: 'אתנח',
      alephMark: '\u05D0\u0591', // א֑
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/etnachta.png',
    ),
    HandSign(
      id: 'segolta',
      taamName: 'סגולתא',
      sephardiName: 'סגול',
      alephMark: '\u05D0\u0592', // א֒
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/segolta.png',
    ),
    HandSign(
      id: 'shalshelet',
      taamName: 'שלשלת',
      sephardiName: 'שלשלת',
      alephMark: '\u05D0\u0593', // א֓
      colorMs: 900,
      conjunctive: false,
    ),
    HandSign(
      id: 'zaqef_qatan',
      taamName: 'זקף קטן',
      sephardiName: 'זקף קטן',
      alephMark: '\u05D0\u0594', // א֔
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'zaqef_gadol',
      taamName: 'זקף גדול',
      sephardiName: 'זקף גדול',
      alephMark: '\u05D0\u0595', // א֕
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/zaqef_gadol.png',
    ),
    HandSign(
      id: 'tarha',
      taamName: 'טפחא',
      sephardiName: 'טרחא',
      alephMark: '\u05D0\u0596', // א֖
      colorMs: 680,
      conjunctive: false,
    ),
    HandSign(
      id: 'revia',
      taamName: 'רביע',
      sephardiName: 'רביע',
      alephMark: '\u05D0\u0597', // א֗
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/revia.png',
    ),
    HandSign(
      id: 'zarqa',
      taamName: 'זרקא',
      sephardiName: 'זרקא',
      alephMark: '\u05D0\u0598', // א֘
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/zarqa.gif',
    ),
    HandSign(
      id: 'pashta',
      taamName: 'פשטא',
      sephardiName: 'פשטא',
      alephMark: '\u05D0\u0599', // א֙
      colorMs: 650,
      conjunctive: false,
    ),
    HandSign(
      id: 'yetiv',
      taamName: 'יתיב',
      sephardiName: 'יתיב',
      alephMark: '\u059A\u05D0', // ֚א — mark before the letter
      colorMs: 650,
      conjunctive: false,
    ),
    HandSign(
      id: 'tevir',
      taamName: 'תביר',
      sephardiName: 'תביר',
      alephMark: '\u05D0\u059B', // א֛
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/tevir.gif',
    ),
    HandSign(
      id: 'geresh',
      taamName: 'גרש',
      sephardiName: 'אזלא גרש',
      alephMark: '\u05D0\u059C', // א֜
      imageAsset: 'assets/signs/jerusalem/geresh.gif',
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'geresh_muqdam',
      taamName: 'גרש מוקדם',
      sephardiName: 'אזלא גרש',
      alephMark: '\u05D0\u059D', // א֝
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/geresh.gif',
    ),
    HandSign(
      id: 'gershayim',
      taamName: 'גרשים',
      sephardiName: 'שני גרשין',
      alephMark: '\u05D0\u059E', // א֞
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/gershayim.png',
    ),
    HandSign(
      id: 'qarnei_parah',
      taamName: 'קרני פרה',
      sephardiName: 'קרני פרה',
      alephMark: '\u05D0\u059F', // א֟
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'telisha_gedola',
      taamName: 'תלישא גדולה',
      sephardiName: 'תלשא',
      alephMark: '\u05A0\u05D0', // ֠א — mark at the start
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'pazer',
      taamName: 'פזר',
      sephardiName: 'פזר',
      alephMark: '\u05D0\u05A1', // א֡
      colorMs: 1100,
      conjunctive: false,
      shownByDefault: true,
    ),
    HandSign(
      id: 'munach',
      taamName: 'מונח',
      sephardiName: 'שופר הולך',
      alephMark: '\u05D0\u05A3', // א֣
      colorMs: 580,
      conjunctive: true,
    ),
    HandSign(
      id: 'mahpach',
      taamName: 'מהפך',
      sephardiName: 'שופר מהופך',
      alephMark: '\u05D0\u05A4', // א֤
      colorMs: 580,
      conjunctive: true,
    ),
    HandSign(
      id: 'mercha',
      taamName: 'מרכא',
      sephardiName: 'מאריך',
      alephMark: '\u05D0\u05A5', // א֥
      colorMs: 580,
      conjunctive: true,
    ),
    HandSign(
      id: 'mercha_kefulah',
      taamName: 'מרכא כפולה',
      sephardiName: 'תרי טעמי',
      alephMark: '\u05D0\u05A6', // א֦
      colorMs: 620,
      conjunctive: true,
    ),
    HandSign(
      id: 'darga',
      taamName: 'דרגא',
      sephardiName: 'דרגא',
      alephMark: '\u05D0\u05A7', // א֧
      colorMs: 1100,
      conjunctive: true,
      shownByDefault: true,
    ),
    HandSign(
      id: 'azla',
      taamName: 'קדמא',
      sephardiName: 'אזלא',
      alephMark: '\u05D0\u05A8', // א֨
      colorMs: 1100,
      conjunctive: true,
      shownByDefault: true,
      imageAsset: 'assets/signs/jerusalem/azla.gif',
    ),
    HandSign(
      id: 'telisha_qetana',
      taamName: 'תלישא קטנה',
      sephardiName: 'תילשא',
      alephMark: '\u05D0\u05A9', // א֩
      colorMs: 1100,
      conjunctive: true,
      shownByDefault: true,
    ),
    HandSign(
      id: 'yerach_ben_yomo',
      taamName: 'ירח בן יומו',
      sephardiName: 'ירח בן יומו',
      alephMark: '\u05D0\u05AA', // א֪
      colorMs: 800,
      conjunctive: true,
    ),
  ];

  static final Map<String, HandSign> byTaamName = {
    for (final sign in all) sign.taamName: sign,
  };

  static HandSign? of(String? taamName) =>
      taamName == null ? null : byTaamName[taamName];

  /// Sign to draw in masmich. Hidden taamim still color the word.
  /// [enabledIds] comes from Settings; omit to use [shownByDefault].
  static HandSign? shownOf(String? taamName, {Set<String>? enabledIds}) {
    final sign = of(taamName);
    if (sign == null) return null;
    final on = enabledIds ?? {
      for (final item in all)
        if (item.shownByDefault) item.id,
    };
    if (!on.contains(sign.id)) return null;
    return sign;
  }

  static Iterable<HandSign> get starterSet =>
      all.where((sign) => sign.shownByDefault);

  static String assetFor(String? taamName) =>
      of(taamName)?.imageAsset ?? defaultAsset;

  static int colorMsFor(String? taamName) =>
      of(taamName)?.colorMs ?? noTaamColorMs;
}
