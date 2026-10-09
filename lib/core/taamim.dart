import 'hebrew_text.dart';

/// Cantillation names for the 21-book system (not איוב, משלי, תהלים).
///
/// Time bonuses are placeholders until we tune them against Jerusalem chant.
class TaamInfo {
  const TaamInfo({
    required this.name,
    required this.disjunctive,
    required this.timeBonus,
    required this.priority,
  });

  final String name;
  final bool disjunctive;
  final double timeBonus;
  final int priority;
}

class Taamim {
  Taamim._();

  static const String sofPasuqName = 'סוף פסוק';
  static const String paseqName = 'פסק';

  static const TaamInfo sofPasuq = TaamInfo(
    name: sofPasuqName,
    disjunctive: true,
    timeBonus: 0.80,
    priority: 100,
  );

  /// Vertical bar after a word (WLC `x-paseq`). Not a combining taam.
  static const TaamInfo paseq = TaamInfo(
    name: paseqName,
    disjunctive: true,
    timeBonus: 0.25,
    priority: 85,
  );

  /// Unicode U+0591–U+05AF → taam.
  static const Map<int, TaamInfo> byCode = {
    0x0591: TaamInfo(name: 'אתנחתא', disjunctive: true, timeBonus: 0.55, priority: 90),
    0x0592: TaamInfo(name: 'סגולתא', disjunctive: true, timeBonus: 0.35, priority: 70),
    0x0593: TaamInfo(name: 'שלשלת', disjunctive: true, timeBonus: 0.45, priority: 75),
    0x0594: TaamInfo(name: 'זקף קטן', disjunctive: true, timeBonus: 0.35, priority: 80),
    0x0595: TaamInfo(name: 'זקף גדול', disjunctive: true, timeBonus: 0.40, priority: 82),
    0x0596: TaamInfo(name: 'טפחא', disjunctive: true, timeBonus: 0.20, priority: 60),
    0x0597: TaamInfo(name: 'רביע', disjunctive: true, timeBonus: 0.30, priority: 65),
    0x0598: TaamInfo(name: 'זרקא', disjunctive: true, timeBonus: 0.18, priority: 55),
    0x0599: TaamInfo(name: 'פשטא', disjunctive: true, timeBonus: 0.15, priority: 50),
    0x059A: TaamInfo(name: 'יתיב', disjunctive: true, timeBonus: 0.15, priority: 50),
    0x059B: TaamInfo(name: 'תביר', disjunctive: false, timeBonus: 0.08, priority: 20),
    0x059C: TaamInfo(name: 'גרש', disjunctive: true, timeBonus: 0.18, priority: 45),
    0x059D: TaamInfo(name: 'גרש מוקדם', disjunctive: true, timeBonus: 0.18, priority: 44),
    0x059E: TaamInfo(name: 'גרשים', disjunctive: true, timeBonus: 0.20, priority: 46),
    0x059F: TaamInfo(name: 'קרני פרה', disjunctive: true, timeBonus: 0.40, priority: 72),
    0x05A0: TaamInfo(name: 'תלישא גדולה', disjunctive: true, timeBonus: 0.22, priority: 48),
    0x05A1: TaamInfo(name: 'פזר', disjunctive: true, timeBonus: 0.25, priority: 52),
    0x05A3: TaamInfo(name: 'מונח', disjunctive: false, timeBonus: 0.0, priority: 10),
    0x05A4: TaamInfo(name: 'מהפך', disjunctive: false, timeBonus: 0.0, priority: 10),
    0x05A5: TaamInfo(name: 'מרכא', disjunctive: false, timeBonus: 0.0, priority: 10),
    0x05A6: TaamInfo(name: 'מרכא כפולה', disjunctive: false, timeBonus: 0.05, priority: 12),
    0x05A7: TaamInfo(name: 'דרגא', disjunctive: false, timeBonus: 0.0, priority: 10),
    0x05A8: TaamInfo(name: 'קדמא', disjunctive: false, timeBonus: 0.0, priority: 10),
    0x05A9: TaamInfo(name: 'תלישא קטנה', disjunctive: true, timeBonus: 0.12, priority: 40),
    0x05AA: TaamInfo(name: 'ירח בן יומו', disjunctive: true, timeBonus: 0.35, priority: 68),
    // WLC 21-book zarqa is encoded as zinor, not U+0598.
    0x05AE: TaamInfo(name: 'זרקא', disjunctive: true, timeBonus: 0.18, priority: 55),
  };

  static TaamInfo? primaryOf(
    String fullText, {
    bool endsVerse = false,
    bool hasPaseq = false,
  }) {
    TaamInfo? best;
    for (final code in HebrewText.taamCodePoints(fullText)) {
      final info = byCode[code];
      if (info == null) continue;
      if (best == null || info.priority > best.priority) {
        best = info;
      }
    }
    final paseqHere = hasPaseq || fullText.contains('\u05C0');
    if (paseqHere) {
      if (best == null || best.priority < paseq.priority) {
        best = paseq;
      }
    }
    if (endsVerse) {
      if (best == null || best.priority < sofPasuq.priority) {
        return sofPasuq;
      }
    }
    return best;
  }
}
