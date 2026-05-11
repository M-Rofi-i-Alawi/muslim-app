import 'package:flutter/material.dart';
import '../services/tr_service.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/doa_model.dart';
import '../utils/theme_helper.dart';
const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);

class DoaDetailPage extends StatelessWidget {
  final DoaModel doa;

  const DoaDetailPage({super.key, required this.doa});

  void _copyDoa(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: '${doa.arab}\n\n${doa.latin}\n\n${doa.arti}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TrText('Doa berhasil disalin', style: GoogleFonts.poppins()),
        backgroundColor: _kTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: adaptive colors
    final c             = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _kTealDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            // title hanya muncul saat collapsed
            title: Text(
              doa.judul,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
              collapseMode: CollapseMode.pin,
              // titlePadding kosong agar title AppBar yang tampil, bukan ini
              titlePadding: EdgeInsets.zero,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kTealDark, _kTeal, _kTealLight],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Icon dengan dekorasi lebih kaya
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 12),
                      // Judul di bawah icon (expanded state)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Text(
                          doa.judul,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle dekoratif
                      Text(
                        'الدعاء',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 16,
                          fontFamily: 'serif',
                        ),
                      ),
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
                    c: c,
                    label: 'Arab',
                    labelColor: _kTeal,
                    labelBg: _kTeal.withOpacity(0.12),
                    child: Text(
                      doa.arab,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'serif',
                        height: 2.2,
                        // FIX: hardcoded 0xFF1A1A2E → c.onSurface
                        color: c.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card Latin
                  _buildSection(
                    c: c,
                    label: 'Latin',
                    labelColor: const Color(0xFF7B1FA2),
                    labelBg: const Color(0xFF7B1FA2).withOpacity(0.12),
                    child: Text(
                      doa.latin,
                      style: GoogleFonts.poppins(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        // FIX: Colors.grey[700] → c.textSecondary
                        color: c.textSecondary,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card Artinya
                  _buildSection(
                    c: c,
                    label: 'Artinya',
                    labelColor: const Color(0xFF388E3C),
                    labelBg: const Color(0xFF388E3C).withOpacity(0.12),
                    child: Text(
                      '"${doa.arti}"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        // FIX: hardcoded 0xFF1A1A2E → c.onSurface
                        color: c.onSurface,
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
                      icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                      label: TrText('Salin Doa',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kTeal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    required AppColors c,
    required String label,
    required Color labelColor,
    required Color labelBg,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // FIX: Colors.white → c.surface (adaptive)
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: c.shadow,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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