import 'dart:convert';
import 'dart:async';
import 'dart:math'; // untuk sqrt jika dibutuhkan
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../model/shalat_model.dart';

class ShalatRepository {
  // =========================================================================
  // MAP KOORDINAT KOTA
  // Koordinat ini dipakai untuk DUA hal:
  // 1. Pilih kota manual → langsung pakai lat/lon dari sini
  // 2. GPS mode → cari kota terdekat dari koordinat GPS
  // =========================================================================
  static const Map<String, Map<String, dynamic>> cityCoordinates = {
    // Jabodetabek & Banten
    'Jakarta':        {'lat': -6.2088,  'lon': 106.8456},
    'Bogor':          {'lat': -6.5971,  'lon': 106.8060},
    'Depok':          {'lat': -6.4025,  'lon': 106.7942},
    'Tangerang':      {'lat': -6.1783,  'lon': 106.6319},
    'Bekasi':         {'lat': -6.2383,  'lon': 106.9756},
    'Serang':         {'lat': -6.1201,  'lon': 106.1503},

    // Jawa Barat
    'Bandung':        {'lat': -6.9147,  'lon': 107.6098},
    'Cianjur':        {'lat': -6.8172,  'lon': 107.1395}, // ✅ koordinat kota Cianjur yang benar
    'Sukabumi':       {'lat': -6.9277,  'lon': 106.9300},
    'Tasikmalaya':    {'lat': -7.3274,  'lon': 108.2207},
    'Garut':          {'lat': -7.2167,  'lon': 107.9000},
    'Cirebon':        {'lat': -6.7320,  'lon': 108.5523},
    'Karawang':       {'lat': -6.3215,  'lon': 107.3381},
    'Subang':         {'lat': -6.5718,  'lon': 107.7621},
    'Purwakarta':     {'lat': -6.5567,  'lon': 107.4307},
    'Kuningan':       {'lat': -6.9757,  'lon': 108.4743},
    'Majalengka':     {'lat': -6.8362,  'lon': 108.2274},
    'Indramayu':      {'lat': -6.3279,  'lon': 108.3198},
    'Sumedang':       {'lat': -6.8451,  'lon': 107.9199},

    // Jawa Tengah
    'Purwokerto':     {'lat': -7.4308,  'lon': 109.2479},
    'Semarang':       {'lat': -6.9932,  'lon': 110.4203},
    'Solo':           {'lat': -7.5755,  'lon': 110.8243},
    'Yogyakarta':     {'lat': -7.7956,  'lon': 110.3695},
    'Magelang':       {'lat': -7.4712,  'lon': 110.2178},
    'Pekalongan':     {'lat': -6.8886,  'lon': 109.6753},
    'Tegal':          {'lat': -6.8694,  'lon': 109.1402},
    'Salatiga':       {'lat': -7.3305,  'lon': 110.5084},
    'Kudus':          {'lat': -6.8048,  'lon': 110.8396},

    // Jawa Timur
    'Surabaya':       {'lat': -7.2575,  'lon': 112.7521},
    'Malang':         {'lat': -7.9666,  'lon': 112.6326},
    'Madiun':         {'lat': -7.6298,  'lon': 111.5239},
    'Kediri':         {'lat': -7.8166,  'lon': 112.0117},
    'Jember':         {'lat': -8.1724,  'lon': 113.7018},
    'Banyuwangi':     {'lat': -8.2192,  'lon': 114.3691},
    'Probolinggo':    {'lat': -7.7543,  'lon': 113.2159},
    'Mojokerto':      {'lat': -7.4717,  'lon': 112.4338},

    // Sumatera
    'Banda Aceh':     {'lat': 5.5483,   'lon': 95.3238},
    'Medan':          {'lat': 3.5952,   'lon': 98.6722},
    'Padang':         {'lat': -0.9492,  'lon': 100.3543},
    'Pekanbaru':      {'lat': 0.5335,   'lon': 101.4508},
    'Batam':          {'lat': 1.1301,   'lon': 104.0529},
    'Jambi':          {'lat': -1.6101,  'lon': 103.6131},
    'Palembang':      {'lat': -2.9761,  'lon': 104.7754},
    'Bengkulu':       {'lat': -3.7928,  'lon': 102.2608},
    'Bandar Lampung': {'lat': -5.3971,  'lon': 105.2668},

    // Kalimantan
    'Pontianak':      {'lat': -0.0263,  'lon': 109.3425},
    'Palangkaraya':   {'lat': -2.2161,  'lon': 113.9135},
    'Banjarmasin':    {'lat': -3.3194,  'lon': 114.5908},
    'Samarinda':      {'lat': -0.5022,  'lon': 117.1536},
    'Balikpapan':     {'lat': -1.2675,  'lon': 116.8529},

    // Sulawesi
    'Makassar':       {'lat': -5.1477,  'lon': 119.4327},
    'Manado':         {'lat': 1.4748,   'lon': 124.8421},
    'Kendari':        {'lat': -3.9985,  'lon': 122.5127},
    'Palu':           {'lat': -0.9003,  'lon': 119.8779},
    'Gorontalo':      {'lat': 0.5435,   'lon': 123.0595},

    // Bali & Nusa Tenggara
    'Denpasar':       {'lat': -8.6705,  'lon': 115.2126},
    'Mataram':        {'lat': -8.5833,  'lon': 116.1167},
    'Kupang':         {'lat': -10.1772, 'lon': 123.6070},

    // Maluku & Papua
    'Ambon':          {'lat': -3.6954,  'lon': 128.1814},
    'Jayapura':       {'lat': -2.5916,  'lon': 140.6690},
    'Sorong':         {'lat': -0.8762,  'lon': 131.2505},
  };

