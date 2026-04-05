import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ramadhan_model.dart';

class RamadhanRepository {
  static const String _storageKey = 'ramadhan_entries';

  // Load all entries from SharedPreferences
  Future<List<RamadhanEntry>> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => RamadhanEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading ramadhan entries: $e');
      return [];
    }
  }

  // Save all entries to SharedPreferences
  Future<void> saveEntries(List<RamadhanEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = entries.map((entry) => entry.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving ramadhan entries: $e');
      throw Exception('Failed to save entries');
    }
  }

  // Get entry by date
  Future<RamadhanEntry?> getEntryByDate(DateTime date) async {
    final entries = await loadEntries();
    final dateStr = _formatDate(date);
    
    try {
      return entries.firstWhere((entry) => entry.id == dateStr);
    } catch (e) {
      return null;
    }
  }

  // Save or update single entry
  Future<void> saveEntry(RamadhanEntry entry) async {
    final entries = await loadEntries();
    
    // Remove existing entry with same date if exists
    entries.removeWhere((e) => e.id == entry.id);
    
    // Add new entry
    entries.add(entry);
    
    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    // Save to storage
    await saveEntries(entries);
  }

  // Delete entry by date
  Future<void> deleteEntry(DateTime date) async {
    final entries = await loadEntries();
    final dateStr = _formatDate(date);
    
    entries.removeWhere((entry) => entry.id == dateStr);
    await saveEntries(entries);
  }

  // Get entries for current Ramadhan (last 30 days from latest entry)
  Future<List<RamadhanEntry>> getCurrentRamadhanEntries() async {
    final entries = await loadEntries();
    
    if (entries.isEmpty) return [];
    
    // Get the latest entry
    final latestEntry = entries.first;
    final startDate = latestEntry.date.subtract(Duration(days: 29));
    
    // Filter entries within 30 days
    return entries.where((entry) {
      return entry.date.isAfter(startDate.subtract(Duration(days: 1))) &&
             entry.date.isBefore(latestEntry.date.add(Duration(days: 1)));
    }).toList();
  }

  // Calculate statistics
  Future<RamadhanStatistics> getStatistics() async {
    final entries = await getCurrentRamadhanEntries();
    
    if (entries.isEmpty) {
      return RamadhanStatistics();
    }

    int puasaCount = 0;
    int allShalatCompleteCount = 0;
    int tarawihCount = 0;
    int tahajudCount = 0;
    int totalTadarusJuz = 0;
    double totalInfak = 0;
    int ceramahCount = 0;

    for (var entry in entries) {
      if (entry.puasa) puasaCount++;
      if (entry.allShalatComplete) allShalatCompleteCount++;
      if (entry.shalatTarawih) tarawihCount++;
      if (entry.shalatTahajud) tahajudCount++;
      totalTadarusJuz += entry.tadarusJuz;
      totalInfak += entry.infakAmount;
      if (entry.ceramahTitle.isNotEmpty) ceramahCount++;
    }

    return RamadhanStatistics(
      totalDays: entries.length,
      puasaCount: puasaCount,
      allShalatCompleteCount: allShalatCompleteCount,
      tarawihCount: tarawihCount,
      tahajudCount: tahajudCount,
      totalTadarusJuz: totalTadarusJuz,
      totalInfak: totalInfak,
      ceramahCount: ceramahCount,
    );
  }

  // Export to JSON string (for sharing/backup)
  Future<String> exportToJson() async {
    final entries = await loadEntries();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    return json.encode(jsonList);
  }

  // Import from JSON string
  Future<void> importFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final entries = jsonList
          .map((json) => RamadhanEntry.fromJson(json))
          .toList();
      
      await saveEntries(entries);
    } catch (e) {
      print('Error importing ramadhan entries: $e');
      throw Exception('Failed to import entries');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Helper: Format date to string ID (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper: Create new entry for today
  RamadhanEntry createNewEntry({DateTime? date, int? ramadhanDay}) {
    final entryDate = date ?? DateTime.now();
    return RamadhanEntry(
      id: _formatDate(entryDate),
      date: entryDate,
      ramadhanDay: ramadhanDay ?? 1,
    );
  }
}