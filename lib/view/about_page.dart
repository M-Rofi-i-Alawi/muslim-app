// lib/view/about_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: kTealDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(l.tentangAplikasi,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            centerTitle: true,
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + bottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Deskripsi ──────────────────────────────
                _SectionCard(
                  icon: Icons.info_outline_rounded,
                  title: l.tentangAplikasi,
                  child: Text(
                    l.isEn
                        ? 'Muslim App is a worship companion app that helps Muslims carry out '
                          'daily religious activities. Equipped with accurate GPS-based prayer schedules, '
                          'a complete digital Quran, a collection of prayers and dhikr, selected hadiths, '
                          'and an AI chatbot to answer Islamic questions. Designed with a modern Teal-themed UI/UX '
                          'that is comfortable and easy to use.'
                        : 'Muslim App adalah aplikasi pendamping ibadah yang membantu umat Muslim '
                          'dalam menjalankan aktivitas keagamaan sehari-hari. Dilengkapi dengan '
                          'jadwal shalat berbasis GPS yang akurat, Al-Qur\'an digital lengkap, '
                          'kumpulan doa dan wirid, hadist pilihan, hingga fitur chatbot AI untuk '
                          'menjawab pertanyaan seputar Islam. Aplikasi ini dirancang dengan UI/UX '
                          'modern bertema Teal yang nyaman dan mudah digunakan.',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: c.textSecondary, height: 1.7),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Fitur Utama ────────────────────────────
                _SectionCard(
                  icon: Icons.auto_awesome_rounded,
                  title: l.fiturUtama,
                  child: Column(
                    children: [
                      _featureItem(c, Icons.access_time_rounded,
                          l.jadwalShalat,
                          l.isEn ? 'Accurate prayer times with GPS auto-detect, supports 30+ cities'
                                  : 'Waktu shalat akurat dengan GPS auto-detect, support 30+ kota',
                          kTeal),
                      _featureItem(c, Icons.auto_stories_rounded,
                          l.alQuran,
                          l.isEn ? '114 complete surahs with Indonesian translation & audio'
                                  : '114 Surat lengkap dengan terjemahan Indonesia & audio',
                          const Color(0xFF1565C0)),
                      _featureItem(c, Icons.favorite_rounded,
                          l.doaHarian,
                          l.isEn ? 'Collection of prayers with Arabic, Latin, and translation'
                                  : 'Kumpulan doa dengan teks Arab, Latin, dan terjemahan',
                          const Color(0xFFE8650A)),
                      _featureItem(c, Icons.book_rounded,
                          l.hadist,
                          l.isEn ? 'Hadith Arbain Nawawi and other selected hadiths'
                                  : 'Hadist Arbain Nawawi dan hadist pilihan lainnya',
                          const Color(0xFF795548)),
                      _featureItem(c, Icons.explore_rounded,
                          l.arahKiblat,
                          l.isEn ? 'Digital GPS compass to determine accurate qibla direction'
                                  : 'Kompas digital GPS untuk menentukan arah kiblat akurat',
                          const Color(0xFF7B1FA2)),
                      _featureItem(c, Icons.track_changes_rounded,
                          l.tasbihDigital,
                          l.isEn ? 'Digital dhikr counter with target & history'
                                  : 'Counter dzikir digital dengan target & histori',
                          const Color(0xFF388E3C)),
                      _featureItem(c, Icons.volunteer_activism_rounded,
                          l.dzikirHarian,
                          l.isEn ? 'Morning & evening dhikr guide with count'
                                  : 'Panduan dzikir pagi & petang dengan hitungan',
                          const Color(0xFF00897B)),
                      _featureItem(c, Icons.star_rounded,
                          l.asmaulHusna,
                          l.isEn ? '99 Names of Allah with Latin, Arabic, and meaning'
                                  : '99 Nama Allah dengan Latin, Arab, dan artinya',
                          kGold),
                      _featureItem(c, Icons.account_balance_wallet_rounded,
                          l.kalkulatorZakat,
                          l.isEn ? 'Calculate maal, income, fitrah & professional zakat'
                                  : 'Hitung zakat maal, penghasilan, fitrah & profesi',
                          const Color(0xFF00838F)),
                      _featureItem(c, Icons.calendar_today_rounded,
                          l.kalenderHijri,
                          l.isEn ? 'Islamic calendar with Gregorian date conversion'
                                  : 'Kalender Islam dengan konversi tanggal Masehi',
                          const Color(0xFF5E35B1)),
                      _featureItem(c, Icons.checklist_rounded,
                          l.panduanIbadah,
                          l.isEn ? 'Tutorial for prayer, wudhu, tayammum & other worship'
                                  : 'Tutorial shalat, wudhu, tayamum & ibadah lainnya',
                          const Color(0xFF6A1B9A)),
                      _featureItem(c, Icons.nightlight_round,
                          l.catatanRamadhan,
                          l.isEn ? 'Daily worship journal: fasting, recitation, charity, tarawih'
                                  : 'Jurnal ibadah harian: puasa, tadarus, sedekah, tarawih',
                          const Color(0xFFC62828)),
                      _featureItem(c, Icons.chat_bubble_outline_rounded,
                          l.tanyaIslam,
                          l.isEn ? 'AI chatbot to answer Islamic questions'
                                  : 'AI chatbot untuk menjawab pertanyaan keislaman',
                          kTeal),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Teknologi ──────────────────────────────
                _SectionCard(
                  icon: Icons.code_rounded,
                  title: l.teknologi,
                  child: Column(
                    children: [
                      _techItem(c, 'Flutter 3.x', 'Cross-platform framework'),
                      _techItem(c, 'Provider', 'State management pattern'),
                      _techItem(c, 'Google Fonts', 'Typography — Poppins'),
                      _techItem(c, 'Geolocator', 'GPS & location services'),
                      _techItem(c, 'Flutter Compass', 'Compass sensor access'),
                      _techItem(c, 'Shared Preferences', 'Local data storage'),
                      _techItem(c, 'HTTP Package', 'API networking'),
                      _techItem(c, 'Google Gemini AI', 'AI chatbot engine'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── API & Data ─────────────────────────────
                _SectionCard(
                  icon: Icons.api_rounded,
                  title: l.apiSumberData,
                  child: Column(
                    children: [
                      _creditItem(c, 'Aladhan API',
                          l.isEn ? 'Prayer schedule GPS & qibla direction' : 'Jadwal shalat GPS & arah kiblat'),
                      _creditItem(c, 'Equran.id API',
                          l.isEn ? "Al-Qur'an & translation" : "Al-Qur'an & terjemahan"),
                      _creditItem(c, 'Doa-Doa API',
                          l.isEn ? 'Daily prayer database' : 'Database doa harian'),
                      _creditItem(c, 'Hadist API',
                          l.isEn ? 'Hadith Arbain Nawawi' : 'Hadist Arbain Nawawi'),
                      _creditItem(c, 'Google Gemini',
                          l.isEn ? 'AI for Ask ISLAM' : 'AI untuk Tanya ISLAM'),
                      _creditItem(c, 'Kemenag RI',
                          l.isEn ? 'Prayer time calculation method' : 'Metode perhitungan shalat'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Update ─────────────────────────────────
                _SectionCard(
                  icon: Icons.celebration_rounded,
                  title: l.updateTerbaru,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _updateItem(c, l.isEn ? '✨ UI/UX redesign with modern Teal theme'      : '✨ Redesign UI/UX dengan tema Teal modern'),
                      _updateItem(c, l.isEn ? '📍 GPS auto-detect for prayer schedule'        : '📍 GPS auto-detect untuk jadwal shalat'),
                      _updateItem(c, l.isEn ? '🌍 Support 30+ cities in Indonesia'            : '🌍 Support 30+ kota di Indonesia'),
                      _updateItem(c, l.isEn ? '🤖 Google Gemini AI integration'               : '🤖 Integrasi Google Gemini AI'),
                      _updateItem(c, l.isEn ? '📓 Ramadan Notes feature (Timeline)'           : '📓 Fitur Catatan Ramadhan (Timeline)'),
                      _updateItem(c, l.isEn ? '🎯 Bug fixes & performance improvements'       : '🎯 Perbaikan bug & peningkatan performa'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Footer ─────────────────────────────────
                Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mosque_rounded, color: kTeal, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(l.dikembangkanDengan,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: c.textSecondary)),
                    const SizedBox(height: 4),
                    Text(l.copyright,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: c.textHint)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: kTeal.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flutter_dash, color: kTeal, size: 16),
                          const SizedBox(width: 6),
                          Text(l.builtWithFlutter,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: kTeal,
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

  Widget _featureItem(AppColors c, IconData icon, String title, String desc, Color color) {
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.onSurface)),
                const SizedBox(height: 2),
                Text(desc,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: c.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techItem(AppColors c, String name, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(color: kTeal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.onSurface)),
                Text(desc,
                    style: GoogleFonts.poppins(fontSize: 11, color: c.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditItem(AppColors c, String source, String purpose) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: kTeal, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(source,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.onSurface)),
                Text(purpose,
                    style: GoogleFonts.poppins(fontSize: 11, color: c.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _updateItem(AppColors c, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(color: kTeal, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: c.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION CARD ─────────────────────────────────────────────────────────────
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
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.isDark ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
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
                  color: kTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: kTeal, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: c.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
