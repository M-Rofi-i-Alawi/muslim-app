class DoaModel {
  final String doa;      // Field asli dari API
  final String ayat;     // Field asli dari API
  final String latin;    // Field asli dari API
  final String artinya;  // Field asli dari API

  DoaModel({
    required this.doa,
    required this.ayat,
    required this.latin,
    required this.artinya,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      doa: json['doa'] ?? '',
      ayat: json['ayat'] ?? '',
      latin: json['latin'] ?? '',
      artinya: json['artinya'] ?? '',
    );
  }

  // ✅ Getters untuk compatibility dengan kode baru
  // Sekarang kamu bisa pakai doa.doa ATAU doa.judul, sama aja!
  String get judul => doa;
  String get arab => ayat;
  String get arti => artinya;
}