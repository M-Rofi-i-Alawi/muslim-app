import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import '../viewmodel/shalat_viewmodel.dart';
import '../model/shalat_model.dart';
import '../utils/theme_helper.dart';
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

const _kTeal = Color(0xFF00A086);
const _kTealLight = Color(0xFF00C4A7);
const _kTealDark = Color(0xFF007A68);
const _kGold = Color(0xFFE8B84B);

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Timer? _timer;
  Duration _countdown = Duration.zero;
  String _nextPrayerName = '';
  String _nextPrayerTime = '';

  String _getZona(String kota) {
    if (['Jayapura', 'Sorong'].contains(kota)) return 'WIT';
    if (['Makassar', 'Kendari', 'Palu', 'Gorontalo', 'Denpasar', 'Mataram']
        .contains(kota)) return 'WITA';
    return 'WIB';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShalatViewModel>().initWithSavedCity();
    });
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
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
    final now = DateTime.now();
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;

    // ✅ FIX: jadwal.subuh bukan jadwal.context.tr('Subuh')
    //    jadwal.xxx = waktu shalat (String jam:menit), bukan terjemahan
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
      final pSec = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60;
      if (pSec > nowSec) {
        next = p;
        break;
      }
    }
    next ??= prayers.first;

    final parts = next['time']!.split(':');
    final pSec = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60;
    var diffSec = pSec - nowSec;
    if (diffSec < 0) diffSec += 86400;

    if (mounted) {
      setState(() {
        _nextPrayerName = next!['name']!;
        _nextPrayerTime = next['time']!;
        _countdown = Duration(seconds: diffSec);
      });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _countdownStr {
    final h = _countdown.inHours;
    final m = _countdown.inMinutes.remainder(60);
    final s = _countdown.inSeconds.remainder(60);
    return '${_pad(h)}:${_pad(m)}:${_pad(s)}';
  }

  // ✅ FIX: context.tr() bukan jadwal.context.tr()
  String _translatePrayer(String name) {
    switch (name) {
      case 'Subuh':   return context.tr('Subuh');
      case 'Dzuhur':  return context.tr('Dzuhur');
      case 'Ashar':   return context.tr('Ashar');
      case 'Maghrib': return context.tr('Maghrib');
      case 'Isya':    return context.tr('Isya');
      default:        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final mainItems = <_MenuItemData>[
      _MenuItemData(Icons.access_time_rounded, 'Jadwal\nShalat',
          const Color(0xFF00897B), () => _push(context, const ShalatPage())),
      _MenuItemData(Icons.menu_book_rounded, 'Wirid\n& Doa',
          const Color(0xFFE67E22), () => _push(context, const DoaListPage())),
      _MenuItemData(Icons.auto_stories_rounded, "Al-\nQur'an",
          const Color(0xFF1976D2), () => _push(context, const SuratListPage())),
      _MenuItemData(Icons.explore_rounded, 'Arah\nKiblat',
          const Color(0xFF7B1FA2), () => _push(context, const KiblatPage())),
      _MenuItemData(Icons.track_changes_rounded, 'Tasbih\nDigital',
          const Color(0xFF388E3C), () => _push(context, const TasbihPage())),
      _MenuItemData(Icons.volunteer_activism_rounded, 'Dzikir\nHarian',
          const Color(0xFF00796B), () => _push(context, const DzikirPage())),
      _MenuItemData(Icons.checklist_rounded, 'Panduan\nIbadah',
          const Color(0xFF6A1B9A),
          () => _push(context, const PanduanIbadahPage())),
      _MenuItemData(Icons.history_edu_rounded, 'Hadist',
          const Color(0xFF5D4037), () => _push(context, const HadistPage())),
      _MenuItemData(Icons.auto_awesome_rounded, 'Asmaul\nHusna',
          const Color(0xFFF9A825),
          () => _push(context, const AsmaulHusnaPage())),
      _MenuItemData(Icons.calculate_rounded, 'Zakat',
          const Color(0xFF00838F), () => _push(context, const ZakatPage())),
      _MenuItemData(Icons.calendar_month_rounded, 'Kalender\nHijri',
          const Color(0xFF1565C0),
          () => _push(context, const HijriCalendarPage())),
      _MenuItemData(Icons.question_answer_rounded, 'Tanya\nISLAM',
          const Color(0xFF00897B), () => _push(context, const ChatPage())),
    ];

    final lastItems = <_MenuItemData>[
      _MenuItemData(Icons.nightlight_round, 'Ramadhan',
          const Color(0xFFC62828),
          () => _push(context, const RamadhanPage())),
      _MenuItemData(Icons.info_outline_rounded, 'Tentang Aplikasi',
          const Color(0xFF546E7A), () => _push(context, const AboutPage())),
      _MenuItemData(Icons.settings_rounded, 'Pengaturan',
          const Color(0xFF37474F), () => _push(context, const SettingsPage())),
    ];

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildListDelegate(
                mainItems
                    .map((d) => _MenuItem(
                          icon: d.icon,
                          label: d.label,
                          color: d.color,
                          onTap: d.onTap,
                        ))
                    .toList(),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemW = (constraints.maxWidth - 24) / 4;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: lastItems
                        .map((d) => SizedBox(
                              width: itemW,
                              child: _MenuItem(
                                icon: d.icon,
                                label: d.label,
                                color: d.color,
                                onTap: d.onTap,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Translate structured tanggal "DayName|day|MonthName|year"
  String _formatTanggal(String tanggal) {
    final parts = tanggal.split('|');
    if (parts.length == 4) {
      final day   = context.tr(parts[0]); // Senin → Monday
      final date  = parts[1];
      final month = context.tr(parts[2]); // Mei → May
      final year  = parts[3];
      if (context.isEn) {
        return '$day, $month $date, $year';
      }
      return '$day, $date $month $year';
    }
    return tanggal; // fallback for old format
  }

  Widget _buildHeroHeader() {
    return Consumer<ShalatViewModel>(
      builder: (context, vm, _) {
        final c = context.colors;
        final cityName = vm.jadwal?.namaKota ??
            context.tr('Mendeteksi...');
        final tanggal = vm.jadwal?.tanggal ?? '';
        final zona = _getZona(cityName);
        final nextName = _translatePrayer(_nextPrayerName);

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                  child: Row(children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white60, size: 15),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(cityName,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    InkWell(
                      onTap: () => _push(context, const ShalatPage()),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(context.tr('Ganti'),
                            style: GoogleFonts.poppins(
                                color: _kGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: vm.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : _nextPrayerName.isNotEmpty
                          ? Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(
                                        color: _kGold,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${context.tr('Menuju')} $nextName · $_nextPrayerTime $zona',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(_countdownStr,
                                  style: GoogleFonts.courierPrime(
                                      color: Colors.white,
                                      fontSize: 44,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3)),
                            ])
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                  context.tr('Memuat jadwal...'),
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 14)),
                            ),
                ),

                if (tanggal.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white38, size: 11),
                        const SizedBox(width: 4),
                        Text(_formatTanggal(tanggal),
                            style: GoogleFonts.poppins(
                                color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),

                if (vm.jadwal != null) _buildPrayerRow(vm.jadwal!),
                _buildCurvedBottom(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ FIX: p.$2 = waktu jam:menit dari jadwal.xxx, p.$3 = nama terjemahan
  Widget _buildPrayerRow(ShalatModel jadwal) {
    final prayers = [
      ('Subuh',   jadwal.subuh,   context.tr('Subuh')),
      ('Dzuhur',  jadwal.dzuhur,  context.tr('Dzuhur')),
      ('Ashar',   jadwal.ashar,   context.tr('Ashar')),
      ('Maghrib', jadwal.maghrib, context.tr('Maghrib')),
      ('Isya',    jadwal.isya,    context.tr('Isya')),
    ];

    final now = DateTime.now();
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
          final parts = p.$2.split(':');
          final pMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          final isPast = pMin < nowMin;
          final isNext = _nextPrayerName == p.$1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.$3,
                  style: GoogleFonts.poppins(
                      color: isNext
                          ? _kGold
                          : isPast
                              ? Colors.white38
                              : Colors.white70,
                      fontSize: 11,
                      fontWeight:
                          isNext ? FontWeight.bold : FontWeight.normal)),
              const SizedBox(height: 3),
              Text(p.$2,
                  style: GoogleFonts.poppins(
                      color: isNext
                          ? Colors.white
                          : isPast
                              ? Colors.white38
                              : Colors.white,
                      fontSize: 13,
                      fontWeight:
                          isNext ? FontWeight.bold : FontWeight.w500)),
              if (isNext)
                Container(
                  margin: const EdgeInsets.only(top: 4),
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

  Widget _buildCurvedBottom(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 28,
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItemData(this.icon, this.label, this.color, this.onTap);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withOpacity(0.25), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            TrText(
              label.replaceAll('\n', ' '),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}