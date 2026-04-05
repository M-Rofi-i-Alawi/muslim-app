class SuratModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String arti;
  final String tempatTurun;
  final String deskripsi;

  SuratModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.arti,
    required this.tempatTurun,
    required this.deskripsi,
  });

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    return SuratModel(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      arti: json['arti'] ?? '',
      tempatTurun: json['tempatTurun'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }
}