import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/panduan_ibadah_model.dart';

class PanduanIbadahRepository {
  // Load all categories from separate JSON files
  Future<List<PanduanIbadahCategory>> getAllCategories() async {
    try {
      List<PanduanIbadahCategory> categories = [];
      
      // List of JSON files to load
      final files = [
        'assets/panduan/shalat.json',
        'assets/panduan/wudhu.json',
        'assets/panduan/puasa.json',
        'assets/panduan/zakat.json',
        'assets/panduan/haji.json',
      ];
      
      // Load each file
      for (String file in files) {
        try {
          final String jsonString = await rootBundle.loadString(file);
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          
          // Parse as category
          final category = _parseCategoryFromJson(jsonData);
          categories.add(category);
        } catch (e) {
          print('Error loading $file: $e');
          // Continue loading other files even if one fails
        }
      }
      
      return categories;
    } catch (e) {
      print('Error loading panduan ibadah: $e');
      return [];
    }
  }

  // Get category by ID
  Future<PanduanIbadahCategory?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Parse category from JSON (single file format)
  PanduanIbadahCategory _parseCategoryFromJson(Map<String, dynamic> json) {
    return PanduanIbadahCategory(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      items: (json['items'] as List)
          .map((item) => _parseItemFromJson(item))
          .toList(),
    );
  }

  // Parse item from JSON
  PanduanIbadahItem _parseItemFromJson(Map<String, dynamic> json) {
    return PanduanIbadahItem(
      id: json['id'],
      title: json['title'],
      shortDesc: json['shortDesc'],
      sections: (json['sections'] as List)
          .map((section) => _parseSectionFromJson(section))
          .toList(),
      references: List<String>.from(json['references'] ?? []),
    );
  }

  // Parse section from JSON
  PanduanSection _parseSectionFromJson(Map<String, dynamic> json) {
    dynamic content;
    
    if (json['type'] == 'steps') {
      content = (json['content'] as List)
          .map((step) => StepItem(
                number: step['number'],
                title: step['title'],
                description: step['description'],
                arabic: step['arabic'],
                transliteration: step['transliteration'],
                translation: step['translation'],
              ))
          .toList();
    } else if (json['type'] == 'list') {
      content = List<String>.from(json['content']);
    } else if (json['type'] == 'arabic') {
      content = ArabicText(
        arabic: json['content']['arabic'],
        transliteration: json['content']['transliteration'],
        translation: json['content']['translation'],
      );
    } else if (json['type'] == 'text') {
      content = json['content'];
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