import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hebrew_text.dart';
import 'package:torah_reader/core/taamim.dart';

void main() {
  const bereshit = 'בְּרֵאשִׁ֖ית';
  const bara = 'בָּרָ֣א';
  const elohim = 'אֱלֹהִ֑ים';
  const withSlash = 'בְּ/רֵאשִׁ֖ית';

  test('strips WLC lemma slash', () {
    expect(HebrewText.stripSlash(withSlash), 'בְּרֵאשִׁ֖ית');
  });

  test('nikud-only drops taamim and keeps nikud', () {
    expect(HebrewText.nikudOnly(bereshit), 'בְּרֵאשִׁית');
    expect(HebrewText.nikudOnly(elohim), 'אֱלֹהִים');
  });

  test('bare looks like a sefer Torah', () {
    expect(HebrewText.bare(bereshit), 'בראשית');
    expect(HebrewText.bare(elohim), 'אלהים');
    expect(HebrewText.bare('הָאָֽרֶץ׃'), 'הארץ');
    expect(HebrewText.bare('עַל־פְּנֵי'), 'עלפני');
  });

  test('maqaf becomes hyphen in nikud version', () {
    expect(HebrewText.nikudOnly('עַל־פְּנֵי'), 'עַל-פְּנֵי');
  });

  test('primary taam from unicode', () {
    expect(Taamim.primaryOf(bereshit)?.name, 'טפחא');
    expect(Taamim.primaryOf(bara)?.name, 'מונח');
    expect(Taamim.primaryOf(elohim)?.name, 'אתנחתא');
    expect(Taamim.primaryOf('הָאָֽרֶץ', endsVerse: true)?.name, 'סוף פסוק');
  });
}
