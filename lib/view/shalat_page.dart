import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import '../services/settings_service.dart';
import '../utils/theme_helper.dart';
import '../viewmodel/shalat_viewmodel.dart';
import '../model/shalat_model.dart';
import '../repository/shalat_repository.dart';
import 'shalat_detail_page.dart';

const _kTeal     = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);
const _kGold     = Color(0xFFE8A020);

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
      if (vm.jadwal == null) vm.initWithSavedCity();
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _tick() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    if (mounted) setState(() => _currentTime = '$h:$m:$s');
    final vm = context.read<ShalatViewModel>();
    if (vm.jadwal != null) _calcNext(vm.jadwal!);
  }

  void _calcNext(ShalatModel jadwal) {
    final now    = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final prayers = [
      ('Subuh',   jadwal.subuh),  ('Dzuhur', jadwal.dzuhur),
      ('Ashar',   jadwal.ashar),  ('Maghrib', jadwal.maghrib),
      ('Isya',    jadwal.isya),
    ];
    for (final p in prayers) {
      final parts = p.$2.split(':');
      final pMin  = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (pMin > nowMin) {
        if (mounted) setState(() { _nextPrayerName = p.$1; _nextPrayerMinutes = pMin - nowMin; });
        return;
      }
    }
    final parts = jadwal.subuh.split(':');
    final pMin  = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    if (mounted) setState(() {
      _nextPrayerName = 'Subuh';
      _nextPrayerMinutes = (1440 - TimeOfDay.now().hour * 60 - TimeOfDay.now().minute) + pMin;
    });
  }

  String _formatCountdown(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final jam = TrService().translate('jam', context.read<SettingsService>().language);
    final menit = TrService().translate('menit', context.read<SettingsService>().language);
    return h > 0 ? '$h $jam $m $menit' : '$m $menit';
  }

  void _showCityPicker() {
    final cities = ShalatRepository.cityCoordinates.keys.toList()..sort();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        cities: cities,
        onGPS: () { Navigator.pop(context); context.read<ShalatViewModel>().resetToGPS(); },
        onCity: (city) { Navigator.pop(context); context.read<ShalatViewModel>().selectCityByName(city); },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kTeal)),
        child: child!,
      ),
    );
    if (picked != null && mounted) context.read<ShalatViewModel>().setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: Consumer<ShalatViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(vm),

              if (vm.isLoading)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: _kTeal)))
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: c.textHint, size: 60),
                    const SizedBox(height: 12),
                    TrText('Gagal memuat jadwal',
                        style: GoogleFonts.poppins(color: c.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ShalatViewModel>().refresh(),
                      style: ElevatedButton.styleFrom(backgroundColor: _kTeal),
                      child: TrText('Coba Lagi',
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ],
                )))
              else if (vm.jadwal != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_nextPrayerName.isNotEmpty)
                        _buildCountdownCard(context, vm.jadwal!),
                      const SizedBox(height: 8),
                      ..._buildPrayerCards(context, vm.jadwal!),
                    ]),
                  ),
                )
              else
                SliverFillRemaining(child: Center(
                  child: TrText('Memuat...',
                      style: GoogleFonts.poppins(color: c.textSecondary)))),
            ],
          );
        },
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  // FIX: leading, title, actions dipindah ke property SliverAppBar langsung
  // sehingga title "Jadwal Shalat" hanya muncul saat collapsed (otomatis),
  // dan jam di background tidak akan pernah overlap dengan judul.
  Widget _buildAppBar(ShalatViewModel vm) {
    final jadwal   = vm.jadwal;
    final cityName = jadwal?.namaKota ?? context.tr('Mendeteksi...');
    final tanggal  = jadwal?.tanggal  ?? '';

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _kTealDark,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: TrText(
        'Jadwal Shalat',
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onPressed: _pickDate),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // titlePadding: EdgeInsets.zero menonaktifkan title bawaan FlexibleSpaceBar
        // agar tidak double render dengan title di SliverAppBar
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.pin,
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
              // top 56: beri ruang untuk area toolbar (back button, dll)
              // sehingga jam tidak ketutup saat expanded
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentTime,
                      style: GoogleFonts.courierPrime(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _showCityPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white70, size: 15),
                            const SizedBox(width: 4),
                            Text(cityName,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: _kGold,
                                  borderRadius: BorderRadius.circular(12)),
                              child: TrText('Ganti',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ),
                      ),
                      if (tanggal.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: Colors.white60, size: 12),
                          const SizedBox(width: 4),
                          Text(tanggal,
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, fontSize: 11)),
                        ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── COUNTDOWN CARD ───────────────────────────────────────────────────────
  Widget _buildCountdownCard(BuildContext context, ShalatModel jadwal) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGold.withOpacity(0.15), _kGold.withOpacity(0.05)],
        ),
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGold.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: c.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _kGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: _kGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText('Shalat Berikutnya',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _kGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(context.tr(_nextPrayerName),
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: c.onSurface)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kGold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(_formatCountdown(_nextPrayerMinutes),
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                TrText('lagi',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PRAYER CARDS ─────────────────────────────────────────────────────────
  List<Widget> _buildPrayerCards(BuildContext context, ShalatModel jadwal) {
    final now    = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final prayers = [
      _PrayerItem('Imsak',   jadwal.imsak,   Icons.nightlight_round,    const Color(0xFF3949AB), const Color(0xFF9FA8DA)),
      _PrayerItem('Subuh',   jadwal.subuh,   Icons.wb_twilight_rounded,  const Color(0xFF1565C0), const Color(0xFF64B5F6)),
      _PrayerItem('Terbit',  jadwal.terbit,  Icons.wb_sunny_rounded,     const Color(0xFFE65100), const Color(0xFFFFB74D)),
      _PrayerItem('Dhuha',   jadwal.dhuha,   Icons.light_mode_rounded,   const Color(0xFFF57F17), const Color(0xFFFFD54F)),
      _PrayerItem('Dzuhur',  jadwal.dzuhur,  Icons.wb_sunny_rounded,     const Color(0xFFBF360C), const Color(0xFFFF8A65)),
      _PrayerItem('Ashar',   jadwal.ashar,   Icons.cloud_rounded,        const Color(0xFFFF8F00), const Color(0xFFFFCA28)),
      _PrayerItem('Maghrib', jadwal.maghrib, Icons.nights_stay_rounded,  const Color(0xFF6A1B9A), const Color(0xFFCE93D8)),
      _PrayerItem('Isya',    jadwal.isya,    Icons.nightlight_round,     const Color(0xFF0D47A1), const Color(0xFF90CAF9)),
    ];

    final widgets = <Widget>[];
    for (final p in prayers) {
      final parts  = p.time.split(':');
      final pMin   = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final isPast = pMin < nowMin;
      final isNext = p.name == _nextPrayerName;
      widgets.add(_buildPrayerCard(context, p, isPast, isNext));
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }

  Widget _buildPrayerCard(
      BuildContext context, _PrayerItem p, bool isPast, bool isNext) {
    final c = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isNext
            ? (c.isDark
                ? _kTeal.withOpacity(0.12)
                : _kTeal.withOpacity(0.06))
            : c.surface,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(color: _kTeal, width: 1.5)
            : Border.all(color: c.divider, width: 1),
        boxShadow: isNext
            ? [BoxShadow(color: _kTeal.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: c.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ShalatDetailPage(
                      title: p.name, time: p.time, color: p.bgColor))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isPast
                        ? c.surfaceVariant
                        : p.bgColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    p.icon,
                    color: isPast ? c.textHint : p.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(p.name),
                          style: GoogleFonts.poppins(
                              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                              color: isPast
                                  ? c.textHint
                                  : isNext
                                      ? _kTeal
                                      : c.onSurface)),
                      const SizedBox(height: 2),
                      if (isNext)
                        Row(children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                                color: _kTeal, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          TrText('Shalat Berikutnya',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: _kTeal,
                                  fontWeight: FontWeight.w500)),
                        ])
                      else if (isPast)
                        TrText('Sudah lewat',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: c.textHint))
                      else
                        TrText('Belum tiba',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: c.textSecondary)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(p.time,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isPast
                                ? c.textHint
                                : isNext
                                    ? _kTeal
                                    : c.onSurface)),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded,
                        color: isPast ? c.textHint : c.textSecondary,
                        size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── HELPER CLASSES ───────────────────────────────────────────────────────────

class _PrayerItem {
  final String name, time;
  final IconData icon;
  final Color bgColor, iconColor;
  const _PrayerItem(this.name, this.time, this.icon, this.bgColor, this.iconColor);
}

class _CityPickerSheet extends StatefulWidget {
  final List<String>          cities;
  final VoidCallback          onGPS;
  final void Function(String) onCity;
  const _CityPickerSheet(
      {required this.cities, required this.onGPS, required this.onCity});
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
    final c = context.colors;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: c.divider, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: TrText('Pilih Lokasi',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: c.onSurface)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: c.onSurface),
            decoration: InputDecoration(
              hintText: context.tr('Cari kota...'),
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: c.textHint),
              prefixIcon: Icon(Icons.search_rounded, color: c.textHint),
              filled: true,
              fillColor: c.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        ListTile(
          leading: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.gps_fixed_rounded, color: _kTeal, size: 22),
          ),
          title: TrText('Auto GPS',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: c.onSurface)),
          subtitle: TrText('Deteksi otomatis dari lokasi Anda',
              style: GoogleFonts.poppins(fontSize: 12, color: c.textSecondary)),
          trailing: Icon(Icons.chevron_right_rounded, color: c.textHint),
          onTap: widget.onGPS,
        ),
        Divider(height: 1, color: c.divider),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final city = filtered[i];
              return ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: c.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.location_city_rounded,
                      color: c.textHint, size: 20),
                ),
                title: Text(city,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: c.onSurface)),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: c.textHint, size: 18),
                onTap: () => widget.onCity(city),
              );
            },
          ),
        ),
      ]),
    );
  }
}