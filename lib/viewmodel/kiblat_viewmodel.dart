import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/kiblat_model.dart';
import '../repository/kiblat_repository.dart';

class KiblatViewModel extends ChangeNotifier {
  final KiblatRepository repository;

  KiblatViewModel(this.repository);

  bool isLoading = false;
  String error = '';
  KiblatModel? kiblat;
  Position? currentPosition;

  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error = 'Izin lokasi ditolak';
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        error = 'Izin lokasi ditolak permanen. Aktifkan di pengaturan.';
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get position
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await getArahKiblat(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
    } catch (e) {
      error = 'Gagal mendapatkan lokasi: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getArahKiblat(double lat, double lon) async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      kiblat = await repository.fetchArahKiblat(
        latitude: lat,
        longitude: lon,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}