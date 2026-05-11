// lib/viewmodel/shalat_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/shalat_model.dart';
import '../repository/shalat_repository.dart';
import '../services/settings_service.dart';

class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository repository;

  ShalatViewModel(this.repository);

  bool         isLoading = false;
  String       error     = '';
  ShalatModel? jadwal;

  String?  selectedKota;
  DateTime selectedDate = DateTime.now();
  bool     useGPS       = true;

  // ─── INIT DARI KOTA TERSIMPAN ─────────────────────────────────────────────
  Future<void> initWithSavedCity() async {
    final settings = SettingsService();
    await settings.load();

    final savedCity = settings.lastCity;
    final savedGPS  = settings.useGPS;

    if (savedCity != null && !savedGPS) {
      debugPrint('📍 Restoring saved city: $savedCity');
      await selectCityByName(savedCity, saveToPrefs: false);
    } else {
      debugPrint('🌍 Starting with GPS mode');
      await getJadwalShalatGPS();
    }
  }

  // ─── GPS MODE ─────────────────────────────────────────────────────────────
  Future<void> getJadwalShalatGPS() async {
    try {
      isLoading = true;
      error     = '';
      notifyListeners();

      jadwal = await repository.fetchJadwal(
        tanggal: selectedDate,
        useGPS:  true,
      );

      selectedKota = null;
      useGPS       = true;

      // ✅ Simpan bahwa user pakai GPS (koordinat dikelola SettingsService)
      await SettingsService().saveLocation(
        lat:      SettingsService().lastLat,
        lng:      SettingsService().lastLng,
        cityName: null, // null = GPS mode
      );

      debugPrint('✅ GPS jadwal: ${jadwal?.namaKota}');
    } catch (e) {
      error = e.toString();
      debugPrint('❌ GPS error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── PILIH KOTA MANUAL ────────────────────────────────────────────────────
  Future<void> selectCityByName(String cityName,
      {bool saveToPrefs = true}) async {
    debugPrint('📍 User selected city: $cityName');
    selectedKota = null;
    useGPS       = false;

    try {
      isLoading = true;
      error     = '';
      notifyListeners();

      final coords = ShalatRepository.cityCoordinates[cityName];
      if (coords != null) {
        final lat = coords['lat']!;
        final lng = coords['lon']!;

        jadwal = await repository.fetchJadwal(
          tanggal:    selectedDate,
          useGPS:     false,
          manualLat:  lat,
          manualLon:  lng,
          manualCity: cityName,
        );

        // ✅ FIX: pakai saveLocation dengan koordinat kota
        if (saveToPrefs) {
          await SettingsService().saveLocation(
            lat:      lat,
            lng:      lng,
            cityName: cityName,
          );
          debugPrint('💾 Saved city: $cityName');
        }

        debugPrint('✅ Jadwal loaded: $cityName');
      } else {
        error = 'Kota tidak ditemukan';
        debugPrint('⚠️ Kota $cityName tidak ada di daftar');
      }
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── BACKWARD COMPAT ──────────────────────────────────────────────────────
  Future<void> getJadwalShalat({
    String?   kodeKota,
    DateTime? tanggal,
  }) async {
    if (tanggal != null) selectedDate = tanggal;
    if (kodeKota != null) {
      final cityName = ShalatRepository.getCityName(kodeKota);
      await selectCityByName(cityName);
    } else {
      await getJadwalShalatGPS();
    }
  }

  void setKota(String kodeKota) {
    final cityName = ShalatRepository.getCityName(kodeKota);
    selectedKota   = kodeKota;
    useGPS         = false;
    selectCityByName(cityName);
  }

  void setDate(DateTime date) {
    selectedDate = date;
    if (selectedKota != null) {
      getJadwalShalat(tanggal: date);
    } else if (!useGPS) {
      final city = jadwal?.namaKota;
      if (city != null) selectCityByName(city);
    } else {
      getJadwalShalatGPS();
    }
  }

  Future<void> resetToGPS() async {
    debugPrint('🌍 Reset to GPS mode');
    selectedKota = null;
    useGPS       = true;
    await getJadwalShalatGPS();
  }

  Future<void> refresh() async {
    final city = jadwal?.namaKota;
    if (!useGPS && city != null) {
      await selectCityByName(city, saveToPrefs: false);
    } else {
      await getJadwalShalatGPS();
    }
  }

  String getCityName() {
    if (jadwal?.namaKota != null) return jadwal!.namaKota;
    if (selectedKota != null)
      return ShalatRepository.getCityName(selectedKota!);
    return 'Detecting...';
  }

  bool   get isUsingGPS  => selectedKota == null && useGPS;
  String get modeDisplay => isUsingGPS ? 'GPS Auto' : 'Manual';

  void fetchJadwalByCity(String city) {}
}