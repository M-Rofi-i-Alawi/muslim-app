class RamadhanEntry {
  final String id; // format: YYYY-MM-DD
  final DateTime date;
  final int ramadhanDay; // Hari ke-X dari 30
  
  // Checklist Amalan
  final bool puasa;
  final bool shalatSubuh;
  final bool shalatDzuhur;
  final bool shalatAshar;
  final bool shalatMaghrib;
  final bool shalatIsya;
  final bool shalatTarawih;
  final bool shalatTahajud;
  
  // Tadarus
  final int tadarusJuz; // Juz berapa (1-30)
  final int tadarusHalaman; // Halaman tambahan
  final String tadarusSurah; // Surat apa
  
  // Infak
  final double infakAmount;
  final String infakNote;
  
  // Ceramah
  final String ceramahTitle;
  final String ceramahUstadz;
  final String ceramahRangkuman;
  final List<String> ceramahPoinPenting;
  
  // Catatan & Karomah
  final String catatanHarian;
  final String doaTerkabul;
  final String momenSpesial;
  final String refleksi;
  final String pembelajaran;

  RamadhanEntry({
    required this.id,
    required this.date,
    required this.ramadhanDay,
    this.puasa = false,
    this.shalatSubuh = false,
    this.shalatDzuhur = false,
    this.shalatAshar = false,
    this.shalatMaghrib = false,
    this.shalatIsya = false,
    this.shalatTarawih = false,
    this.shalatTahajud = false,
    this.tadarusJuz = 0,
    this.tadarusHalaman = 0,
    this.tadarusSurah = '',
    this.infakAmount = 0,
    this.infakNote = '',
    this.ceramahTitle = '',
    this.ceramahUstadz = '',
    this.ceramahRangkuman = '',
    this.ceramahPoinPenting = const [],
    this.catatanHarian = '',
    this.doaTerkabul = '',
    this.momenSpesial = '',
    this.refleksi = '',
    this.pembelajaran = '',
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'ramadhanDay': ramadhanDay,
      'puasa': puasa,
      'shalatSubuh': shalatSubuh,
      'shalatDzuhur': shalatDzuhur,
      'shalatAshar': shalatAshar,
      'shalatMaghrib': shalatMaghrib,
      'shalatIsya': shalatIsya,
      'shalatTarawih': shalatTarawih,
      'shalatTahajud': shalatTahajud,
      'tadarusJuz': tadarusJuz,
      'tadarusHalaman': tadarusHalaman,
      'tadarusSurah': tadarusSurah,
      'infakAmount': infakAmount,
      'infakNote': infakNote,
      'ceramahTitle': ceramahTitle,
      'ceramahUstadz': ceramahUstadz,
      'ceramahRangkuman': ceramahRangkuman,
      'ceramahPoinPenting': ceramahPoinPenting,
      'catatanHarian': catatanHarian,
      'doaTerkabul': doaTerkabul,
      'momenSpesial': momenSpesial,
      'refleksi': refleksi,
      'pembelajaran': pembelajaran,
    };
  }

  // Convert from JSON
  factory RamadhanEntry.fromJson(Map<String, dynamic> json) {
    return RamadhanEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      ramadhanDay: json['ramadhanDay'],
      puasa: json['puasa'] ?? false,
      shalatSubuh: json['shalatSubuh'] ?? false,
      shalatDzuhur: json['shalatDzuhur'] ?? false,
      shalatAshar: json['shalatAshar'] ?? false,
      shalatMaghrib: json['shalatMaghrib'] ?? false,
      shalatIsya: json['shalatIsya'] ?? false,
      shalatTarawih: json['shalatTarawih'] ?? false,
      shalatTahajud: json['shalatTahajud'] ?? false,
      tadarusJuz: json['tadarusJuz'] ?? 0,
      tadarusHalaman: json['tadarusHalaman'] ?? 0,
      tadarusSurah: json['tadarusSurah'] ?? '',
      infakAmount: (json['infakAmount'] ?? 0).toDouble(),
      infakNote: json['infakNote'] ?? '',
      ceramahTitle: json['ceramahTitle'] ?? '',
      ceramahUstadz: json['ceramahUstadz'] ?? '',
      ceramahRangkuman: json['ceramahRangkuman'] ?? '',
      ceramahPoinPenting: List<String>.from(json['ceramahPoinPenting'] ?? []),
      catatanHarian: json['catatanHarian'] ?? '',
      doaTerkabul: json['doaTerkabul'] ?? '',
      momenSpesial: json['momenSpesial'] ?? '',
      refleksi: json['refleksi'] ?? '',
      pembelajaran: json['pembelajaran'] ?? '',
    );
  }

  // Copy with
  RamadhanEntry copyWith({
    String? id,
    DateTime? date,
    int? ramadhanDay,
    bool? puasa,
    bool? shalatSubuh,
    bool? shalatDzuhur,
    bool? shalatAshar,
    bool? shalatMaghrib,
    bool? shalatIsya,
    bool? shalatTarawih,
    bool? shalatTahajud,
    int? tadarusJuz,
    int? tadarusHalaman,
    String? tadarusSurah,
    double? infakAmount,
    String? infakNote,
    String? ceramahTitle,
    String? ceramahUstadz,
    String? ceramahRangkuman,
    List<String>? ceramahPoinPenting,
    String? catatanHarian,
    String? doaTerkabul,
    String? momenSpesial,
    String? refleksi,
    String? pembelajaran,
  }) {
    return RamadhanEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      ramadhanDay: ramadhanDay ?? this.ramadhanDay,
      puasa: puasa ?? this.puasa,
      shalatSubuh: shalatSubuh ?? this.shalatSubuh,
      shalatDzuhur: shalatDzuhur ?? this.shalatDzuhur,
      shalatAshar: shalatAshar ?? this.shalatAshar,
      shalatMaghrib: shalatMaghrib ?? this.shalatMaghrib,
      shalatIsya: shalatIsya ?? this.shalatIsya,
      shalatTarawih: shalatTarawih ?? this.shalatTarawih,
      shalatTahajud: shalatTahajud ?? this.shalatTahajud,
      tadarusJuz: tadarusJuz ?? this.tadarusJuz,
      tadarusHalaman: tadarusHalaman ?? this.tadarusHalaman,
      tadarusSurah: tadarusSurah ?? this.tadarusSurah,
      infakAmount: infakAmount ?? this.infakAmount,
      infakNote: infakNote ?? this.infakNote,
      ceramahTitle: ceramahTitle ?? this.ceramahTitle,
      ceramahUstadz: ceramahUstadz ?? this.ceramahUstadz,
      ceramahRangkuman: ceramahRangkuman ?? this.ceramahRangkuman,
      ceramahPoinPenting: ceramahPoinPenting ?? this.ceramahPoinPenting,
      catatanHarian: catatanHarian ?? this.catatanHarian,
      doaTerkabul: doaTerkabul ?? this.doaTerkabul,
      momenSpesial: momenSpesial ?? this.momenSpesial,
      refleksi: refleksi ?? this.refleksi,
      pembelajaran: pembelajaran ?? this.pembelajaran,
    );
  }

  // Helper: Check if all shalat complete
  bool get allShalatComplete {
    return shalatSubuh && shalatDzuhur && shalatAshar && 
           shalatMaghrib && shalatIsya;
  }

  // Helper: Count completed shalat
  int get completedShalatCount {
    int count = 0;
    if (shalatSubuh) count++;
    if (shalatDzuhur) count++;
    if (shalatAshar) count++;
    if (shalatMaghrib) count++;
    if (shalatIsya) count++;
    return count;
  }
}

// Statistics Model
class RamadhanStatistics {
  final int totalDays; // Total hari yang sudah dicatat
  final int puasaCount; // Berapa hari puasa
  final int allShalatCompleteCount; // Berapa hari shalat 5 waktu lengkap
  final int tarawihCount; // Berapa hari tarawih
  final int tahajudCount; // Berapa hari tahajud
  final int totalTadarusJuz; // Total juz yang sudah dibaca
  final double totalInfak; // Total infak
  final int ceramahCount; // Berapa ceramah yang dirangkum

  RamadhanStatistics({
    this.totalDays = 0,
    this.puasaCount = 0,
    this.allShalatCompleteCount = 0,
    this.tarawihCount = 0,
    this.tahajudCount = 0,
    this.totalTadarusJuz = 0,
    this.totalInfak = 0,
    this.ceramahCount = 0,
  });

  // Calculate percentage
  double get puasaPercentage => totalDays > 0 ? (puasaCount / totalDays) * 100 : 0;
  double get shalatPercentage => totalDays > 0 ? (allShalatCompleteCount / totalDays) * 100 : 0;
  double get tarawihPercentage => totalDays > 0 ? (tarawihCount / totalDays) * 100 : 0;
}