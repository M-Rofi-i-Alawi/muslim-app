class TasbihModel {
  final int id;
  final String nama;
  final String arab;
  int count;
  int target;
  final DateTime createdAt;

  TasbihModel({
    required this.id,
    required this.nama,
    required this.arab,
    this.count = 0,
    this.target = 33,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TasbihModel.fromJson(Map<String, dynamic> json) {
    return TasbihModel(
      id: json['id'],
      nama: json['nama'],
      arab: json['arab'],
      count: json['count'] ?? 0,
      target: json['target'] ?? 33,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'arab': arab,
      'count': count,
      'target': target,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get progress => target > 0 ? count / target : 0;
  bool get isCompleted => count >= target;
}

class TasbihHistory {
  final int id;
  final String namaZikir;
  final int totalCount;
  final int target;
  final DateTime completedAt;

  TasbihHistory({
    required this.id,
    required this.namaZikir,
    required this.totalCount,
    required this.target,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  factory TasbihHistory.fromJson(Map<String, dynamic> json) {
    return TasbihHistory(
      id: json['id'],
      namaZikir: json['namaZikir'],
      totalCount: json['totalCount'],
      target: json['target'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaZikir': namaZikir,
      'totalCount': totalCount,
      'target': target,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}