import 'package:flutter/material.dart';
import '../model/chat_message_model.dart';
import '../services/gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  final GeminiService _geminiService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatViewModel(this._geminiService);

  List<ChatMessage> get messages   => _messages;
  bool              get isLoading  => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    final response = await _geminiService.getResponse(text);

    _messages.add(ChatMessage(
      text:      response['text'],
      isUser:    false,
      imageUrls: response['imageUrls'], // ✅ tetap dikirim tapi ditampilkan sebagai link
    ));

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Tambahan: hapus semua pesan
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}