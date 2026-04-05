import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/asmaul_husna_model.dart';

class AsmaulHusnaRepository {
  Future<List<AsmaulHusnaModel>> fetchAsmaulHusna() async {
    try {
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/asmaul_husna.json');
      } catch (e) {
        jsonString = await rootBundle.loadString('asmaul_husna.json');
      }
      
      final List data = jsonDecode(jsonString);
      return data.map((e) => AsmaulHusnaModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error loading Asmaul Husna: $e');
      throw Exception('Gagal memuat Asmaul Husna: $e');
    }
  }
}