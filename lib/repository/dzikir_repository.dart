import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/dzikir_model.dart';

class DzikirRepository {
  Future<List<DzikirModel>> fetchDzikirPagi() async {
    return _loadDzikir('dzikir_pagi.json');
  }

  Future<List<DzikirModel>> fetchDzikirPetang() async {
    return _loadDzikir('dzikir_petang.json');
  }

  Future<List<DzikirModel>> fetchDzikirShalat() async {
    return _loadDzikir('dzikir_shalat.json');
  }

  Future<List<DzikirModel>> _loadDzikir(String filename) async {
    try {
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/$filename');
      } catch (e) {
        jsonString = await rootBundle.loadString(filename);
      }
      
      final List data = jsonDecode(jsonString);
      return data.map((e) => DzikirModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error loading dzikir $filename: $e');
      throw Exception('Gagal memuat dzikir: $e');
    }
  }
}