import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kTeal      = Color.fromRGBO(0, 160, 134, 1);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _kTealDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Tentang Aplikasi',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kTealDark, _kTeal, _kTealLight],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mosque_rounded,
                            size: 52, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text('Muslim App',
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Versi 2.5.3 (Teal Edition)',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── KONTEN ───────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + bottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Deskripsi
                _SectionCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Aplikasi',
                  child: Text(
                    'Muslim App adalah aplikasi pendamping ibadah yang membantu umat Muslim '
                    'dalam menjalankan aktivitas keagamaan sehari-hari. Dilengkapi dengan '
                    'jadwal shalat berbasis GPS yang akurat, Al-Qur\'an digital lengkap, '
                    'kumpulan doa dan wirid, hadist pilihan, hingga fitur chatbot AI untuk '
                    'menjawab pertanyaan seputar Islam. Aplikasi ini dirancang dengan UI/UX '
                    'modern bertema Teal yang nyaman dan mudah digunakan.',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.7),
                  ),
                ),

                const SizedBox(height: 14),

                // Fitur utama
                _SectionCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Fitur Utama',
                  child: Column(
                    children: [
                      _featureItem(Icons.access_time_rounded,
                          'Jadwal Shalat',
                          'Waktu shalat akurat dengan GPS auto-detect, support 30+ kota',
                          _kTeal),
                      _featureItem(Icons.auto_stories_rounded,
                          'Al-Qur\'an Digital',
                          '114 Surat lengkap dengan terjemahan Indonesia & audio',
                          const Color(0xFF1565C0)),
                      _featureItem(Icons.favorite_rounded,
                          'Doa Harian',
                          'Kumpulan doa dengan teks Arab, Latin, dan terjemahan',
                          const Color(0xFFE8650A)),
                      _featureItem(Icons.book_rounded,
                          'Hadist',
                          'Hadist Arbain Nawawi dan hadist pilihan lainnya',
                          const Color(0xFF795548)),
                      _featureItem(Icons.explore_rounded,
                          'Arah Kiblat',
                          'Kompas digital GPS untuk menentukan arah kiblat akurat',
                          const Color(0xFF7B1FA2)),
                      _featureItem(Icons.repeat_rounded,
                          'Tasbih Digital',
                          'Counter dzikir digital dengan target & histori',
                          const Color(0xFF388E3C)),
                      _featureItem(Icons.repeat_rounded,
                          'Dzikir Harian',
                          'Panduan dzikir pagi & petang dengan hitungan',
                          const Color(0xFF00897B)),
                      _featureItem(Icons.star_rounded,
                          'Asmaul Husna',
                          '99 Nama Allah dengan Latin, Arab, dan artinya',
                          _kGold),
                      _featureItem(Icons.account_balance_wallet_rounded,
                          'Kalkulator Zakat',
                          'Hitung zakat maal, penghasilan, fitrah & profesi',
                          const Color(0xFF00838F)),
                      _featureItem(Icons.calendar_today_rounded,
                          'Kalender Hijri',
                          'Kalender Islam dengan konversi tanggal Masehi',
                          const Color(0xFF5E35B1)),
                      _featureItem(Icons.book_rounded,
                          'Panduan Ibadah',
                          'Tutorial shalat, wudhu, tayamum & ibadah lainnya',
                          const Color(0xFF6A1B9A)),
                      _featureItem(Icons.nightlight_round,
                          'Catatan Ramadhan',
                          'Jurnal ibadah harian: puasa, tadarus, sedekah, tarawih',
                          const Color(0xFFC62828)),
                      _featureItem(Icons.chat_bubble_outline_rounded,
                          'Tanya ISLAM',
                          'AI chatbot untuk menjawab pertanyaan keislaman',
                          _kTeal),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Teknologi
                _SectionCard(
                  icon: Icons.code_rounded,
                  title: 'Teknologi',
                  child: Column(
                    children: [
                      _techItem('Flutter 3.x', 'Cross-platform framework'),
                      _techItem('Provider', 'State management pattern'),
                      _techItem('Google Fonts', 'Typography — Poppins'),
                      _techItem('Geolocator', 'GPS & location services'),
                      _techItem('Flutter Compass', 'Compass sensor access'),
                      _techItem('Shared Preferences', 'Local data storage'),
                      _techItem('HTTP Package', 'API networking'),
                      _techItem('Google Gemini AI', 'AI chatbot engine'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // API & Data Sources
                _SectionCard(
                  icon: Icons.api_rounded,
                  title: 'API & Sumber Data',
                  child: Column(
                    children: [
                      _creditItem('Aladhan API', 'Jadwal shalat GPS & arah kiblat'),
                      _creditItem('Equran.id API', 'Al-Qur\'an & terjemahan'),
                      _creditItem('Doa-Doa API', 'Database doa harian'),
                      _creditItem('Hadist API', 'Hadist Arbain Nawawi'),
                      _creditItem('Google Gemini', 'AI untuk Tanya ISLAM'),
                      _creditItem('Kemenag RI', 'Metode perhitungan shalat'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // What's New
                _SectionCard(
                  icon: Icons.celebration_rounded,
                  title: 'Update Terbaru (v2.5.3)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _updateItem('✨ Redesign UI/UX dengan tema Teal modern'),
                      _updateItem('📍 GPS auto-detect untuk jadwal shalat'),
                      _updateItem('🌍 Support 30+ kota di Indonesia'),
                      _updateItem('🤖 Integrasi Google Gemini AI'),
                      _updateItem('📓 Fitur Catatan Ramadhan (Timeline)'),
                      _updateItem('🎯 Perbaikan bug & peningkatan performa'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: _kTeal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mosque_rounded,
                          color: _kTeal, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text('Dikembangkan dengan ❤️ untuk Umat Muslim',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('© 2026 Muslim App • Teal Edition',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: _kTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _kTeal.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flutter_dash,
                              color: _kTeal, size: 16),
                          const SizedBox(width: 6),
                          Text('Built with Flutter',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _kTeal,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _featureItem(
      IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(desc,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600],
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
                color: _kTeal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(desc,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditItem(String source, String purpose) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: _kTeal, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(source,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(purpose,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _updateItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                color: _kTeal,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _kTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: _kTeal, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}