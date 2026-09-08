class ChumashBook {
  const ChumashBook({
    required this.osis,
    required this.hebrewName,
    required this.assetFile,
    required this.chapterCount,
  });

  final String osis;
  final String hebrewName;
  final String assetFile;
  final int chapterCount;
}

class Books {
  Books._();

  static const List<ChumashBook> chumash = [
    ChumashBook(
      osis: 'Gen',
      hebrewName: 'בראשית',
      assetFile: 'assets/wlc/Gen.xml',
      chapterCount: 50,
    ),
    ChumashBook(
      osis: 'Exod',
      hebrewName: 'שמות',
      assetFile: 'assets/wlc/Exod.xml',
      chapterCount: 40,
    ),
    ChumashBook(
      osis: 'Lev',
      hebrewName: 'ויקרא',
      assetFile: 'assets/wlc/Lev.xml',
      chapterCount: 27,
    ),
    ChumashBook(
      osis: 'Num',
      hebrewName: 'במדבר',
      assetFile: 'assets/wlc/Num.xml',
      chapterCount: 36,
    ),
    ChumashBook(
      osis: 'Deut',
      hebrewName: 'דברים',
      assetFile: 'assets/wlc/Deut.xml',
      chapterCount: 34,
    ),
  ];

  static ChumashBook byOsis(String osis) =>
      chumash.firstWhere((b) => b.osis == osis);
}
