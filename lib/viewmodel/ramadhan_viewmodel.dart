import 'package:flutter/material.dart';
import '../model/ramadhan_model.dart';
import '../repository/ramadhan_repository.dart';

class RamadhanViewModel extends ChangeNotifier {
  final RamadhanRepository _repository;

  RamadhanViewModel(this._repository) {
    loadTodayEntry();
    loadStatistics();
  }

  // Current state
  RamadhanEntry? _currentEntry;
  List<RamadhanEntry> _allEntries = [];
  RamadhanStatistics _statistics = RamadhanStatistics();
  bool _isLoading = false;
  String? _error;

  // Selected date for viewing
  DateTime _selectedDate = DateTime.now();

  // Getters
  RamadhanEntry? get currentEntry => _currentEntry;
  List<RamadhanEntry> get allEntries => _allEntries;
  RamadhanStatistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Load today's entry
  Future<void> loadTodayEntry() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentEntry = await _repository.getEntryByDate(DateTime.now());
      
      // If no entry for today, create new one
      if (_currentEntry == null) {
        final currentRamadhanDay = await _calculateRamadhanDay();
        _currentEntry = _repository.createNewEntry(
          ramadhanDay: currentRamadhanDay,
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load entry by date
  Future<void> loadEntryByDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();

    try {
      _currentEntry = await _repository.getEntryByDate(date);
      
      if (_currentEntry == null) {
        final ramadhanDay = await _calculateRamadhanDay(date);
        _currentEntry = _repository.createNewEntry(
          date: date,
          ramadhanDay: ramadhanDay,
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all entries
  Future<void> loadAllEntries() async {
    try {
      _allEntries = await _repository.getCurrentRamadhanEntries();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get all entries (for Timeline)
  Future<List<RamadhanEntry>> getAllEntries() async {
    return await _repository.getCurrentRamadhanEntries();
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getStatistics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update checklist (shalat, puasa, etc)
  void updatePuasa(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(puasa: value);
    notifyListeners();
  }

  void updateShalatSubuh(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatSubuh: value);
    notifyListeners();
  }

  void updateShalatDzuhur(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatDzuhur: value);
    notifyListeners();
  }

  void updateShalatAshar(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatAshar: value);
    notifyListeners();
  }

  void updateShalatMaghrib(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatMaghrib: value);
    notifyListeners();
  }

  void updateShalatIsya(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatIsya: value);
    notifyListeners();
  }

  void updateShalatTarawih(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatTarawih: value);
    notifyListeners();
  }

  void updateShalatTahajud(bool value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(shalatTahajud: value);
    notifyListeners();
  }

  // Update tadarus
  void updateTadarusJuz(int juz) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(tadarusJuz: juz);
    notifyListeners();
  }

  void updateTadarusHalaman(int halaman) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(tadarusHalaman: halaman);
    notifyListeners();
  }

  void updateTadarusSurah(String surah) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(tadarusSurah: surah);
    notifyListeners();
  }

  // Update infak
  void updateInfakAmount(double amount) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(infakAmount: amount);
    notifyListeners();
  }

  void updateInfakNote(String note) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(infakNote: note);
    notifyListeners();
  }

  // Update ceramah
  void updateCeramahTitle(String title) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(ceramahTitle: title);
    notifyListeners();
  }

  void updateCeramahUstadz(String ustadz) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(ceramahUstadz: ustadz);
    notifyListeners();
  }

  void updateCeramahRangkuman(String rangkuman) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(ceramahRangkuman: rangkuman);
    notifyListeners();
  }

  void updateCeramahPoinPenting(List<String> poinPenting) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(ceramahPoinPenting: poinPenting);
    notifyListeners();
  }

  // Update diary/karomah
  void updateCatatanHarian(String catatan) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(catatanHarian: catatan);
    notifyListeners();
  }

  void updateDoaTerkabul(String doa) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(doaTerkabul: doa);
    notifyListeners();
  }

  void updateMomenSpesial(String momen) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(momenSpesial: momen);
    notifyListeners();
  }

  void updateRefleksi(String refleksi) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(refleksi: refleksi);
    notifyListeners();
  }

  void updatePembelajaran(String pembelajaran) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(pembelajaran: pembelajaran);
    notifyListeners();
  }

  // Save current entry
  Future<void> saveCurrentEntry() async {
    if (_currentEntry == null) return;

    try {
      await _repository.saveEntry(_currentEntry!);
      await loadStatistics(); // Reload statistics after saving
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Delete entry
  Future<void> deleteEntry(DateTime date) async {
    try {
      await _repository.deleteEntry(date);
      await loadTodayEntry();
      await loadStatistics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Export data (returns JSON string)
  Future<String?> exportData() async {
    try {
      final jsonString = await _repository.exportToJson();
      return jsonString;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Import data (from JSON string)
  Future<void> importData(String jsonString) async {
    try {
      await _repository.importFromJson(jsonString);
      await loadTodayEntry();
      await loadAllEntries();
      await loadStatistics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      await _repository.clearAllData();
      _currentEntry = null;
      _allEntries = [];
      _statistics = RamadhanStatistics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Helper: Calculate Ramadhan day number
  Future<int> _calculateRamadhanDay([DateTime? date]) async {
    final entries = await _repository.getCurrentRamadhanEntries();
    
    if (entries.isEmpty) return 1;
    
    final targetDate = date ?? DateTime.now();
    final firstEntry = entries.last; // Oldest entry
    final daysDiff = targetDate.difference(firstEntry.date).inDays;
    
    return firstEntry.ramadhanDay + daysDiff;
  }

  // Go to previous day
  Future<void> previousDay() async {
    final newDate = _selectedDate.subtract(Duration(days: 1));
    await loadEntryByDate(newDate);
  }

  // Go to next day
  Future<void> nextDay() async {
    final newDate = _selectedDate.add(Duration(days: 1));
    await loadEntryByDate(newDate);
  }

  // Go to today
  Future<void> goToToday() async {
    await loadTodayEntry();
    _selectedDate = DateTime.now();
  }
}