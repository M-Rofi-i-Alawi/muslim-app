import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/shalat_model.dart';
import '../repository/shalat_repository.dart';

class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository repository;

  // ✅ FIX 1: Hapus auto-call di constructor → cegah fetch 2-3x
  // MenuPage.initState() sudah memanggil getJadwalShalat(), jadi tidak perlu di sini
  ShalatViewModel(this.repository);

  bool isLoading = false;
  String error = '';
  ShalatModel? jadwal;

  String? selectedKota;       // null = GPS mode
  DateTime selectedDate = DateTime.now();
  bool useGPS = true;

  // ✅ GPS mode
  Future<void> getJadwalShalatGPS() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      debugPrint('🔄 Fetching jadwal with GPS...'); // ✅ FIX 2: debugPrint

      jadwal = await repository.fetchJadwal(
        tanggal: selectedDate,
        useGPS: true,
      );

      debugPrint('✅ Jadwal loaded successfully: ${jadwal?.namaKota}');

      selectedKota = null;
      useGPS = true;
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error loading jadwal: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Manual city selection — pakai nama kota, bukan kode
  Future<void> getJadwalShalat({String? kodeKota, DateTime? tanggal}) async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      if (kodeKota != null) selectedKota = kodeKota;
      if (tanggal != null) selectedDate = tanggal;

      if (selectedKota != null) {
        // ✅ FIX 3: Ambil koordinat dari cityCoordinates, bukan fallback Jakarta
        final cityName = ShalatRepository.getCityName(selectedKota!);
        final coords = ShalatRepository.cityCoordinates[cityName];

        debugPrint('📍 Fetching jadwal for city: $cityName');

        if (coords != null) {
          // ✅ Pakai koordinat kota yang benar
          jadwal = await repository.fetchJadwal(
            tanggal: selectedDate,
            useGPS: false,
            manualLat: coords['lat'],
            manualLon: coords['lon'],
            manualCity: cityName,
          );
        } else {
          // Fallback GPS kalau kota tidak ditemukan
          debugPrint('⚠️ Koordinat kota $cityName tidak ditemukan, fallback GPS');
          jadwal = await repository.fetchJadwal(
            tanggal: selectedDate,
            useGPS: true,
          );
        }

        useGPS = false;
      } else {
        // GPS mode
        debugPrint('🔄 Fetching jadwal with GPS...');
        jadwal = await repository.fetchJadwal(
          tanggal: selectedDate,
          useGPS: true,
        );
        useGPS = true;
      }

      debugPrint('✅ Jadwal loaded successfully: ${jadwal?.namaKota}');
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error loading jadwal: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Pilih kota dari nama langsung (untuk UI yang pakai nama kota)
  Future<void> selectCityByName(String cityName) async {
    debugPrint('📍 User selected city: $cityName');
    selectedKota = null; // Clear kode kota
    useGPS = false;

    try {
      isLoading = true;
      error = '';
      notifyListeners();

      final coords = ShalatRepository.cityCoordinates[cityName];

      if (coords != null) {
        jadwal = await repository.fetchJadwal(
          tanggal: selectedDate,
          useGPS: false,
          manualLat: coords['lat'],
          manualLon: coords['lon'],
          manualCity: cityName,
        );
        debugPrint('✅ Jadwal loaded for: $cityName');
      } else {
        debugPrint('⚠️ Kota $cityName tidak ada di daftar koordinat');
        error = 'Kota tidak ditemukan';
      }
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Pilih kota dari kode (backward compatibility)
  void setKota(String kodeKota) {
    final cityName = ShalatRepository.getCityName(kodeKota);
    debugPrint('📍 User selected city code: $kodeKota → $cityName');
    selectedKota = kodeKota;
    useGPS = false;
    getJadwalShalat(kodeKota: kodeKota);
  }

  // ✅ Ganti tanggal
  void setDate(DateTime date) {
    debugPrint('📅 User selected date: ${date.day}/${date.month}/${date.year}');
    selectedDate = date;

    if (selectedKota != null) {
      getJadwalShalat(tanggal: date);
    } else {
      getJadwalShalatGPS();
    }
  }

  // ✅ Reset ke GPS
  void resetToGPS() {
    debugPrint('🌍 Resetting to GPS mode...');
    selectedKota = null;
    useGPS = true;
    getJadwalShalatGPS();
  }

  // ✅ Refresh
  Future<void> refresh() async {
    debugPrint('🔄 Refreshing jadwal...');
    if (selectedKota != null) {
      await getJadwalShalat();
    } else {
      await getJadwalShalatGPS();
    }
  }

  String getCityName() {
    if (jadwal?.namaKota != null) return jadwal!.namaKota;
    if (selectedKota != null) return ShalatRepository.getCityName(selectedKota!);
    return 'Detecting...';
  }

  bool get isUsingGPS => selectedKota == null && useGPS;
  String get modeDisplay => isUsingGPS ? 'GPS Auto' : 'Manual';
}