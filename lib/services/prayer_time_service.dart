// lib/services/prayer_time_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._();

  Future<Map<String, DateTime>> fetchJadwal({
    required double latitude,
    required double longitude,
    int method = 20,
  }) async {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final url   = Uri.parse(
      'https://api.aladhan.com/v1/timings/$today'
      '?latitude=$latitude&longitude=$longitude&method=$method',
    );

    debugPrint('[PrayerTimeService] Fetch: $url');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('[PrayerTimeService] HTTP ${response.statusCode}');
    }

    final body    = jsonDecode(response.body);
    final timings = body['data']['timings'] as Map<String, dynamic>;
    return _parse(timings);
  }

  Map<String, DateTime> _parse(Map<String, dynamic> timings) {
    // key internal → key API Aladhan
    const apiKeys = {
      'imsak':   'Imsak',
      'subuh':   'Fajr',
      'terbit':  'Sunrise',  // ✅ Terbit = batas akhir Subuh (bukan +20 menit)
      'dhuha':   'Sunrise',  // Dhuha = Sunrise + 20 menit
      'dzuhur':  'Dhuhr',
      'ashar':   'Asr',
      'maghrib': 'Maghrib',
      'isya':    'Isha',
    };

    final now    = DateTime.now();
    final result = <String, DateTime>{};

    for (final entry in apiKeys.entries) {
      final raw   = (timings[entry.value] as String? ?? '00:00').split(' ').first;
      final parts = raw.split(':');
      final hour  = int.tryParse(parts[0]) ?? 0;
      final min   = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      var dt = DateTime(now.year, now.month, now.day, hour, min);

      // Dhuha = Sunrise + 20 menit
      if (entry.key == 'dhuha') {
        dt = dt.add(const Duration(minutes: 20));
      }

      result[entry.key] = dt;
    }

    return result;
  }
}