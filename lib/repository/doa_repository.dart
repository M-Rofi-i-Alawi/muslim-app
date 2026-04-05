import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../model/doa_model.dart';

class DoaRepository {
  Future<List<DoaModel>> fetchDoa() async {
    // 🔄 Coba dari API dulu (optional, bisa jalan offline juga)
    try {
      final response = await http.get(
        Uri.parse('https://doa-doa-api-ahmadramadhan.fly.dev/api'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        print('✅ Doa loaded from API');
        final List data = jsonDecode(response.body);
        return data.map((e) => DoaModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('⚠️ API gagal, menggunakan data offline...');
    }

    // 📦 Jika API gagal, gunakan data lokal (PASTI JALAN!)
    try {
      final String jsonString = await rootBundle.loadString('doa.json');
      print('✅ Doa loaded from local assets');
      final List data = jsonDecode(jsonString);
      return data.map((e) => DoaModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error loading local doa: $e');
      throw Exception('Gagal memuat doa offline: $e');
    }
  }
}