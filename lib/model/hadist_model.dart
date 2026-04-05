class HadistModel {
  final int id;
  final int number;
  final String rawi;
  final String arab;
  final String latin;
  final String arti;
  final String penjelasan;
  final String tema;
  bool isFavorite;

  HadistModel({
    required this.id,
    required this.number,
    required this.rawi,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.penjelasan,
    required this.tema,
    this.isFavorite = false,
  });

  factory HadistModel.fromJson(Map<String, dynamic> json) {
    return HadistModel(
      id: json['id'],
      number: json['number'],
      rawi: json['rawi'],
      arab: json['arab'],
      latin: json['latin'],
      arti: json['arti'],
      penjelasan: json['penjelasan'],
      tema: json['tema'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'rawi': rawi,
      'arab': arab,
      'latin': latin,
      'arti': arti,
      'penjelasan': penjelasan,
      'tema': tema,
      'isFavorite': isFavorite,
    };
  }
}