import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/hebrew_text.dart';
import 'package:torah_reader/data/xml/morphhb_parser.dart';

const _gen1 = '''
<?xml version="1.0" encoding="UTF-8"?>
<osis xmlns="http://www.bibletechnologies.net/2003/OSIS/namespace">
  <osisText xml:lang="he">
    <div type="book" osisID="Gen">
      <chapter osisID="Gen.1">
        <verse osisID="Gen.1.1">
          <w lemma="b/7225">בְּ/רֵאשִׁ֖ית</w>
          <w lemma="1254">בָּרָ֣א</w>
          <w lemma="430">אֱלֹהִ֑ים</w>
          <w lemma="853">אֵ֥ת</w>
          <w lemma="d/8064">הַ/שָּׁמַ֖יִם</w>
          <w lemma="c/853">וְ/אֵ֥ת</w>
          <w lemma="d/776">הָ/אָֽרֶץ</w><seg type="x-sof-pasuq">׃</seg>
        </verse>
        <verse osisID="Gen.1.2">
          <w>עַל</w><seg type="x-maqqef">־</seg><w>פְּנֵ֣י</w>
        </verse>
      </chapter>
    </div>
  </osisText>
</osis>
''';

void main() {
  const parser = MorphhbParser();

  test('parses Gen 1:1 words without slashes', () {
    final verses = parser.parse(_gen1, bookOsis: 'Gen');
    expect(verses, hasLength(2));
    final v1 = verses.first;
    expect(v1.osisId, 'Gen.1.1');
    expect(v1.words, hasLength(7));
    expect(v1.words.first.fullText, 'בְּרֵאשִׁ֖ית');
    expect(v1.words.first.fullText.contains('/'), isFalse);
    expect(v1.words.first.bare, 'בראשית');
    expect(v1.words.last.taamName, 'סוף פסוק');
  });

  test('attaches maqqef to the previous word', () {
    final verses = parser.parse(_gen1, bookOsis: 'Gen');
    final v2 = verses[1];
    expect(v2.words, hasLength(2));
    expect(v2.words.first.fullText.endsWith('\u05BE'), isTrue);
    expect(HebrewText.bare(v2.words.first.fullText), 'על');
  });

  test('parses bundled Genesis XML', () {
    final xml = File('assets/wlc/Gen.xml').readAsStringSync();
    final verses = parser.parse(xml, bookOsis: 'Gen');
    expect(verses, isNotEmpty);
    expect(verses.first.osisId, 'Gen.1.1');
    expect(verses.first.words.first.bare, 'בראשית');
    expect(verses.first.words.last.taamName, 'סוף פסוק');
  });
}
