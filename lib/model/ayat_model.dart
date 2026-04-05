class AyatModel {
  final int nomorAyat;
  final String arab;
  final String latin;
  final String arti;

  AyatModel({
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory AyatModel.fromJson(Map<String, dynamic> json) {
    return AyatModel(
      nomorAyat: json['nomorAyat'] ?? 0,
      arab: json['teksArab'] ?? '',
      latin: json['teksLatin'] ?? '',
      arti: json['teksIndonesia'] ?? '',
    );
  }
}