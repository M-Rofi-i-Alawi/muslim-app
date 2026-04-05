import '../services/gemini_service.dart';

class ChatRepository {
  final GeminiService _service;

  ChatRepository(this._service);

  // ✅ Sekarang return Map karena ada text + imageUrls
  Future<Map<String, dynamic>> sendMessage(String message) async {
    return await _service.getResponse(message);
  }
}