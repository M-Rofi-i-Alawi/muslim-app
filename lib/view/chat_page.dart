import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../model/chat_message_model.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kBg        = Color(0xFFF2F4F7);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctrl        = TextEditingController();
  final _scrollCtrl  = ScrollController();

  // Pertanyaan cepat yang bisa di-tap
  static const _quickQuestions = [
    'Apa syarat sah shalat?',
    'Bacaan doa qunut subuh',
    'Cara tayamum yang benar',
    'Niat puasa Senin Kamis',
    'Doa setelah adzan',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(ChatViewModel vm, {String? text}) {
    final msg = text ?? _ctrl.text.trim();
    if (msg.isEmpty) return;
    vm.sendMessage(msg);
    _ctrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm             = context.watch<ChatViewModel>();
    final bottomPadding  = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── APP BAR ────────────────────────────────────────
          _buildAppBar(context, vm),

          // ── AREA CHAT ──────────────────────────────────────
          Expanded(
            child: vm.messages.isEmpty
                ? _buildEmptyState(vm)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: vm.messages.length,
                    itemBuilder: (_, i) =>
                        _ChatBubble(message: vm.messages[i]),
                  ),
          ),

          // ── LOADING ────────────────────────────────────────
          if (vm.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kTeal),
                  ),
                  const SizedBox(width: 10),
                  Text('AI sedang menyiapkan jawaban...',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),

          // ── INPUT AREA ─────────────────────────────────────
          _buildInputArea(vm, bottomPadding),
        ],
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, ChatViewModel vm) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              // Avatar AI
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanya ISLAM',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Online · siap menjawab',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color:
                                    Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  ],
                ),
              ),
              // Tombol hapus riwayat
              if (vm.messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white70),
                  tooltip: 'Hapus percakapan',
                  onPressed: () => _confirmClear(context, vm),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(ChatViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Ilustrasi
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.question_answer_rounded,
                color: _kTeal, size: 46),
          ),
          const SizedBox(height: 18),
          Text('Tanya Seputar Islam',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text(
            'Ajukan pertanyaan tentang ibadah, Al-Qur\'an,\nhadist, doa, dan seputar Islam lainnya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.6),
          ),
          const SizedBox(height: 28),

          // Pertanyaan cepat
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Coba tanya:',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700])),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _quickQuestions.map((q) {
              return GestureDetector(
                onTap: () => _send(vm, text: q),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kTeal.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(q,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _kTeal,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── INPUT AREA ───────────────────────────────────────────────────────────
  Widget _buildInputArea(ChatViewModel vm, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: _kTeal.withOpacity(0.2), width: 1),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Tanya sesuatu tentang Islam...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol kirim
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46, height: 46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [_kTealDark, _kTeal]),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: vm.isLoading ? null : () => _send(vm),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── KONFIRMASI HAPUS ─────────────────────────────────────────────────────
  void _confirmClear(BuildContext context, ChatViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Percakapan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Semua pesan akan dihapus.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              vm.clearMessages();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTeal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar AI
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _kTeal, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _kTeal : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teks pesan
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isUser
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        height: 1.5,
                      ),
                    ),

                  // ✅ Link sumber (ganti gambar)
                  // Tampilkan imageUrls sebagai link teks, bukan gambar
                  if (message.imageUrls != null &&
                      message.imageUrls!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _kTeal.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link_rounded,
                                  color: _kTeal, size: 14),
                              const SizedBox(width: 6),
                              Text('Sumber:',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _kTeal)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...message.imageUrls!.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: e.value));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('Link disalin',
                                        style:
                                            GoogleFonts.poppins()),
                                    backgroundColor: _kTeal,
                                    behavior:
                                        SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10)),
                                    duration:
                                        const Duration(seconds: 1),
                                  ));
                                },
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('${e.key + 1}. ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: _kTeal)),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _kTeal,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.copy_rounded,
                                        color: _kTeal, size: 13),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Avatar user
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: _kTeal, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}