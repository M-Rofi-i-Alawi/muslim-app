import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/kiblat_model.dart';

class KiblatRepository {
  Future<KiblatModel> fetchArahKiblat({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/qibla/$latitude/$longitude',
    );
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return KiblatModel.fromJson(jsonData['data'], latitude, longitude);
      } else {
        throw Exception('Gagal memuat arah kiblat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}