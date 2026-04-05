class PanduanIbadahCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final List<PanduanIbadahItem> items;

  PanduanIbadahCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });

  factory PanduanIbadahCategory.fromJson(Map<String, dynamic> json) {
    return PanduanIbadahCategory(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      items: (json['items'] as List)
          .map((item) => PanduanIbadahItem.fromJson(item))
          .toList(),
    );
  }
}

class PanduanIbadahItem {
  final String id;
  final String title;
  final String shortDesc;
  final List<PanduanSection> sections;
  final List<String> references;

  PanduanIbadahItem({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.sections,
    required this.references,
  });

  factory PanduanIbadahItem.fromJson(Map<String, dynamic> json) {
    return PanduanIbadahItem(
      id: json['id'],
      title: json['title'],
      shortDesc: json['shortDesc'],
      sections: (json['sections'] as List)
          .map((section) => PanduanSection.fromJson(section))
          .toList(),
      references: List<String>.from(json['references'] ?? []),
    );
  }
}

class PanduanSection {
  final String title;
  final String type; // text, steps, list, arabic, note, warning
  final dynamic content; // String, List<String>, or List<Step>
  
  PanduanSection({
    required this.title,
    required this.type,
    required this.content,
  });

  factory PanduanSection.fromJson(Map<String, dynamic> json) {
    dynamic content;
    
    if (json['type'] == 'steps') {
      content = (json['content'] as List)
          .map((step) => StepItem.fromJson(step))
          .toList();
    } else if (json['type'] == 'list') {
      content = List<String>.from(json['content']);
    } else if (json['type'] == 'arabic') {
      content = ArabicText.fromJson(json['content']);
    } else {
      content = json['content'];
    }
    
    return PanduanSection(
      title: json['title'],
      type: json['type'],
      content: content,
    );
  }
}

class StepItem {
  final int number;
  final String title;
  final String description;
  final String? arabic;
  final String? transliteration;
  final String? translation;

  StepItem({
    required this.number,
    required this.title,
    required this.description,
    this.arabic,
    this.transliteration,
    this.translation,
  });

  factory StepItem.fromJson(Map<String, dynamic> json) {
    return StepItem(
      number: json['number'],
      title: json['title'],
      description: json['description'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
    );
  }
}

class ArabicText {
  final String arabic;
  final String transliteration;
  final String translation;

  ArabicText({
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  factory ArabicText.fromJson(Map<String, dynamic> json) {
    return ArabicText(
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
    );
  }
}