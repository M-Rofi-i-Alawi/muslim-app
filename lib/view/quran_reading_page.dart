import 'package:flutter/material.dart';
import '../services/tr_service.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quran_bookmark_service.dart';
const _kTeal     = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);
const _kNavyBg   = Color(0xFF0D1B2A);   // background immersive reading
const _kNavyCard = Color(0xFF1A2940);   // card / bottom sheet

class QuranReadingPage extends StatefulWidget {
  final List<dynamic> ayatList;
  final int           initialIndex;
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
  late int    _currentIndex;
  bool        _showUI    = true;
  bool        _bookmarked = false;
  double      _fontSize  = 30.0;
  final _svc = QuranBookmarkService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl     = PageController(initialPage: widget.initialIndex);
    _checkBookmark();
    // Immersive: sembunyikan status bar & nav bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // FIX: status bar icon putih agar kontras di atas background gelap
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    // Kembalikan system UI normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // FIX: kembalikan status bar sesuai theme saat halaman ditutup
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  Future<void> _checkBookmark() async {
    final ayat   = widget.ayatList[_currentIndex];
    final result = await _svc.isBookmarked(widget.nomorSurat, ayat.nomorAyat);
    if (mounted) setState(() => _bookmarked = result);
  }

  Future<void> _toggleBookmark() async {
    final ayat   = widget.ayatList[_currentIndex];
    final result = await _svc.toggleBookmark(QuranBookmark(
      nomorSurat: widget.nomorSurat,
      namaSurat:  widget.namaSurat,
      nomorAyat:  ayat.nomorAyat,
      teksArab:   ayat.arab,
      terjemahan: ayat.arti,
    ));
    if (mounted) {
      setState(() => _bookmarked = result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result ? context.tr('Ayat disimpan ke bookmark') : context.tr('Bookmark dihapus'),
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _kTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  // ─── SHARE AYAT ───────────────────────────────────────────────────────────
  void _shareAyat() {
    final ayat = widget.ayatList[_currentIndex];
    // FIX: tambah fitur share teks ayat
    final text =
        '${ayat.arab}\n\n${ayat.latin}\n\n"${ayat.arti}"\n\n— ${widget.namaSurat}, Ayat ${ayat.nomorAyat}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: TrText('Ayat disalin ke clipboard', style: GoogleFonts.poppins()),
      backgroundColor: _kTealDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavyBg,
      body: GestureDetector(
        // FIX: tap untuk show/hide UI, tapi tidak trigger saat swipe
        onTap: () => setState(() => _showUI = !_showUI),
        child: Stack(
          children: [
            // ── PageView ayat ─────────────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.ayatList.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _checkBookmark();
                _svc.saveLastRead(QuranLastRead(
                  nomorSurat: widget.nomorSurat,
                  namaSurat:  widget.namaSurat,
                  nomorAyat:  widget.ayatList[i].nomorAyat,
                ));
              },
              itemBuilder: (_, index) =>
                  _buildAyatView(widget.ayatList[index]),
            ),

            // ── Top bar ────────────────────────────────────────────────────
            AnimatedOpacity(
              // FIX: ganti if(_showUI) → AnimatedOpacity agar transisi smooth
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [Color(0xEE0D1B2A), Colors.transparent],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                widget.namaSurat,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            // FIX: tambah tombol copy/share
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                              tooltip: context.tr('Salin ayat'),
                              onPressed: _shareAyat,
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_fields_rounded, color: Colors.white70),
                              tooltip: context.tr('Ukuran font'),
                              onPressed: _showFontDialog,
                            ),
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
              ),
            ),

            // ── Bottom bar ─────────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end:   Alignment.topCenter,
                        colors: [Color(0xEE0D1B2A), Colors.transparent],
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
                                value: (_currentIndex + 1) / widget.ayatList.length,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation(_kTeal),
                                minHeight: 3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Navigasi ayat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // FIX: tambah tooltip dan visual disabled state yang jelas
                                IconButton(
                                  icon: Icon(
                                    Icons.chevron_left_rounded,
                                    color: _currentIndex > 0
                                        ? Colors.white70
                                        : Colors.white24,
                                    size: 32,
                                  ),
                                  onPressed: _currentIndex > 0
                                      ? () => _pageCtrl.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          )
                                      : null,
                                ),
                                // FIX: tampilkan progress lebih jelas
                                Column(
                                  children: [
                                    Text(
                                      '${context.tr('Ayat')} ${widget.ayatList[_currentIndex].nomorAyat}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${_currentIndex + 1} / ${widget.ayatList.length}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54, fontSize: 11),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.chevron_right_rounded,
                                    color: _currentIndex < widget.ayatList.length - 1
                                        ? Colors.white70
                                        : Colors.white24,
                                    size: 32,
                                  ),
                                  onPressed: _currentIndex < widget.ayatList.length - 1
                                      ? () => _pageCtrl.nextPage(
                                            duration: const Duration(milliseconds: 300),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── VIEW SATU AYAT ───────────────────────────────────────────────────────
  Widget _buildAyatView(dynamic ayat) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 100, 28, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge nomor ayat
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kTeal.withOpacity(0.4), width: 1),
              ),
              child: Text(
                '${widget.namaSurat} · ${context.tr('Ayat')} ${ayat.nomorAyat}',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
              ),
            ),

            const SizedBox(height: 48),

            // Teks Arab
            Text(
              ayat.arab,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: _fontSize,
                  color: Colors.white,
                  fontFamily: 'serif',
                  height: 2.2),
            ),

            const SizedBox(height: 36),

            // Divider dekoratif
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 24, height: 1, color: _kTeal.withOpacity(0.3)),
                Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: _kTeal.withOpacity(0.6), shape: BoxShape.circle)),
                Container(width: 24, height: 1, color: _kTeal.withOpacity(0.3)),
              ],
            ),

            const SizedBox(height: 28),

            // Latin / transliterasi
            Text(
              ayat.latin,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF7EC8B8),
                  fontStyle: FontStyle.italic,
                  height: 1.8),
            ),

            const SizedBox(height: 20),

            // Terjemahan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // FIX: beri background container agar terjemahan lebih terbaca
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                '"${ayat.arti}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.8),
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
      backgroundColor: _kNavyCard,
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
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              TrText('Ukuran Tulisan Arab',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),

              // Preview teks Arab
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: 'serif',
                      color: Colors.white,
                      height: 2.0),
                ),
              ),

              const SizedBox(height: 8),

              // FIX: tampilkan ukuran font saat ini
              Text(
                '${_fontSize.toInt()} px',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),

              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14, color: Colors.white60)),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 20, max: 50, divisions: 15,
                      activeColor: _kTeal,
                      inactiveColor: Colors.white12,
                      onChanged: (v) {
                        setModal(() => _fontSize = v);
                        setState(() => _fontSize = v);
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24, color: Colors.white60)),
                ],
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTeal,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: TrText('Selesai', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}