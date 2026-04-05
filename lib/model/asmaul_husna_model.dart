class AsmaulHusnaModel {
  final int id;
  final int number;
  final String arab;
  final String latin;
  final String arti;
  final String penjelasan;
  bool isFavorite;
  bool isMemorized;

  AsmaulHusnaModel({
    required this.id,
    required this.number,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.penjelasan,
    this.isFavorite = false,
    this.isMemorized = false,
  });

  factory AsmaulHusnaModel.fromJson(Map<String, dynamic> json) {
    return AsmaulHusnaModel(
      id: json['id'],
      number: json['number'],
      arab: json['arab'],
      latin: json['latin'],
      arti: json['arti'],
      penjelasan: json['penjelasan'],
      isFavorite: json['isFavorite'] ?? false,
      isMemorized: json['isMemorized'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'arab': arab,
      'latin': latin,
      'arti': arti,
      'penjelasan': penjelasan,
      'isFavorite': isFavorite,
      'isMemorized': isMemorized,
    };
  }
}