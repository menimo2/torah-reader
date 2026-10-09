/// Unicode filters for the three Torah text versions.
///
/// Full text is stored once (nikud + taamim). Nikud-only and bare
/// (sefer Torah) are derived at runtime.
class HebrewText {
  HebrewText._();

  static const int _taamimStart = 0x0591;
  static const int _taamimEnd = 0x05AF;
  static const int _sofPasuq = 0x05C3;
  static const int _maqaf = 0x05BE;
  static const int _paseq = 0x05C0;
  static const int _slash = 0x002F;
  static const int _hyphen = 0x002D;
  static const int _narrowNbsp = 0x202F;

  static bool isTaam(int code) =>
      code >= _taamimStart && code <= _taamimEnd;

  static bool isNikud(int code) =>
      (code >= 0x05B0 && code <= 0x05BD) ||
      code == 0x05BF ||
      code == 0x05C1 ||
      code == 0x05C2 ||
      code == 0x05C4 ||
      code == 0x05C5 ||
      code == 0x05C7;

  static bool isSofPasuq(int code) => code == _sofPasuq;

  static bool isMaqaf(int code) => code == _maqaf;

  /// Strip WLC lemma slashes (`בְּ/רֵאשִׁית` → `בְּרֵאשִׁית`).
  static String stripSlash(String text) =>
      String.fromCharCodes(text.runes.where((c) => c != _slash));

  /// Full pointed text. WLC zinor (U+05AE) stays as-is; SBL Hebrew places it.
  static String displayFull(String fullText) => fullText;

  /// Nikud without taamim. Maqaf becomes a plain hyphen.
  static String nikudOnly(String fullText) {
    final out = <int>[];
    for (final c in fullText.runes) {
      if (isTaam(c) ||
          isSofPasuq(c) ||
          c == _paseq ||
          c == _slash ||
          c == _narrowNbsp) {
        continue;
      }
      if (isMaqaf(c)) {
        out.add(_hyphen);
        continue;
      }
      out.add(c);
    }
    return String.fromCharCodes(out);
  }

  /// Letters only — like a sefer Torah. No nikud, taamim, sof pasuq, maqaf, slash.
  static String bare(String fullText) {
    final out = <int>[];
    for (final c in fullText.runes) {
      if (isTaam(c) ||
          isNikud(c) ||
          isSofPasuq(c) ||
          isMaqaf(c) ||
          c == _paseq ||
          c == _slash ||
          c == _hyphen ||
          c == _narrowNbsp) {
        continue;
      }
      out.add(c);
    }
    return String.fromCharCodes(out);
  }

  static List<int> taamCodePoints(String fullText) =>
      fullText.runes.where(isTaam).toList();
}
