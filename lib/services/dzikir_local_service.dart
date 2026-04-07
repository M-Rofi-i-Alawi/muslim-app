import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan progress dzikir secara persisten
/// Setiap counter dzikir tersimpan berdasarkan tanggal + id dzikir
/// sehingga otomatis reset tiap hari baru
class DzikirLocalService {
  static const _keyPrefix = 'dzikir_';

  static final DzikirLocalService _instance = DzikirLocalService._();
  factory DzikirLocalService() => _instance;
  DzikirLocalService._();

  // ─── KEY HELPER ───────────────────────────────────────────────────────────
  /// Key format: dzikir_pagi_2026-04-07_dzikir_001
  /// Dengan tanggal → otomatis reset tiap hari
  String _key(String kategori, String dzikirId) {
    final today = _todayStr();
    return '${_keyPrefix}${kategori}_${today}_$dzikirId';
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ─── SAVE COUNT ───────────────────────────────────────────────────────────
  Future<void> saveCount(
      String kategori, String dzikirId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(kategori, dzikirId), count);
  }

  // ─── GET COUNT ────────────────────────────────────────────────────────────
  /// Kembalikan count hari ini. Jika hari baru → otomatis 0
  Future<int> getCount(String kategori, String dzikirId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(kategori, dzikirId)) ?? 0;
  }

  // ─── LOAD ALL COUNTS (untuk satu kategori) ────────────────────────────────
  Future<Map<String, int>> loadAllCounts(String kategori) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final prefix = '${_keyPrefix}${kategori}_$today';

    final Map<String, int> result = {};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(prefix)) {
        // Ekstrak dzikirId dari key
        final parts = key.split('_');
        final dzikirId = parts.last;
        result[dzikirId] = prefs.getInt(key) ?? 0;
      }
    }
    return result;
  }

  // ─── RESET SATU DZIKIR ────────────────────────────────────────────────────
  Future<void> resetCount(String kategori, String dzikirId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(kategori, dzikirId));
  }

  // ─── RESET SEMUA KATEGORI ─────────────────────────────────────────────────
  Future<void> resetAll(String kategori) async {
    final prefs   = await SharedPreferences.getInstance();
    final today   = _todayStr();
    final prefix  = '${_keyPrefix}${kategori}_$today';
    final toDelete = prefs.getKeys()
        .where((k) => k.startsWith(prefix))
        .toList();
    for (final key in toDelete) {
      await prefs.remove(key);
    }
  }

  // ─── CLEANUP DATA LAMA (opsional, panggil saat app start) ────────────────
  /// Hapus data dzikir yang lebih dari 7 hari lalu agar tidak menumpuk
  Future<void> cleanupOldData() async {
    final prefs   = await SharedPreferences.getInstance();
    final cutoff  = DateTime.now().subtract(const Duration(days: 7));
    final toDelete = <String>[];

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;
      // Format key: dzikir_{kategori}_{YYYY-MM-DD}_{id}
      final parts = key.split('_');
      if (parts.length < 4) continue;
      try {
        // Ambil bagian tanggal (index 2 setelah dzikir + kategori)
        final dateStr = parts[2]; // YYYY-MM-DD
        final dateParts = dateStr.split('-');
        if (dateParts.length != 3) continue;
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        if (date.isBefore(cutoff)) toDelete.add(key);
      } catch (_) {
        continue;
      }
    }

    for (final key in toDelete) {
      await prefs.remove(key);
    }
  }
}