import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quran_bookmark_service.dart';

// ─────────────────────────────────────────────
const _kTeal     = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);

/// Halaman baca full screen — satu ayat per layar, swipe kiri/kanan untuk ganti
class QuranReadingPage extends StatefulWidget {
  final List<dynamic> ayatList;
  final int           initialIndex;   // index ayat yang dibuka pertama
  final String        namaSurat;
  final int           nomorSurat;

  const QuranReadingPage({
    super.key,
    required this.ayatList,
    required this.initialIndex,
    required this.namaSurat,
    required this.nomorSurat,
  });

  @override
  State<QuranReadingPage> createState() => _QuranReadingPageState();
}

class _QuranReadingPageState extends State<QuranReadingPage> {
  late PageController _pageCtrl;
  late int _currentIndex;
  bool _showUI    = true;
  bool _bookmarked = false;
  double _fontSize = 30.0;
  final _svc = QuranBookmarkService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl     = PageController(initialPage: widget.initialIndex);
    _checkBookmark();
    // Sembunyikan status bar untuk pengalaman immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    // Kembalikan status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _checkBookmark() async {
    final ayat = widget.ayatList[_currentIndex];
    final result = await _svc.isBookmarked(
      widget.nomorSurat, ayat.nomorAyat);
    if (mounted) setState(() => _bookmarked = result);
  }

  Future<void> _toggleBookmark() async {
    final ayat = widget.ayatList[_currentIndex];
    final result = await _svc.toggleBookmark(QuranBookmark(
      nomorSurat:  widget.nomorSurat,
      namaSurat:   widget.namaSurat,
      nomorAyat:   ayat.nomorAyat,
      teksArab:    ayat.arab,
      terjemahan:  ayat.arti,
    ));
    if (mounted) {
      setState(() => _bookmarked = result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result ? 'Ayat disimpan ke bookmark' : 'Bookmark dihapus',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _kTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        child: Stack(
          children: [
            // ── PageView ayat ──────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.ayatList.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _checkBookmark();
                // Simpan last read setiap ganti ayat
                _svc.saveLastRead(QuranLastRead(
                  nomorSurat: widget.nomorSurat,
                  namaSurat:  widget.namaSurat,
                  nomorAyat:  widget.ayatList[i].nomorAyat,
                ));
              },
              itemBuilder: (context, index) {
                final ayat = widget.ayatList[index];
                return _buildAyatView(ayat, index);
              },
            ),

            // ── Top bar (tap untuk show/hide) ──────────────────
            if (_showUI)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xDD0D1B2A), Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              widget.namaSurat,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Ukuran font
                          IconButton(
                            icon: const Icon(Icons.text_fields_rounded,
                                color: Colors.white70),
                            onPressed: _showFontDialog,
                          ),
                          // Bookmark
                          IconButton(
                            icon: Icon(
                              _bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: _bookmarked
                                  ? const Color(0xFFE8B84B)
                                  : Colors.white70,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Bottom bar: progress & navigasi ───────────────
            if (_showUI)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xDD0D1B2A), Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (_currentIndex + 1) /
                                  widget.ayatList.length,
                              backgroundColor:
                                  Colors.white.withOpacity(0.15),
                              valueColor:
                                  const AlwaysStoppedAnimation(_kTeal),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Nomor ayat & navigasi
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white70, size: 32),
                                onPressed: _currentIndex > 0
                                    ? () => _pageCtrl.previousPage(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        )
                                    : null,
                              ),
                              Text(
                                'Ayat ${widget.ayatList[_currentIndex].nomorAyat} / ${widget.ayatList.length}',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white70, size: 32),
                                onPressed: _currentIndex <
                                        widget.ayatList.length - 1
                                    ? () => _pageCtrl.nextPage(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── VIEW SATU AYAT ───────────────────────────────────────────────────────
  Widget _buildAyatView(dynamic ayat, int index) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 100, 28, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge nomor
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _kTeal.withOpacity(0.4), width: 1),
              ),
              child: Text(
                '${widget.namaSurat} · Ayat ${ayat.nomorAyat}',
                style: GoogleFonts.poppins(
                    color: Colors.white60, fontSize: 12),
              ),
            ),

            const SizedBox(height: 40),

            // Teks Arab
            Text(
              ayat.arab,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _fontSize,
                color: Colors.white,
                fontFamily: 'serif',
                height: 2.2,
              ),
            ),

            const SizedBox(height: 36),

            // Divider
            Container(
              width: 60, height: 2,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            const SizedBox(height: 28),

            // Latin
            Text(
              ayat.latin,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF7EC8B8),
                fontStyle: FontStyle.italic,
                height: 1.8,
              ),
            ),

            const SizedBox(height: 20),

            // Terjemahan
            Text(
              '"${ayat.arti}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white70,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOG UKURAN FONT ───────────────────────────────────────────────────
  void _showFontDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2940),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ukuran Tulisan Arab',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Text('بِسْمِ اللَّهِ',
                  style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: 'serif',
                      color: Colors.white,
                      height: 2.0)),
              Row(
                children: [
                  const Text('A',
                      style: TextStyle(
                          fontSize: 14, color: Colors.white60)),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 20,
                      max: 50,
                      divisions: 15,
                      activeColor: _kTeal,
                      inactiveColor: Colors.white12,
                      onChanged: (v) {
                        setModal(() => _fontSize = v);
                        setState(() => _fontSize = v);
                      },
                    ),
                  ),
                  const Text('A',
                      style: TextStyle(
                          fontSize: 24, color: Colors.white60)),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTeal,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Selesai',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}