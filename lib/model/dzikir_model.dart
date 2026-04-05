class DzikirModel {
  final int id;
  final String kategori; // pagi, petang, shalat
  final String nama;
  final String arab;
  final String latin;
  final String arti;
  final String keutamaan;
  final int jumlahBaca;
  int currentCount;
  bool isDone;

  DzikirModel({
    required this.id,
    required this.kategori,
    required this.nama,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.keutamaan,
    required this.jumlahBaca,
    this.currentCount = 0,
    this.isDone = false,
  });

  factory DzikirModel.fromJson(Map<String, dynamic> json) {
    return DzikirModel(
      id: json['id'],
      kategori: json['kategori'],
      nama: json['nama'],
      arab: json['arab'],
      latin: json['latin'],
      arti: json['arti'],
      keutamaan: json['keutamaan'],
      jumlahBaca: json['jumlahBaca'],
      currentCount: json['currentCount'] ?? 0,
      isDone: json['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': kategori,
      'nama': nama,
      'arab': arab,
      'latin': latin,
      'arti': arti,
      'keutamaan': keutamaan,
      'jumlahBaca': jumlahBaca,
      'currentCount': currentCount,
      'isDone': isDone,
    };
  }

  double get progress {
    if (jumlahBaca == 0) return 0;
    return currentCount / jumlahBaca;
  }

  bool get isCompleted => currentCount >= jumlahBaca;
}