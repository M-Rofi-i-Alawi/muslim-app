import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<Map<String, dynamic>> getResponse(String prompt) async {
    try {
      final systemPrompt = 
          "Kamu adalah asisten Muslim App yang ramah dan informatif. "
          "Jawab HANYA pertanyaan seputar Islam, doa, shalat, Al-Qur'an, dan ibadah. "
          "\n\n"
          "PENTING: Jika ada pertanyaan yang membutuhkan GAMBAR/VISUAL (seperti 'cara wudhu', 'gerakan shalat', 'tata cara haji', dll), "
          "SELALU sertakan URL gambar yang relevan di akhir jawaban dengan format: "
          "[IMAGE:https://example.com/gambar.jpg] "
          "\n\n"
          "Contoh jawaban dengan gambar: "
          "Cara wudhu yang benar adalah... [IMAGE:https://example.com/wudhu.jpg]"
          "\n\n"
          "Berikan jawaban yang jelas, singkat, dan mudah dipahami dalam Bahasa Indonesia.\n\n";
      
      final fullPrompt = systemPrompt + prompt;
      
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey'
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] ?? "";
        
        // ✅ Extract URL gambar dari response AI
        final imageUrls = _extractImageUrls(text);
        final cleanText = _removeImageTags(text);
        
        return {
          'text': cleanText,
          'imageUrls': imageUrls,
        };
      } else {
        return {
          'text': "Maaf, terjadi kesalahan. Silakan coba lagi.",
          'imageUrls': <String>[],
        };
      }
    } catch (e) {
      return {
        'text': "Terjadi kesalahan koneksi. Cek internet kamu ya!",
        'imageUrls': <String>[],
      };
    }
  }

  // ✅ Extract image URLs from AI response
  List<String> _extractImageUrls(String text) {
    final regex = RegExp(r'\[IMAGE:(https?://[^\]]+)\]');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  // ✅ Remove [IMAGE:...] tags from text
  String _removeImageTags(String text) {
    return text.replaceAll(RegExp(r'\[IMAGE:https?://[^\]]+\]'), '').trim();
  }
}
