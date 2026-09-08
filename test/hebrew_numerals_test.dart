import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hebrew_numerals.dart';

void main() {
  test('maps like a chumash', () {
    expect(hebrewNumeral(1), 'א');
    expect(hebrewNumeral(2), 'ב');
    expect(hebrewNumeral(10), 'י');
    expect(hebrewNumeral(11), 'יא');
    expect(hebrewNumeral(13), 'יג');
    expect(hebrewNumeral(15), 'טו');
    expect(hebrewNumeral(16), 'טז');
    expect(hebrewNumeral(20), 'כ');
    expect(hebrewNumeral(21), 'כא');
    expect(hebrewChapterVerse(1, 1), 'א:א');
  });
}
