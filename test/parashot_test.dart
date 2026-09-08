import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/core/parashot.dart';

void main() {
  late ParashaCatalog catalog;

  setUpAll(() {
    final raw = File('assets/data/parashot.json').readAsStringSync();
    catalog = ParashaCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('54 weekly parashot plus 7 combined', () {
    expect(catalog.parashot.where((p) => !p.combined), hasLength(54));
    expect(catalog.parashot.where((p) => p.combined), hasLength(7));
  });

  test('Bereshit rishon is Gen 1:1–2:3', () {
    final bereshit = catalog.byId('Bereshit');
    expect(bereshit.hebrewName, 'בראשית');
    expect(bereshit.bookOsis, 'Gen');
    final rishon = bereshit.aliyot['1']!;
    expect(rishon.start.chapter, 1);
    expect(rishon.start.verse, 1);
    expect(rishon.end.chapter, 2);
    expect(rishon.end.verse, 3);
  });

  test('combined pair sits in the same book list', () {
    final lev = catalog.forBook('Lev').map((p) => p.id).toList();
    expect(lev, containsAll(['Tazria', 'Metzora', 'Tazria-Metzora']));
    expect(
      lev.indexOf('Tazria-Metzora'),
      greaterThan(lev.indexOf('Metzora')),
    );
  });
}
