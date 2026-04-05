import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/surat_model.dart';

class SuratRepository {
  Future<List<SuratModel>> fetchSurat() async {
    final url = Uri.parse('https://equran.id/api/v2/surat');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List list = jsonData['data'];

        return list.map((e) => SuratModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil daftar surat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}