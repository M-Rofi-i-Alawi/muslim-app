import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodel/shalat_viewmodel.dart';
import '../model/shalat_model.dart';
import '../repository/shalat_repository.dart';
import 'shalat_detail_page.dart'; // ✅ Import halaman detail

// ─────────────────────────────────────────────
// KONSTANTA
// ─────────────────────────────────────────────
const _kTeal     = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);
const _kGold     = Color(0xFFE8A020);
const _kBg       = Color(0xFFF2F4F7);

class ShalatPage extends StatefulWidget {
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  Timer? _timer;
  String _currentTime       = '';
  String _nextPrayerName    = '';
  int    _nextPrayerMinutes = 0;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ShalatViewModel>();
      if (vm.jadwal == null) vm.getJadwalShalatGPS();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    final h   = now.hour.toString().padLeft(2, '0');
    final m   = now.minute.toString().padLeft(2, '0');
    final s   = now.second.toString().padLeft(2, '0');
    if (mounted) setState(() => _currentTime = '$h:$m:$s');

    final vm = context.read<ShalatViewModel>();
    if (vm.jadwal != null) _calcNext(vm.jadwal!);
  }

  void _calcNext(ShalatModel jadwal) {
    final now    = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final prayers = [
      ('Subuh',   jadwal.subuh),
      ('Dzuhur',  jadwal.dzuhur),
      ('Ashar',   jadwal.ashar),
      ('Maghrib', jadwal.maghrib),
      ('Isya',    jadwal.isya),
    ];
    for (final p in prayers) {
      final parts = p.$2.split(':');
      final pMin  = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (pMin > nowMin) {
        if (mounted) setState(() {
          _nextPrayerName    = p.$1;
          _nextPrayerMinutes = pMin - nowMin;
        });
        return;
      }
    }
    // wrap ke subuh besok
    final parts = jadwal.subuh.split(':');
    final pMin  = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    if (mounted) setState(() {
      _nextPrayerName    = 'Subuh';
      _nextPrayerMinutes = (1440 - TimeOfDay.now().hour * 60 -
          TimeOfDay.now().minute) + pMin;
    });
  }

  String _formatCountdown(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0) return '$h jam $m menit lagi';
    return '$m menit lagi';
  }

  // ─── PILIH KOTA ───────────────────────────────────────────────────────────
  void _showCityPicker() {
    final cities = ShalatRepository.cityCoordinates.keys.toList()..sort();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        cities: cities,
        onGPS: () {
          Navigator.pop(context);
          context.read<ShalatViewModel>().resetToGPS();
        },
        onCity: (city) {
          Navigator.pop(context);
          context.read<ShalatViewModel>().selectCityByName(city);
        },
      ),
    );
  }

  // ─── PILIH TANGGAL ────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _kTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      context.read<ShalatViewModel>().setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<ShalatViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              // ── APP BAR ───────────────────────────────────────
              _buildAppBar(vm),

              // ── INFO MENUJU WAKTU ─────────────────────────────
              if (vm.jadwal != null && _nextPrayerName.isNotEmpty)
                SliverToBoxAdapter(child: _buildNextInfo(vm.jadwal!)),

              // ── LOADING ───────────────────────────────────────
              if (vm.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _kTeal),
                  ),
                )

              // ── ERROR ─────────────────────────────────────────
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.grey, size: 60),
                        const SizedBox(height: 12),
                        Text('Gagal memuat jadwal',
                            style: GoogleFonts.poppins(color: Colors.grey)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ShalatViewModel>().refresh(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _kTeal),
                          child: Text('Coba Lagi',
                              style: GoogleFonts.poppins(
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )

              // ── LIST JADWAL ───────────────────────────────────
              else if (vm.jadwal != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _buildPrayerCards(vm.jadwal!),
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  child: Center(
                    child: Text('Memuat...',
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(ShalatViewModel vm) {
    final jadwal   = vm.jadwal;
    final cityName = jadwal?.namaKota ?? 'Mendeteksi...';
    final tanggal  = jadwal?.tanggal  ?? '';

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: _kTealDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Jadwal Shalat',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
          onPressed: _pickDate,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kTealDark, _kTeal, Color(0xFF00C4A7)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Kota + tombol Ganti
                  GestureDetector(
                    onTap: _showCityPicker,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          cityName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ganti',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tanggal.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          tanggal,
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── INFO MENUJU WAKTU ────────────────────────────────────────────────────
  Widget _buildNextInfo(ShalatModel jadwal) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kTeal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Jam live
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTime,
                style: GoogleFonts.courierPrime(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Waktu sekarang',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),

          const Spacer(),

          Container(
            width: 1, height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),

          const SizedBox(width: 16),

          // Menuju waktu berikutnya
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Menuju $_nextPrayerName',
                style: GoogleFonts.poppins(
                  color: _kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '± ${_formatCountdown(_nextPrayerMinutes)}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── PRAYER CARDS ─────────────────────────────────────────────────────────
  List<Widget> _buildPrayerCards(ShalatModel jadwal) {
    final now    = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    // ✅ Setiap item sekarang menyimpan bgColor untuk dikirim ke ShalatDetailPage
    final prayers = [
      _PrayerItem(
        name: 'Imsak',
        time: jadwal.imsak,
        icon: Icons.nightlight_round,
        bgColor:   const Color(0xFF1A237E),
        iconColor: const Color(0xFF7986CB),
      ),
      _PrayerItem(
        name: 'Subuh',
        time: jadwal.subuh,
        icon: Icons.wb_twilight_rounded,
        bgColor:   const Color(0xFF1565C0),
        iconColor: const Color(0xFF64B5F6),
      ),
      _PrayerItem(
        name: 'Terbit',
        time: jadwal.terbit,
        icon: Icons.wb_sunny_rounded,
        bgColor:   const Color(0xFFE65100),
        iconColor: const Color(0xFFFFB74D),
      ),
      _PrayerItem(
        name: 'Dhuha',
        time: jadwal.dhuha,
        icon: Icons.light_mode_rounded,
        bgColor:   const Color(0xFFF57F17),
        iconColor: const Color(0xFFFFD54F),
      ),
      _PrayerItem(
        name: 'Dzuhur',
        time: jadwal.dzuhur,
        icon: Icons.wb_sunny_rounded,
        bgColor:   const Color(0xFFBF360C),
        iconColor: const Color(0xFFFF8A65),
      ),
      _PrayerItem(
        name: 'Ashar',
        time: jadwal.ashar,
        icon: Icons.cloud_rounded,
        bgColor:   const Color(0xFFFF8F00),
        iconColor: const Color(0xFFFFCA28),
      ),
      _PrayerItem(
        name: 'Maghrib',
        time: jadwal.maghrib,
        icon: Icons.nights_stay_rounded,
        bgColor:   const Color(0xFF4A148C),
        iconColor: const Color(0xFFCE93D8),
      ),
      _PrayerItem(
        name: 'Isya',
        time: jadwal.isya,
        icon: Icons.nightlight_round,
        bgColor:   const Color(0xFF0D47A1),
        iconColor: const Color(0xFF90CAF9),
      ),
    ];

    final widgets = <Widget>[];
    for (final p in prayers) {
      final parts  = p.time.split(':');
      final pMin   = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final isPast = pMin < nowMin;
      final isNext = p.name == _nextPrayerName;
      widgets.add(_buildPrayerCard(p, isPast, isNext));
      widgets.add(const SizedBox(height: 10));
    }
    return widgets;
  }

  Widget _buildPrayerCard(_PrayerItem p, bool isPast, bool isNext) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color:  isNext ? _kTeal.withOpacity(0.07) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(color: _kTeal, width: 1.5)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: isPast
                ? Colors.grey.withOpacity(0.1)
                : p.bgColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            p.icon,
            color: isPast ? Colors.grey[400] : p.iconColor,
            size: 26,
          ),
        ),
        title: Text(
          p.name,
          style: GoogleFonts.poppins(
            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            color: isPast
                ? Colors.grey[400]
                : isNext
                    ? _kTeal
                    : const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: isNext
            ? Text(
                'Waktu shalat berikutnya',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: _kTeal.withOpacity(0.7),
                ),
              )
            : isPast
                ? Text(
                    'Sudah lewat',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[400]),
                  )
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p.time,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPast
                    ? Colors.grey[400]
                    : isNext
                        ? _kTeal
                        : _kGold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: isPast ? Colors.grey[300] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),

        // ✅ NAVIGASI KE SHALAT DETAIL PAGE
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShalatDetailPage(
                title: p.name,     // "Dzuhur", "Subuh", dll
                time:  p.time,     // "11:54"
                color: p.bgColor,  // warna sesuai waktu shalat
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA CLASS
// ─────────────────────────────────────────────
class _PrayerItem {
  final String   name;
  final String   time;
  final IconData icon;
  final Color    bgColor;
  final Color    iconColor;

  const _PrayerItem({
    required this.name,
    required this.time,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

// ─────────────────────────────────────────────
// CITY PICKER BOTTOM SHEET
// ─────────────────────────────────────────────
class _CityPickerSheet extends StatefulWidget {
  final List<String> cities;
  final VoidCallback onGPS;
  final void Function(String city) onCity;

  const _CityPickerSheet({
    required this.cities,
    required this.onGPS,
    required this.onCity,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cities
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Pilih Lokasi',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F6F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Auto GPS
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.gps_fixed_rounded,
                  color: _kTeal, size: 22),
            ),
            title: Text('Auto GPS',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text('Deteksi otomatis dari lokasi Anda',
                style: GoogleFonts.poppins(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onGPS,
          ),

          const Divider(height: 1),

          // List kota
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final city = filtered[i];
                return ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_city_rounded,
                        color: Colors.grey, size: 20),
                  ),
                  title: Text(city,
                      style: GoogleFonts.poppins(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey, size: 18),
                  onTap: () => widget.onCity(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}