import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodel/shalat_viewmodel.dart';
import '../model/shalat_model.dart';
import 'surat_list_page.dart';
import 'doa_list_page.dart';
import 'shalat_page.dart';
import 'about_page.dart';
import 'kiblat_page.dart';
import 'chat_page.dart';
import 'hadist_page.dart';
import 'asmaul_husna_page.dart';
import 'dzikir_page.dart';
import 'tasbih_page.dart';
import 'zakat_page.dart';
import 'kalender_page.dart';
import 'panduan_ibadah_page.dart';
import 'ramadhan_page.dart';
import 'settings_page.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealLight = Color(0xFF00C4A7);
const _kTealDark  = Color(0xFF007A68);
const _kGold      = Color(0xFFE8B84B);
const _kBg        = Color(0xFFF4F6F9);

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Timer?    _timer;
  Duration  _countdown       = Duration.zero;
  String    _nextPrayerName  = '';
  String    _nextPrayerTime  = '';

  int _getOffset(String kota) {
    if (['Jayapura', 'Sorong'].contains(kota)) return 9;
    if (['Makassar', 'Kendari', 'Palu', 'Gorontalo',
         'Denpasar', 'Mataram'].contains(kota)) return 8;
    return 7;
  }

  String _getZona(String kota) {
    if (['Jayapura', 'Sorong'].contains(kota)) return 'WIT';
    if (['Makassar', 'Kendari', 'Palu', 'Gorontalo',
         'Denpasar', 'Mataram'].contains(kota)) return 'WITA';
    return 'WIB';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShalatViewModel>().initWithSavedCity();
    });
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final vm = context.read<ShalatViewModel>();
    if (vm.jadwal == null) return;

    final jadwal = vm.jadwal!;
    final now    = DateTime.now();
    // FIX: hitung dalam total detik, bukan menit + detik terpisah
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;

    final prayers = [
      {'name': 'Subuh',   'time': jadwal.subuh},
      {'name': 'Dzuhur',  'time': jadwal.dzuhur},
      {'name': 'Ashar',   'time': jadwal.ashar},
      {'name': 'Maghrib', 'time': jadwal.maghrib},
      {'name': 'Isya',    'time': jadwal.isya},
    ];

    Map<String, String>? next;
    for (final p in prayers) {
      final parts = p['time']!.split(':');
      final pSec  = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60;
      if (pSec > nowSec) { next = p; break; }
    }
    next ??= prayers.first;

    final parts   = next['time']!.split(':');
    final pSec    = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60;
    var   diffSec = pSec - nowSec;
    if (diffSec < 0) diffSec += 86400; // wrap ke hari berikutnya

    if (mounted) {
      setState(() {
        _nextPrayerName = next!['name']!;
        _nextPrayerTime = next['time']!;
        _countdown      = Duration(seconds: diffSec);
      });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _countdownStr {
    final h = _countdown.inHours;
    final m = _countdown.inMinutes.remainder(60);
    final s = _countdown.inSeconds.remainder(60);
    return '${_pad(h)} : ${_pad(m)} : ${_pad(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? const Color(0xFF121212) : _kBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildListDelegate(_buildMenuItems(context)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO HEADER ──────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Consumer<ShalatViewModel>(
      builder: (context, vm, _) {
        final cityName = vm.jadwal?.namaKota ?? 'Mendeteksi lokasi...';
        final tanggal  = vm.jadwal?.tanggal  ?? '';
        final zona     = _getZona(cityName);
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? const Color(0xFF121212) : _kBg;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [_kTealDark, _kTeal, _kTealLight],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Lokasi + tombol Ganti
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cityName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // FIX: ganti GestureDetector → InkWell + padding besar
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShalatPage()),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Text(
                            'Ganti',
                            style: GoogleFonts.poppins(
                              color: _kGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Countdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Column(
                    children: [
                      if (vm.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        )
                      else if (_nextPrayerName.isNotEmpty) ...[
                        Text(
                          '$_nextPrayerName · $_nextPrayerTime $zona',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '- $_countdownStr',
                            style: GoogleFonts.courierPrime(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          'Memuat jadwal shalat...',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 15),
                        ),
                    ],
                  ),
                ),

                // Tanggal
                if (tanggal.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      tanggal,
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),

                // Row 5 waktu shalat
                if (vm.jadwal != null) _buildPrayerRow(vm.jadwal!),

                // Lengkung bawah
                _buildCurvedBottom(bgColor),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── ROW 5 WAKTU SHALAT ───────────────────────────────────────────────────
  Widget _buildPrayerRow(ShalatModel jadwal) {
    final prayers = [
      ('Subuh',   jadwal.subuh),
      ('Dzuhur',  jadwal.dzuhur),
      ('Ashar',   jadwal.ashar),
      ('Maghrib', jadwal.maghrib),
      ('Isya',    jadwal.isya),
    ];
    final offset = _getOffset(jadwal.namaKota);
    final now    = DateTime.now().toUtc().add(Duration(hours: offset));
    final nowMin = now.hour * 60 + now.minute;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: prayers.map((p) {
          final parts  = p.$2.split(':');
          final pMin   = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          final isPast = pMin < nowMin;
          final isNext = _nextPrayerName == p.$1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.$1,
                  style: GoogleFonts.poppins(
                    color: isNext ? _kGold
                        : isPast ? Colors.white38
                        : Colors.white70,
                    // FIX: naikkan 10 → 12
                    fontSize: 12,
                    fontWeight: isNext
                        ? FontWeight.bold
                        : FontWeight.normal,
                  )),
              const SizedBox(height: 2),
              Text(p.$2,
                  style: GoogleFonts.poppins(
                    color: isNext ? Colors.white
                        : isPast ? Colors.white38
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: isNext
                        ? FontWeight.bold
                        : FontWeight.w500,
                  )),
              if (isNext)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: _kGold, shape: BoxShape.circle),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurvedBottom(Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 28,
      decoration: BoxDecoration(
        // FIX: pakai bgColor dinamis untuk dark/light mode
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  // ─── MENU ITEMS ───────────────────────────────────────────────────────────
  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _MenuItem(
        icon: Icons.access_time_rounded, label: 'Jadwal\nShalat',
        color: const Color(0xFF00897B),
        onTap: () => _push(context, const ShalatPage()),
      ),
      _MenuItem(
        icon: Icons.menu_book_rounded, label: 'Wirid\n& Doa',
        color: const Color(0xFFE67E22),
        onTap: () => _push(context, const DoaListPage()),
      ),
      _MenuItem(
        icon: Icons.auto_stories_rounded, label: 'Al-\nQur\'an',
        color: const Color(0xFF1976D2),
        onTap: () => _push(context, const SuratListPage()),
      ),
      _MenuItem(
        icon: Icons.explore_rounded, label: 'Arah\nKiblat',
        color: const Color(0xFF7B1FA2),
        onTap: () => _push(context, const KiblatPage()),
      ),
      _MenuItem(
        icon: Icons.track_changes_rounded, label: 'Tasbih\nDigital',
        color: const Color(0xFF388E3C),
        onTap: () => _push(context, const TasbihPage()),
      ),
      _MenuItem(
        icon: Icons.volunteer_activism_rounded, label: 'Dzikir\nHarian',
        color: const Color(0xFF00796B),
        onTap: () => _push(context, const DzikirPage()),
      ),
      _MenuItem(
        icon: Icons.checklist_rounded, label: 'Panduan\nIbadah',
        color: const Color(0xFF6A1B9A),
        onTap: () => _push(context, const PanduanIbadahPage()),
      ),
      _MenuItem(
        icon: Icons.history_edu_rounded, label: 'Hadist',
        color: const Color(0xFF5D4037),
        onTap: () => _push(context, const HadistPage()),
      ),
      _MenuItem(
        icon: Icons.auto_awesome_rounded, label: 'Asmaul\nHusna',
        color: const Color(0xFFF9A825),
        onTap: () => _push(context, const AsmaulHusnaPage()),
      ),
      // FIX: ganti ikon duplikat volunteer_activism → calculate untuk Zakat
      _MenuItem(
        icon: Icons.calculate_rounded, label: 'Zakat',
        color: const Color(0xFF00838F),
        onTap: () => _push(context, const ZakatPage()),
      ),
      _MenuItem(
        icon: Icons.calendar_month_rounded, label: 'Kalender\nHijri',
        color: const Color(0xFF1565C0),
        onTap: () => _push(context, const HijriCalendarPage()),
      ),
      _MenuItem(
        icon: Icons.question_answer_rounded, label: 'Tanya\nISLAM',
        color: const Color(0xFF00897B),
        onTap: () => _push(context, const ChatPage()),
      ),
      _MenuItem(
        icon: Icons.nightlight_round, label: 'Ramadhan',
        color: const Color(0xFFC62828),
        onTap: () => _push(context, const RamadhanPage()),
      ),
      _MenuItem(
        icon: Icons.info_outline_rounded, label: 'Tentang',
        color: const Color(0xFF546E7A),
        onTap: () => _push(context, const AboutPage()),
      ),
      _MenuItem(
        icon: Icons.settings_rounded, label: 'Pengaturan',
        color: const Color(0xFF37474F),
        onTap: () => _push(context, const SettingsPage()),
      ),
    ];
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

// ─────────────────────────────────────────────
// MENU ITEM WIDGET
// ─────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: ambil warna label dari theme agar kompatibel dark/light mode
    final labelColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      // FIX: ganti GestureDetector → InkWell untuk ripple effect Material
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.25), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // FIX: naikkan 11 → 13
                fontSize: 13,
                fontWeight: FontWeight.w600,
                // FIX: ganti hardcoded #2C3E50 → theme-aware
                color: labelColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}