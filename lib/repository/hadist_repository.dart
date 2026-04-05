import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/hadist_model.dart';

class HadistRepository {
  Future<List<HadistModel>> fetchHadist() async {
    try {
      // ✅ Coba dengan prefix dulu
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/hadist_arbain.json');
      } catch (e) {
        // ✅ Kalau gagal, coba tanpa prefix (untuk web)
        jsonString = await rootBundle.loadString('hadist_arbain.json');
      }
      
      final List data = jsonDecode(jsonString);
      return data.map((e) => HadistModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error loading hadist: $e');
      throw Exception('Gagal memuat hadist: $e');
    }
  }

  Future<HadistModel> getHadistOfTheDay() async {
    final hadistList = await fetchHadist();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % hadistList.length;
    return hadistList[index];
  }
}