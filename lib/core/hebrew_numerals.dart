/// Hebrew numerals as in a printed chumash (א, ב, … יג, טו, טז).
String hebrewNumeral(int n) {
  if (n <= 0) return '$n';

  const ones = ['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
  const tens = ['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
  const hundreds = ['', 'ק', 'ר', 'ש', 'ת'];

  final buf = StringBuffer();
  var remaining = n;

  final hundred = remaining ~/ 100;
  remaining %= 100;
  if (hundred > 0 && hundred < hundreds.length) {
    buf.write(hundreds[hundred]);
  }

  if (remaining == 15) {
    buf.write('טו');
    return buf.toString();
  }
  if (remaining == 16) {
    buf.write('טז');
    return buf.toString();
  }

  buf.write(tens[remaining ~/ 10]);
  buf.write(ones[remaining % 10]);
  return buf.toString();
}

String hebrewChapterVerse(int chapter, int verse) =>
    '${hebrewNumeral(chapter)}:${hebrewNumeral(verse)}';
