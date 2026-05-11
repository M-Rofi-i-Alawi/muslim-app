import 'package:flutter/material.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
// shalat_detail_page: background adalah gradient dari warna shalat
// tidak butuh dark mode adaptive — selalu dark/colorful background
class ShalatDetailPage extends StatelessWidget {
  final String title;
  final String time;
  final Color  color;

  const ShalatDetailPage({
    super.key,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('${context.tr('Waktu')} $title', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withOpacity(0.8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getPrayerIcon(title), size: 80, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(time,
                    style: GoogleFonts.poppins(
                        fontSize: 48, fontWeight: FontWeight.bold,
                        color: Colors.white, letterSpacing: 2)),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_getPrayerInfo(context, title),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String title) {
    switch (title.toLowerCase()) {
      case 'imsak':                     return Icons.nightlight_round;
      case 'subuh':                     return Icons.wb_twilight;
      case 'terbit': case 'dhuha':      return Icons.wb_sunny;
      case 'dzuhur':                    return Icons.wb_sunny_outlined;
      case 'ashar':                     return Icons.wb_cloudy;
      case 'maghrib':                   return Icons.nights_stay;
      case 'isya':                      return Icons.nightlight;
      default:                          return Icons.access_time;
    }
  }

  String _getPrayerInfo(BuildContext context, String title) {
    switch (title.toLowerCase()) {
      case 'imsak':   return context.tr('Waktu untuk memulai puasa dan berhenti makan sahur');
      case 'subuh':   return context.tr('Waktu shalat di awal pagi sebelum matahari terbit');
      case 'terbit':  return context.tr('Waktu matahari mulai terbit');
      case 'dhuha':   return context.tr('Waktu shalat sunnah setelah matahari terbit');
      case 'dzuhur':  return context.tr('Waktu shalat di tengah hari setelah matahari condong');
      case 'ashar':   return context.tr('Waktu shalat di sore hari');
      case 'maghrib': return context.tr('Waktu shalat setelah matahari terbenam');
      case 'isya':    return context.tr('Waktu shalat di malam hari setelah hilang mega merah');
      default:        return context.tr('Waktu untuk menunaikan shalat');
    }
  }
}