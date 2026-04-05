import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import '../viewmodel/kiblat_viewmodel.dart';

// ─────────────────────────────────────────────
// KONSTANTA — konsisten dengan seluruh app
// ─────────────────────────────────────────────
const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  double? _heading;
  // ignore: unused_field
  bool _hasPermission = false;
  // ignore: unused_field
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initCompass();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KiblatViewModel>().getCurrentLocation();
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    setState(() => _hasPermission = status.isGranted);
  }

  void _initCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      setState(() => _heading = event.heading);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<KiblatViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              // ── APP BAR ───────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: _kTealDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Arah Kiblat',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.my_location_rounded,
                        color: Colors.white),
                    onPressed: () => vm.getCurrentLocation(),
                    tooltip: 'Perbarui lokasi',
                  ),
                ],
              ),

              // ── LOADING ───────────────────────────────────────
              if (vm.isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: _kTeal),
                        const SizedBox(height: 16),
                        Text(
                          'Mendapatkan lokasi Anda...',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )

              // ── ERROR ─────────────────────────────────────────
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal mendapatkan lokasi',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vm.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => vm.getCurrentLocation(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _kTeal),
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white),
                            label: Text('Coba Lagi',
                                style: GoogleFonts.poppins(
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // ── TIDAK ADA DATA ────────────────────────────────
              else if (vm.kiblat == null)
                SliverFillRemaining(
                  child: Center(
                    child: Text('Data kiblat tidak tersedia',
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                )

              // ── KONTEN UTAMA ──────────────────────────────────
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 20, 16, 24 + bottomPadding),
                    child: Column(
                      children: [
                        // ── Info Card ──
                        _buildInfoCard(vm),

                        const SizedBox(height: 32),

                        // ── Kompas ──
                        _heading != null
                            ? _buildCompass(
                                vm.kiblat!.direction, _heading!)
                            : _buildNoCompass(),

                        const SizedBox(height: 28),

                        // ── Instruksi ──
                        _buildInstructions(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── INFO CARD ────────────────────────────────────────────────────────────
  Widget _buildInfoCard(KiblatViewModel vm) {
    final direction = vm.kiblat!.direction;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kTeal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Ka'bah
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.explore_rounded,
                color: Colors.white, size: 32),
          ),

          const SizedBox(height: 12),

          Text(
            'Arah Kiblat',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          // Derajat besar
          Text(
            '${direction.toStringAsFixed(1)}°',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),

          Text(
            'dari Utara',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          // Koordinat
          if (vm.currentPosition != null) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Lat: ${vm.currentPosition!.latitude.toStringAsFixed(4)}, '
                  'Long: ${vm.currentPosition!.longitude.toStringAsFixed(4)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── KOMPAS ───────────────────────────────────────────────────────────────
  Widget _buildCompass(double qiblaDirection, double heading) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _kTeal.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran kompas yang berputar sesuai heading
          Transform.rotate(
            angle: -(heading * (pi / 180)),
            child: SizedBox(
              width: 300, height: 300,
              child: Stack(
                children: [
                  // Penanda N (merah)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        'N',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  // Penanda S
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text('S',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500])),
                    ),
                  ),
                  // Penanda E
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Text('E',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500])),
                    ),
                  ),
                  // Penanda W
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text('W',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500])),
                    ),
                  ),
                  // Garis derajat
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: CompassPainter(tickColor: _kTeal),
                  ),
                ],
              ),
            ),
          ),

          // Panah kiblat — berputar ke arah kiblat
          Transform.rotate(
            angle: (qiblaDirection - heading) * (pi / 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Panah teal ke Ka'bah
                Icon(
                  Icons.navigation_rounded,
                  size: 72,
                  color: _kTeal,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kTeal,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kTeal.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Ka\'bah',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TIDAK ADA KOMPAS ─────────────────────────────────────────────────────
  Widget _buildNoCompass() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off_rounded,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Kompas tidak tersedia',
              style: GoogleFonts.poppins(
                  color: Colors.grey[500], fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Aktifkan sensor kompas perangkat',
              style: GoogleFonts.poppins(
                  color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─── INSTRUKSI ────────────────────────────────────────────────────────────
  Widget _buildInstructions() {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _kTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: _kTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Cara Menggunakan',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep('1', 'Letakkan ponsel pada permukaan datar'),
          _buildStep('2',
              'Putar ponsel hingga panah mengarah ke Ka\'bah'),
          _buildStep(
              '3', 'Jauhkan dari benda logam atau magnet'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: _kTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM PAINTER KOMPAS
// ─────────────────────────────────────────────
class CompassPainter extends CustomPainter {
  final Color tickColor;
  const CompassPainter({this.tickColor = const Color(0xFF00A086)});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    for (int i = 0; i < 360; i += 5) {
      final angle  = i * pi / 180;
      final isMajor = i % 30 == 0;
      final isMid   = i % 10 == 0;

      final paint = Paint()
        ..color = isMajor
            ? tickColor.withOpacity(0.6)
            : isMid
                ? Colors.grey.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2)
        ..strokeWidth = isMajor ? 2.5 : isMid ? 1.5 : 0.8;

      final tickLen = isMajor ? 14.0 : isMid ? 9.0 : 6.0;

      final startPt = Offset(
        center.dx + (radius - tickLen) * cos(angle - pi / 2),
        center.dy + (radius - tickLen) * sin(angle - pi / 2),
      );
      final endPt = Offset(
        center.dx + radius * cos(angle - pi / 2),
        center.dy + radius * sin(angle - pi / 2),
      );

      canvas.drawLine(startPt, endPt, paint);
    }
  }

  @override
  bool shouldRepaint(CompassPainter old) => old.tickColor != tickColor;
}