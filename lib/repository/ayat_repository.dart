import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ayat_model.dart';

class AyatRepository {
  Future<List<AyatModel>> fetchAyat(int nomorSurat) async {
    final url = Uri.parse('https://equran.id/api/v2/surat/$nomorSurat');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List list = jsonData['data']['ayat'];

        return list.map((e) => AyatModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil ayat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}