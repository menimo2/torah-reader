import '../../core/hebrew_text.dart';
import '../../core/taamim.dart';

class TorahWord {
  const TorahWord({
    required this.fullText,
    required this.wordIndex,
    this.taamName,
    this.hasTaam = false,
    this.taamTimeBonus = 0,
  });

  final String fullText;
  final int wordIndex;
  final String? taamName;
  final bool hasTaam;
  final double taamTimeBonus;

  String get nikudOnly => HebrewText.nikudOnly(fullText);
  String get bare => HebrewText.bare(fullText);

  String display(TextVersion version) {
    switch (version) {
      case TextVersion.full:
        return fullText;
      case TextVersion.nikud:
        return nikudOnly;
      case TextVersion.bare:
        return bare;
    }
  }

  factory TorahWord.fromDb(Map<String, Object?> row) {
    return TorahWord(
      fullText: row['full_text'] as String,
      wordIndex: row['word_index'] as int,
      taamName: row['taam_name'] as String?,
      hasTaam: (row['has_taam'] as int) == 1,
      taamTimeBonus: (row['taam_time_bonus'] as num).toDouble(),
    );
  }

  factory TorahWord.fromParsed({
    required String fullText,
    required int wordIndex,
    bool endsVerse = false,
  }) {
    final taam = Taamim.primaryOf(fullText, endsVerse: endsVerse);
    return TorahWord(
      fullText: fullText,
      wordIndex: wordIndex,
      taamName: taam?.name,
      hasTaam: taam != null,
      taamTimeBonus: taam?.timeBonus ?? 0,
    );
  }
}

enum TextVersion { full, nikud, bare }