  // =========================================================================
  // ✅ NEAREST CITY DETECTION
  // Mencari kota terdekat berdasarkan jarak Euclidean dari koordinat GPS.
  // Lebih akurat dari range-based detection karena tidak bergantung
  // pada batas koordinat yang bisa salah.
  // Contoh: -6.9173, 107.6068 → Cianjur (bukan Bandung/Jakarta)
  // =========================================================================
  String _findNearestCity(double lat, double lon) {
    String nearest = 'Indonesia';
    double minDist = double.infinity;

    cityCoordinates.forEach((city, coords) {
      final dLat = lat - (coords['lat'] as double);
      final dLon = lon - (coords['lon'] as double);
      // Tidak perlu sqrt karena hanya untuk perbandingan
      final dist = dLat * dLat + dLon * dLon;
      if (dist < minDist) {
        minDist = dist;
        nearest = city;
      }
    });

    // Konversi ke km untuk logging (1 derajat ≈ 111 km)
    final distKm = sqrt(minDist) * 111;
    debugPrint('📍 Nearest city: $nearest (jarak ≈ ${distKm.toStringAsFixed(1)} km)');
    return nearest;
  }

  // =========================================================================
  // PERMISSION & LOCATION
  // =========================================================================

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Location services disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('🔄 Requesting location permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Location permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ Location permission permanently denied');
      return false;
    }

    debugPrint('✅ Location permission granted');
    return true;
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      debugPrint('🔄 Getting GPS location...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      debugPrint('📍 GPS: ${position.latitude}, ${position.longitude}');
      debugPrint('   Accuracy: ${position.accuracy.toStringAsFixed(0)}m');

      // Peringatan jika akurasi GPS sangat buruk (misalnya pakai browser/emulator)
      if (position.accuracy > 5000) {
        debugPrint('⚠️ GPS accuracy sangat rendah (${position.accuracy.toStringAsFixed(0)}m)');
        debugPrint('   Gunakan HP fisik untuk akurasi lebih baik');
      }

      return position;
    } on TimeoutException {
      debugPrint('⏱️ GPS timeout');
      return null;
    } on LocationServiceDisabledException {
      debugPrint('⚠️ Location service disabled');
      return null;
    } on PermissionDeniedException {
      debugPrint('⚠️ Location permission denied');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return null;
    }
  }

  // =========================================================================
  // FETCH JADWAL UTAMA
  // =========================================================================

  Future<ShalatModel> fetchJadwal({
    String? kodeKota,
    DateTime? tanggal,
    bool useGPS = true,
    double? manualLat,
    double? manualLon,
    String? manualCity,
  }) async {
    final selectedDate = tanggal ?? DateTime.now();

    double? latitude;
    double? longitude;
    String cityName;

    // Priority 1: koordinat manual (user pilih kota dari daftar)
    if (manualLat != null && manualLon != null && manualCity != null) {
      latitude = manualLat;
      longitude = manualLon;
      cityName = manualCity;
      debugPrint('📍 Manual city: $cityName ($latitude, $longitude)');
    }
    // Priority 2: GPS otomatis
    else if (useGPS) {
      final position = await _getCurrentLocation();
      if (position != null) {
        latitude  = position.latitude;
        longitude = position.longitude;

        // ✅ Pakai nearest city — TIDAK lewat API (API selalu return "Jakarta"
        // untuk semua kota WIB karena timezone "Asia/Jakarta")
        cityName = _findNearestCity(latitude, longitude);
      } else {
        // Fallback jika GPS gagal
        latitude  = -6.9147;
        longitude = 107.6098;
        cityName  = 'Bandung';
        debugPrint('⚠️ GPS failed, fallback: Bandung');
      }
    }
    // Priority 3: default
    else {
      latitude  = -6.9147;
      longitude = 107.6098;
      cityName  = 'Bandung';
    }

    // Format tanggal untuk URL
    final day   = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final year  = selectedDate.year;

    final url =
        'https://api.aladhan.com/v1/timings/$day-$month-$year'
        '?latitude=$latitude&longitude=$longitude&method=20';

    debugPrint('🔍 Fetching: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          final timings = jsonData['data']['timings'];

          const months = [
            'Januari', 'Februari', 'Maret',    'April',   'Mei',      'Juni',
            'Juli',    'Agustus',  'September', 'Oktober', 'November', 'Desember',
          ];
          const days = [
            'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
          ];

          final dayName          = days[(selectedDate.weekday - 1) % 7];
          final monthName        = months[selectedDate.month - 1];
          final tanggalFormatted =
              '$dayName, ${selectedDate.day} $monthName ${selectedDate.year}';

          debugPrint('✅ Jadwal loaded: $cityName - $tanggalFormatted');

          return ShalatModel(
            tanggal:  tanggalFormatted,
            lokasi:   cityName,
            namaKota: cityName,
            imsak:    _formatTime(timings['Imsak']),
            subuh:    _formatTime(timings['Fajr']),
            terbit:   _formatTime(timings['Sunrise']),
            dhuha:    _formatTime(timings['Sunrise'], addMinutes: 20),
            dzuhur:   _formatTime(timings['Dhuhr']),
            ashar:    _formatTime(timings['Asr']),
            maghrib:  _formatTime(timings['Maghrib']),
            isya:     _formatTime(timings['Isha']),
          );
        } else {
          throw Exception('Invalid response format dari API');
        }
      } else {
        throw Exception('Gagal memuat jadwal (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Error fetching jadwal: $e');
      throw Exception('Error: $e');
    }
  }

  // =========================================================================
  // FORMAT WAKTU
  // =========================================================================
  String _formatTime(String? time, {int addMinutes = 0}) {
    if (time == null) return '00:00';

    // Hapus timezone suffix: "04:41 (WIB)" → "04:41"
    String cleaned = time.split(' ').first;

    if (addMinutes > 0) {
      try {
        final parts = cleaned.split(':');
        int hours   = int.parse(parts[0]);
        int minutes = int.parse(parts[1]) + addMinutes;

        if (minutes >= 60) {
          hours   += minutes ~/ 60;
          minutes  = minutes % 60;
        }
        if (hours >= 24) hours = hours % 24;

        cleaned =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } catch (_) {
        return cleaned;
      }
    }

    return cleaned;
  }

  // =========================================================================
  // BACKWARD COMPATIBILITY
  // =========================================================================
  static String getCityName(String kodeKota) {
    const cities = {
      '1301': 'Jakarta',
      '1401': 'Bandung',
      '3201': 'Bogor',
    };
    return cities[kodeKota] ?? 'Unknown';
  }

  static Map<String, String> getAllCities() {
    return {
      '1301': 'Jakarta',
      '1401': 'Bandung',
      '3201': 'Bogor',
    };
  }
}