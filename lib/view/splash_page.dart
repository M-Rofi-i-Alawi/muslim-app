import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MenuPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF007A68),
              Color(0xFF00A086),
              Color(0xFF00C4A7),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Dekoratif circle atas kanan ──────────────────────
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Dekoratif circle bawah kiri ──────────────────────
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // ── Gelombang lengkung bawah ──────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomPaint(
                  size: Size(size.width, 180),
                  painter: _WavePainter(),
                ),
              ),
            ),

            // ── Konten utama ──────────────────────────────────────
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo dengan border & shadow
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 32,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Image.asset(
                            'assets/logo_muslim_app.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'logo_muslim_app.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.mosque_rounded,
                                      size: 80, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Nama app + subtitle
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Muslim App',
                            style: GoogleFonts.poppins(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Builder(
                              builder: (context) => Text(
                                context.tr('Sahabat Ibadah Anda'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Branding bawah ────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      children: [
                        // Divider tipis
                        Container(
                          width: 48, height: 1,
                          color: Colors.white.withOpacity(0.25),
                          margin: const EdgeInsets.only(bottom: 14),
                        ),
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.90),
                            fontFamily: 'serif',
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '© 2026 Muslim App',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.65),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wave Painter ─────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gelombang 1 — lebih transparan, lebih tinggi
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.55);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.28,
      size.width * 0.55, size.height * 0.72,
      size.width,        size.height * 0.42,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Gelombang 2 — lebih solid
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.09)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.72);
    path2.cubicTo(
      size.width * 0.3,  size.height * 0.50,
      size.width * 0.65, size.height * 0.88,
      size.width,        size.height * 0.62,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Gelombang 3 — paling bawah, paling solid
    final paint3 = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.85);
    path3.cubicTo(
      size.width * 0.4,  size.height * 0.68,
      size.width * 0.75, size.height * 0.96,
      size.width,        size.height * 0.80,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}