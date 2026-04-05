import 'package:flutter/material.dart';
import '../model/hadist_model.dart';
import '../repository/hadist_repository.dart';

class HadistViewModel extends ChangeNotifier {
  final HadistRepository _repository;
  
  List<HadistModel> _hadistList = [];
  HadistModel? _hadistOfDay;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedTema = 'Semua';

  HadistViewModel(this._repository);

  List<HadistModel> get hadistList => _filteredHadist();
  HadistModel? get hadistOfDay => _hadistOfDay;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedTema => _selectedTema;

  List<String> get temaList {
    final temas = _hadistList.map((h) => h.tema).toSet().toList();
    return ['Semua', ...temas];
  }

  Future<void> fetchHadist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hadistList = await _repository.fetchHadist();
      _hadistOfDay = await _repository.getHadistOfTheDay();
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

  void setSelectedTema(String tema) {
    _selectedTema = tema;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    final index = _hadistList.indexWhere((h) => h.id == id);
    if (index != -1) {
      _hadistList[index].isFavorite = !_hadistList[index].isFavorite;
      notifyListeners();
    }
  }

  List<HadistModel> _filteredHadist() {
    var filtered = _hadistList;

    // Filter by tema
    if (_selectedTema != 'Semua') {
      filtered = filtered.where((h) => h.tema == _selectedTema).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((h) =>
        h.arti.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        h.tema.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        h.rawi.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  List<HadistModel> getFavorites() {
    return _hadistList.where((h) => h.isFavorite).toList();
  }
}