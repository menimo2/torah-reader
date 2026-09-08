import 'verse_ref.dart';

const aliyahOrder = ['1', '2', '3', '4', '5', '6', '7', 'M'];

const aliyahLabels = {
  '1': 'ראשון',
  '2': 'שני',
  '3': 'שלישי',
  '4': 'רביעי',
  '5': 'חמישי',
  '6': 'שישי',
  '7': 'שביעי',
  'M': 'מפטיר',
};

class AliyahRange {
  const AliyahRange({required this.start, required this.end});

  final VerseRef start;
  final VerseRef end;

  factory AliyahRange.fromJson(Map<String, dynamic> json) {
    return AliyahRange(
      start: VerseRef.fromJson(json['start'] as Map<String, dynamic>),
      end: VerseRef.fromJson(json['end'] as Map<String, dynamic>),
    );
  }
}

class Parasha {
  const Parasha({
    required this.id,
    required this.hebrewName,
    required this.bookOsis,
    required this.combined,
    required this.order,
    required this.aliyot,
  });

  final String id;
  final String hebrewName;
  final String bookOsis;
  final bool combined;
  final int order;
  final Map<String, AliyahRange> aliyot;

  factory Parasha.fromJson(Map<String, dynamic> json) {
    final raw = json['aliyot'] as Map<String, dynamic>;
    return Parasha(
      id: json['id'] as String,
      hebrewName: json['hebrewName'] as String,
      bookOsis: json['bookOsis'] as String,
      combined: json['combined'] as bool,
      order: json['order'] as int,
      aliyot: {
        for (final entry in raw.entries)
          entry.key: AliyahRange.fromJson(entry.value as Map<String, dynamic>),
      },
    );
  }
}

class ParashaCatalog {
  const ParashaCatalog(this.parashot);

  final List<Parasha> parashot;

  factory ParashaCatalog.fromJson(Map<String, dynamic> json) {
    final list = json['parashot'] as List<dynamic>;
    return ParashaCatalog([
      for (final item in list) Parasha.fromJson(item as Map<String, dynamic>),
    ]);
  }

  Parasha byId(String id) => parashot.firstWhere((p) => p.id == id);

  Parasha? find(String id) {
    for (final parasha in parashot) {
      if (parasha.id == id) return parasha;
    }
    return null;
  }

  List<Parasha> forBook(String bookOsis) =>
      parashot.where((p) => p.bookOsis == bookOsis).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}

class PassageSelection {
  const PassageSelection({
    required this.parashaId,
    required this.aliyahId,
  });

  static const initial = PassageSelection(
    parashaId: 'Bereshit',
    aliyahId: '1',
  );

  final String parashaId;
  final String aliyahId;

  String get aliyahLabel => aliyahLabels[aliyahId] ?? aliyahId;

  PassageSelection copyWith({String? parashaId, String? aliyahId}) {
    return PassageSelection(
      parashaId: parashaId ?? this.parashaId,
      aliyahId: aliyahId ?? this.aliyahId,
    );
  }
}
