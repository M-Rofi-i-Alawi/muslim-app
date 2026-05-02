import 'package:flutter/foundation.dart';
import '../model/dzikir_model.dart';
import '../repository/dzikir_repository.dart';
import '../services/dzikir_local_service.dart'; // ✅ import service lokal

class DzikirViewModel extends ChangeNotifier {
  final DzikirRepository   _repository;
  final DzikirLocalService _localService = DzikirLocalService();

  List<DzikirModel> _dzikirPagi    = [];
  List<DzikirModel> _dzikirPetang  = [];
  List<DzikirModel> _dzikirShalat  = [];
  bool              _isLoading     = false;

  DzikirViewModel(this._repository);

  // ─── GETTERS ──────────────────────────────────────────────────────────────
  List<DzikirModel> get dzikirPagi    => _dzikirPagi;
  List<DzikirModel> get dzikirPetang  => _dzikirPetang;
  List<DzikirModel> get dzikirShalat  => _dzikirShalat;
  bool              get isLoading     => _isLoading;

  int    get pagiProgress    => _dzikirPagi.where((d) => d.isCompleted).length;
  int    get pagiTotal       => _dzikirPagi.length;
  double get pagiPercentage  => pagiTotal > 0 ? pagiProgress / pagiTotal : 0;

  int    get petangProgress   => _dzikirPetang.where((d) => d.isCompleted).length;
  int    get petangTotal      => _dzikirPetang.length;
  double get petangPercentage => petangTotal > 0 ? petangProgress / petangTotal : 0;

  int    get shalatProgress   => _dzikirShalat.where((d) => d.isCompleted).length;
  int    get shalatTotal      => _dzikirShalat.length;
  double get shalatPercentage => shalatTotal > 0 ? shalatProgress / shalatTotal : 0;

  // ─── FETCH + LOAD SAVED PROGRESS ─────────────────────────────────────────
  /// ✅ FIX: Setelah fetch dari API/local JSON, load ulang counter dari
  /// SharedPreferences supaya progress tidak hilang saat app ditutup
  Future<void> fetchAllDzikir() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dzikirPagi   = await _repository.fetchDzikirPagi();
      _dzikirPetang = await _repository.fetchDzikirPetang();
      _dzikirShalat = await _repository.fetchDzikirShalat();

      // ✅ Load saved counter dari SharedPreferences
      await _loadSavedCounts('pagi',   _dzikirPagi);
      await _loadSavedCounts('petang', _dzikirPetang);
      await _loadSavedCounts('shalat', _dzikirShalat);
    } catch (e) {
      debugPrint('❌ Error fetching dzikir: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load counter yang tersimpan dan terapkan ke list dzikir
  Future<void> _loadSavedCounts(
      String kategori, List<DzikirModel> list) async {
    final saved = await _localService.loadAllCounts(kategori);
    for (final dzikir in list) {
      final key   = dzikir.id.toString();
      final count = saved[key] ?? 0;
      dzikir.currentCount = count;
      dzikir.isDone       = dzikir.isCompleted;
    }
  }

  // ─── INCREMENT ────────────────────────────────────────────────────────────
  /// ✅ FIX: Setelah increment, simpan ke SharedPreferences
  Future<void> incrementCount(String kategori, int id) async {
    final list  = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);

    if (index != -1 && list[index].currentCount < list[index].jumlahBaca) {
      list[index].currentCount++;
      list[index].isDone = list[index].isCompleted;
      notifyListeners();

      // ✅ Simpan ke SharedPreferences
      await _localService.saveCount(
        kategori,
        id.toString(),
        list[index].currentCount,
      );
    }
  }

  // ─── DECREMENT ────────────────────────────────────────────────────────────
  Future<void> decrementCount(String kategori, int id) async {
    final list  = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);

    if (index != -1 && list[index].currentCount > 0) {
      list[index].currentCount--;
      list[index].isDone = list[index].isCompleted;
      notifyListeners();

      await _localService.saveCount(
        kategori,
        id.toString(),
        list[index].currentCount,
      );
    }
  }

  // ─── RESET SATU DZIKIR ────────────────────────────────────────────────────
  Future<void> resetCount(String kategori, int id) async {
    final list  = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);

    if (index != -1) {
      list[index].currentCount = 0;
      list[index].isDone       = false;
      notifyListeners();

      await _localService.resetCount(kategori, id.toString());
    }
  }

  // ─── RESET SEMUA ──────────────────────────────────────────────────────────
  Future<void> resetAll(String kategori) async {
    final list = _getListByKategori(kategori);
    for (final dzikir in list) {
      dzikir.currentCount = 0;
      dzikir.isDone       = false;
    }
    notifyListeners();

    await _localService.resetAll(kategori);
  }

  // ─── HELPER ───────────────────────────────────────────────────────────────
  List<DzikirModel> _getListByKategori(String kategori) {
    switch (kategori) {
      case 'pagi':    return _dzikirPagi;
      case 'petang':  return _dzikirPetang;
      case 'shalat':  return _dzikirShalat;
      default:        return [];
    }
  }
}