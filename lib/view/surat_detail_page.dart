import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/surat_model.dart';
import '../viewmodel/ayat_viewmodel.dart';
import '../utils/theme_helper.dart';
import '../services/settings_service.dart';
import '../services/quran_bookmark_service.dart';
import 'quran_reading_page.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);

class SuratDetailPage extends StatefulWidget {
  final SuratModel surat;
  final int?       scrollToAyat;

  const SuratDetailPage({
    super.key,
    required this.surat,
    this.scrollToAyat,
  });

  @override
  State<SuratDetailPage> createState() => SuratDetailPageState();
}

class SuratDetailPageState extends State<SuratDetailPage> {
  final _svc        = QuranBookmarkService();
  final Map<int, bool> _bookmarkStatus = {};
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AyatViewModel>();
      await vm.getAyat(widget.surat.nomor);

      await _svc.saveLastRead(QuranLastRead(
        nomorSurat: widget.surat.nomor,
        namaSurat:  widget.surat.namaLatin,
        nomorAyat:  1,
      ));

      _loadBookmarkStatus(vm.ayatList);

      if (widget.scrollToAyat != null && widget.scrollToAyat! > 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        _scrollToAyat(widget.scrollToAyat!);
      }
    });
  }

  Future<void> _loadBookmarkStatus(List ayatList) async {
    for (final ayat in ayatList) {
      final status = await _svc.isBookmarked(widget.surat.nomor, ayat.nomorAyat);
      if (mounted) {
        setState(() => _bookmarkStatus[ayat.nomorAyat] = status);
      }
    }
  }

  void _scrollToAyat(int nomorAyat) {
    final offset = (nomorAyat - 1) * 180.0;
    _scrollCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: adaptive background
    final c = context.colors;
    return Scaffold(
      // FIX: _kBg → c.background (adaptive)
      backgroundColor: c.background,
      body: Consumer<AyatViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              _buildAppBar(),

              if (vm.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _kTeal)),
                )
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // FIX: Colors.grey → c.textHint
                        Icon(Icons.wifi_off_rounded, color: c.textHint, size: 60),
                        const SizedBox(height: 12),
                        TrText('Gagal memuat ayat',
                            style: GoogleFonts.poppins(color: c.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => vm.getAyat(widget.surat.nomor),
                          style: ElevatedButton.styleFrom(backgroundColor: _kTeal),
                          child: TrText('Coba Lagi',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (vm.ayatList.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) return _buildSuratHeader(vm);
                        final ayat = vm.ayatList[index - 1];
                        return _buildAyatCard(ayat, vm.ayatList);
                      },
                      childCount: vm.ayatList.length + 1,
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  child: Center(
                    child: TrText('Tidak ada data',
                        // FIX: Colors.grey → c.textSecondary
                        style: GoogleFonts.poppins(color: c.textSecondary)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _kTealDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.surat.namaLatin,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.text_fields_rounded, color: Colors.white),
          onPressed: _showFontSizeDialog,
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
          onPressed: () {
            final vm = context.read<AyatViewModel>();
            if (vm.ayatList.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranReadingPage(
                    ayatList:     vm.ayatList,
                    initialIndex: 0,
                    namaSurat:    widget.surat.namaLatin,
                    nomorSurat:   widget.surat.nomor,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  // ─── HEADER SURAT ─────────────────────────────────────────────────────────
  Widget _buildSuratHeader(AyatViewModel vm) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kTeal.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Text(widget.surat.nama,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 36, fontFamily: 'serif', color: Colors.white, height: 1.8)),
          const SizedBox(height: 4),
          Text(widget.surat.namaLatin,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _infoChip(context.tr(widget.surat.arti)),
              _infoChip('${widget.surat.jumlahAyat} ${context.tr('Ayat')}'),
              _infoChip(_cap(context.tr(widget.surat.tempatTurun))),
            ],
          ),
          if (widget.surat.nomor != 9) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22, fontFamily: 'serif', color: Colors.white, height: 2.0),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (vm.ayatList.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuranReadingPage(
                      ayatList:     vm.ayatList,
                      initialIndex: 0,
                      namaSurat:    widget.surat.namaLatin,
                      nomorSurat:   widget.surat.nomor,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  TrText('Mode Baca Full Screen',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  // ─── AYAT CARD ────────────────────────────────────────────────────────────
  Widget _buildAyatCard(dynamic ayat, List ayatList) {
    // FIX: adaptive colors
    final c            = context.colors;
    final isBookmarked = _bookmarkStatus[ayat.nomorAyat] ?? false;
    final fontSize     = context.watch<SettingsService>().quranFontSize;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // FIX: Colors.white → c.surface (adaptive)
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: isBookmarked
            ? Border.all(color: _kGold.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              // FIX: hardcoded opacity → c.shadow
              color: c.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header nomor + tombol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isBookmarked
                  ? _kGold.withOpacity(0.08)
                  : _kTeal.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: _kTeal, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${ayat.nomorAyat}',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const Spacer(),
                // Fullscreen per ayat
                GestureDetector(
                  onTap: () {
                    final index = (ayat.nomorAyat as int) - 1;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuranReadingPage(
                          ayatList:     ayatList,
                          initialIndex: index.clamp(0, ayatList.length - 1),
                          namaSurat:    widget.surat.namaLatin,
                          nomorSurat:   widget.surat.nomor,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    // FIX: Colors.grey[400] → c.textHint
                    child: Icon(Icons.fullscreen_rounded, color: c.textHint, size: 20),
                  ),
                ),
                // Bookmark
                GestureDetector(
                  onTap: () async {
                    final result = await _svc.toggleBookmark(
                      QuranBookmark(
                        nomorSurat:  widget.surat.nomor,
                        namaSurat:   widget.surat.namaLatin,
                        nomorAyat:   ayat.nomorAyat,
                        teksArab:    ayat.arab,
                        terjemahan:  ayat.arti,
                      ),
                    );
                    if (mounted) {
                      setState(() => _bookmarkStatus[ayat.nomorAyat] = result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? '${context.tr('Ayat')} ${ayat.nomorAyat} ${context.tr('disalin')}'
                                : context.tr('Bookmark dihapus'),
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: result ? _kGold : Colors.grey,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      // FIX: Colors.grey[400] → c.textHint
                      color: isBookmarked ? _kGold : c.textHint,
                      size: 22,
                    ),
                  ),
                ),
                // Salin
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: '${ayat.arab}\n\n${ayat.latin}\n\n${ayat.arti}'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${context.tr('Ayat')} ${ayat.nomorAyat} ${context.tr('disalin')}',
                          style: GoogleFonts.poppins()),
                      backgroundColor: _kTeal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    // FIX: Colors.grey[400] → c.textHint
                    child: Icon(Icons.copy_rounded, color: c.textHint, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Konten ayat
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FIX: hardcoded 0xFF1A1A2E → c.onSurface
                Text(ayat.arab,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: fontSize,
                        color: c.onSurface,
                        height: 2.2,
                        fontFamily: 'serif')),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  // FIX: Colors.grey.withOpacity → c.divider
                  child: Divider(color: c.divider, height: 1),
                ),
                Text(ayat.latin,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _kTeal,
                        fontStyle: FontStyle.italic,
                        height: 1.7)),
                const SizedBox(height: 10),
                // FIX: Colors.grey[700] → c.textSecondary
                Text('"${ayat.arti}"',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: c.textSecondary, height: 1.7)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DIALOG UKURAN FONT ───────────────────────────────────────────────────
  void _showFontSizeDialog() {
    // FIX: adaptive background untuk bottom sheet
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      // FIX: Colors.white → c.surface (adaptive)
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: SettingsService(),
          child: Consumer<SettingsService>(
            builder: (ctx, settings, __) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          // FIX: Colors.grey[300] → c.divider
                          color: c.divider,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  TrText('Ukuran Tulisan Arab',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          // FIX: adaptive text color
                          color: c.onSurface)),
                  const SizedBox(height: 16),
                  Text('بِسْمِ اللَّهِ',
                      style: TextStyle(
                          fontSize: settings.quranFontSize,
                          fontFamily: 'serif',
                          color: _kTealDark,
                          height: 2.0)),
                  Row(
                    children: [
                      Text('A', style: TextStyle(fontSize: 14, color: c.textSecondary)),
                      Expanded(
                        child: Slider(
                          value: settings.quranFontSize,
                          min: 18, max: 42,
                          divisions: 12,
                          activeColor: _kTeal,
                          onChanged: (v) => settings.setQuranFontSize(v),
                        ),
                      ),
                      Text('A', style: TextStyle(fontSize: 24, color: c.textSecondary)),
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
                    child: TrText('Selesai',
                        style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}