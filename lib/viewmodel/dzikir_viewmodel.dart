import 'package:flutter/material.dart';
import '../model/dzikir_model.dart';
import '../repository/dzikir_repository.dart';

class DzikirViewModel extends ChangeNotifier {
  final DzikirRepository _repository;
  
  List<DzikirModel> _dzikirPagi = [];
  List<DzikirModel> _dzikirPetang = [];
  List<DzikirModel> _dzikirShalat = [];
  bool _isLoading = false;

  DzikirViewModel(this._repository);

  // Getters
  List<DzikirModel> get dzikirPagi => _dzikirPagi;
  List<DzikirModel> get dzikirPetang => _dzikirPetang;
  List<DzikirModel> get dzikirShalat => _dzikirShalat;
  bool get isLoading => _isLoading;

  // Progress tracking for Pagi
  int get pagiProgress => _dzikirPagi.where((d) => d.isCompleted).length;
  int get pagiTotal => _dzikirPagi.length;
  double get pagiPercentage => pagiTotal > 0 ? pagiProgress / pagiTotal : 0;

  // Progress tracking for Petang
  int get petangProgress => _dzikirPetang.where((d) => d.isCompleted).length;
  int get petangTotal => _dzikirPetang.length;
  double get petangPercentage => petangTotal > 0 ? petangProgress / petangTotal : 0;

  // Progress tracking for Shalat
  int get shalatProgress => _dzikirShalat.where((d) => d.isCompleted).length;
  int get shalatTotal => _dzikirShalat.length;
  double get shalatPercentage => shalatTotal > 0 ? shalatProgress / shalatTotal : 0;

  // Load all dzikir
  Future<void> fetchAllDzikir() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dzikirPagi = await _repository.fetchDzikirPagi();
      _dzikirPetang = await _repository.fetchDzikirPetang();
      _dzikirShalat = await _repository.fetchDzikirShalat();
    } catch (e) {
      print('❌ Error fetching dzikir: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Increment counter
  void incrementCount(String kategori, int id) {
    final list = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);
    
    if (index != -1 && list[index].currentCount < list[index].jumlahBaca) {
      list[index].currentCount++;
      list[index].isDone = list[index].isCompleted;
      notifyListeners();
    }
  }

  // Decrement counter
  void decrementCount(String kategori, int id) {
    final list = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);
    
    if (index != -1 && list[index].currentCount > 0) {
      list[index].currentCount--;
      list[index].isDone = list[index].isCompleted;
      notifyListeners();
    }
  }

  // Reset single dzikir
  void resetCount(String kategori, int id) {
    final list = _getListByKategori(kategori);
    final index = list.indexWhere((d) => d.id == id);
    
    if (index != -1) {
      list[index].currentCount = 0;
      list[index].isDone = false;
      notifyListeners();
    }
  }

  // Reset all dzikir in category
  void resetAll(String kategori) {
    final list = _getListByKategori(kategori);
    for (var dzikir in list) {
      dzikir.currentCount = 0;
      dzikir.isDone = false;
    }
    notifyListeners();
  }

  // Helper to get list by category
  List<DzikirModel> _getListByKategori(String kategori) {
    switch (kategori) {
      case 'pagi':
        return _dzikirPagi;
      case 'petang':
        return _dzikirPetang;
      case 'shalat':
        return _dzikirShalat;
      default:
        return [];
    }
  }
}