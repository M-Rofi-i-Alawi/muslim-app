import 'package:flutter/material.dart';
import '../model/tasbih_model.dart';

class TasbihViewModel extends ChangeNotifier {
  // Default tasbih list
  final List<TasbihModel> _tasbihList = [
    TasbihModel(id: 1, nama: 'Subhanallah', arab: 'سُبْحَانَ اللهِ'),
    TasbihModel(id: 2, nama: 'Alhamdulillah', arab: 'اَلْحَمْدُ لِلَّهِ'),
    TasbihModel(id: 3, nama: 'Allahu Akbar', arab: 'اَللهُ أَكْبَرُ'),
    TasbihModel(id: 4, nama: 'La ilaha illallah', arab: 'لاَ إِلَهَ إِلاَّ اللهُ'),
    TasbihModel(id: 5, nama: 'Astaghfirullah', arab: 'أَسْتَغْفِرُ اللهَ'),
  ];

  List<TasbihHistory> _history = [];
  int _selectedIndex = 0;
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;

  // Getters
  List<TasbihModel> get tasbihList => _tasbihList;
  List<TasbihHistory> get history => _history;
  int get selectedIndex => _selectedIndex;
  TasbihModel get currentTasbih => _tasbihList[_selectedIndex];
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;

  // Select tasbih
  void selectTasbih(int index) {
    if (index >= 0 && index < _tasbihList.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // Increment counter
  void increment() {
    final current = _tasbihList[_selectedIndex];
    
    // Increment count
    current.count++;
    
    // Check if just completed (count == target)
    if (current.count == current.target) {
      // Save to history
      _saveToHistory();
      
      // Notify listeners to trigger vibration/sound in UI
      notifyListeners();
      
      // Auto-reset after short delay (allow UI to show completion)
      Future.delayed(const Duration(milliseconds: 500), () {
        current.count = 0;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // Reset counter
  void reset() {
    _tasbihList[_selectedIndex].count = 0;
    notifyListeners();
  }

  // Set target
  void setTarget(int target) {
    _tasbihList[_selectedIndex].target = target;
    notifyListeners();
  }

  // Add custom tasbih
  void addCustomTasbih(String nama, String arab) {
    final newId = _tasbihList.isEmpty ? 1 : _tasbihList.last.id + 1;
    _tasbihList.add(TasbihModel(
      id: newId,
      nama: nama,
      arab: arab,
    ));
    notifyListeners();
  }

  // Remove custom tasbih (only if id > 5, default ones can't be deleted)
  void removeTasbih(int id) {
    if (id > 5) {
      _tasbihList.removeWhere((t) => t.id == id);
      if (_selectedIndex >= _tasbihList.length) {
        _selectedIndex = _tasbihList.length - 1;
      }
      notifyListeners();
    }
  }

  // Save to history
  void _saveToHistory() {
    final current = _tasbihList[_selectedIndex];
    final newHistory = TasbihHistory(
      id: _history.isEmpty ? 1 : _history.last.id + 1,
      namaZikir: current.nama,
      totalCount: current.count,
      target: current.target,
    );
    _history.insert(0, newHistory); // Add to beginning
    
    // Keep only last 50 entries
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }
  }

  // Clear history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // Toggle vibration
  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  // Toggle sound
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  // Get total count from history
  int getTotalCountForZikir(String namaZikir) {
    return _history
        .where((h) => h.namaZikir == namaZikir)
        .fold(0, (sum, h) => sum + h.totalCount);
  }

  // Get today's count
  int getTodayCount() {
    final today = DateTime.now();
    return _history
        .where((h) => 
          h.completedAt.year == today.year &&
          h.completedAt.month == today.month &&
          h.completedAt.day == today.day
        )
        .fold(0, (sum, h) => sum + h.totalCount);
  }
}