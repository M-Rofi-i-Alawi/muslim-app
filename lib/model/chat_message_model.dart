class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;  // ✅ Tambah field untuk URL gambar
  final List<String>? imageUrls;  // ✅ Untuk multiple images

  ChatMessage({
    required this.text, 
    required this.isUser,
    this.imageUrl,
    this.imageUrls,
  });
}
