import 'package:flutter/material.dart';
import '../model/asmaul_husna_model.dart';
import '../repository/asmaul_husna_repository.dart';

class AsmaulHusnaViewModel extends ChangeNotifier {
  final AsmaulHusnaRepository _repository;
  
  List<AsmaulHusnaModel> _asmaulHusnaList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _memorizedCount = 0;

  AsmaulHusnaViewModel(this._repository);

  List<AsmaulHusnaModel> get asmaulHusnaList => _filteredList();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get memorizedCount => _memorizedCount;
  int get totalCount => _asmaulHusnaList.length;

  Future<void> fetchAsmaulHusna() async {
    _isLoading = true;
    notifyListeners();

    try {
      _asmaulHusnaList = await _repository.fetchAsmaulHusna();
      _updateMemorizedCount();
    } catch (e) {
      print('Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    final index = _asmaulHusnaList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _asmaulHusnaList[index].isFavorite = !_asmaulHusnaList[index].isFavorite;
      notifyListeners();
    }
  }

  void toggleMemorized(int id) {
    final index = _asmaulHusnaList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _asmaulHusnaList[index].isMemorized = !_asmaulHusnaList[index].isMemorized;
      _updateMemorizedCount();
      notifyListeners();
    }
  }

  void _updateMemorizedCount() {
    _memorizedCount = _asmaulHusnaList.where((item) => item.isMemorized).length;
  }

  List<AsmaulHusnaModel> _filteredList() {
    if (_searchQuery.isEmpty) {
      return _asmaulHusnaList;
    }

    return _asmaulHusnaList.where((item) =>
      item.latin.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.arti.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.arab.contains(_searchQuery)
    ).toList();
  }

  List<AsmaulHusnaModel> getFavorites() {
    return _asmaulHusnaList.where((item) => item.isFavorite).toList();
  }

  List<AsmaulHusnaModel> getMemorized() {
    return _asmaulHusnaList.where((item) => item.isMemorized).toList();
  }
}