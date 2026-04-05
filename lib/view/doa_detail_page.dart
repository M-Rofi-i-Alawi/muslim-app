import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/doa_model.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kBg        = Color(0xFFF2F4F7);

class DoaDetailPage extends StatelessWidget {
  final DoaModel doa;

  const DoaDetailPage({super.key, required this.doa});

  void _copyDoa(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: '${doa.arab}\n\n${doa.latin}\n\n${doa.arti}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Doa berhasil disalin', style: GoogleFonts.poppins()),
        backgroundColor: _kTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding    = MediaQuery.of(context).padding.top;

    // ✅ FIX: hitung expandedHeight dinamis berdasarkan panjang judul
    // judul panjang butuh lebih banyak ruang
    final titleLines = (doa.judul.length / 20).ceil().clamp(1, 3);
    final expandedHeight = topPadding + 56 + 16 + 56 + 8 + (titleLines * 22.0) + 24;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ──────────────────────────────────────────
          SliverAppBar(
            // ✅ FIX: expandedHeight dinamis, tidak hardcode 160
            expandedHeight: expandedHeight.clamp(180.0, 260.0),
            pinned: true,
            backgroundColor: _kTealDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              doa.judul,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                tooltip: 'Salin Doa',
                onPressed: () => _copyDoa(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              // ✅ FIX: collapseMode.none agar tidak ada overlap
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kTealDark, _kTeal, _kTealLight],
                  ),
                ),
                // ✅ FIX: pakai SafeArea + Column yang tidak overflow
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ruang untuk appbar (back button + title row)
                      const SizedBox(height: 56),

                      // Icon
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 30),
                      ),

                      const SizedBox(height: 10),

                      // ✅ FIX: judul dengan Padding horizontal agar tidak
                      // mentok ke tepi dan teks tidak terpotong ke bawah
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          doa.judul,
                          textAlign: TextAlign.center,
                          // ✅ FIX: maxLines lebih besar + softWrap agar tidak overflow
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── KONTEN ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + bottomPadding),
              child: Column(
                children: [
                  // Card Arab
                  _buildSection(
                    label: 'Arab',
                    labelColor: _kTeal,
                    labelBg: _kTeal.withOpacity(0.08),
                    child: Text(
                      doa.arab,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 26,
                        fontFamily: 'serif',
                        height: 2.2,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card Latin
                  _buildSection(
                    label: 'Latin',
                    labelColor: const Color(0xFF7B1FA2),
                    labelBg: const Color(0xFF7B1FA2).withOpacity(0.08),
                    child: Text(
                      doa.latin,
                      style: GoogleFonts.poppins(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card Artinya
                  _buildSection(
                    label: 'Artinya',
                    labelColor: const Color(0xFF388E3C),
                    labelBg: const Color(0xFF388E3C).withOpacity(0.08),
                    child: Text(
                      '"${doa.arti}"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E),
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Salin
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _copyDoa(context),
                      icon: const Icon(Icons.copy_rounded,
                          color: Colors.white, size: 18),
                      label: Text('Salin Doa',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kTeal,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required Color labelColor,
    required Color labelBg,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}