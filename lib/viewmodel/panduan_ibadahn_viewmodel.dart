import 'package:flutter/material.dart';
import '../model/panduan_ibadah_model.dart';
import '../repository/panduan_ibadah_repository.dart';

class PanduanIbadahViewModel extends ChangeNotifier {
  final PanduanIbadahRepository _repository;
  
  List<PanduanIbadahCategory> _categories = [];
  PanduanIbadahCategory? _selectedCategory;
  PanduanIbadahItem? _selectedItem;
  bool _isLoading = false;
  String? _error;

  PanduanIbadahViewModel(this._repository) {
    loadCategories();
  }

  // Getters
  List<PanduanIbadahCategory> get categories => _categories;
  PanduanIbadahCategory? get selectedCategory => _selectedCategory;
  PanduanIbadahItem? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a category
  void selectCategory(PanduanIbadahCategory category) {
    _selectedCategory = category;
    _selectedItem = null;
    notifyListeners();
  }

  // Select an item
  void selectItem(PanduanIbadahItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  // Go back to categories
  void backToCategories() {
    _selectedCategory = null;
    _selectedItem = null;
    notifyListeners();
  }

  // Go back to items list
  void backToItems() {
    _selectedItem = null;
    notifyListeners();
  }

  // Get color from hex string
  Color getColor(String hexColor) {
    return Color(int.parse(hexColor));
  }
}