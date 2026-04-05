import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan bookmark ayat dan riwayat terakhir dibaca
/// Menggunakan SharedPreferences agar data persisten
class QuranBookmarkService {
  static const _keyBookmarks = 'quran_bookmarks';
  static const _keyLastRead  = 'quran_last_read';

  // ─── SINGLETON ────────────────────────────────────────────────────────────
  static final QuranBookmarkService _instance = QuranBookmarkService._();
  factory QuranBookmarkService() => _instance;
  QuranBookmarkService._();

  // =========================================================================
  // BOOKMARK
  // =========================================================================

  /// Ambil semua bookmark yang tersimpan
  Future<List<QuranBookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_keyBookmarks) ?? [];
    return raw
        .map((e) => QuranBookmark.fromJson(json.decode(e)))
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // terbaru di atas
  }

  /// Cek apakah ayat sudah di-bookmark
  Future<bool> isBookmarked(int nomorSurat, int nomorAyat) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (b) => b.nomorSurat == nomorSurat && b.nomorAyat == nomorAyat,
    );
  }

  /// Tambah bookmark
  Future<void> addBookmark(QuranBookmark bookmark) async {
    final prefs     = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    // Hindari duplikat
    bookmarks.removeWhere(
      (b) => b.nomorSurat == bookmark.nomorSurat &&
             b.nomorAyat  == bookmark.nomorAyat,
    );
    bookmarks.insert(0, bookmark);

    await prefs.setStringList(
      _keyBookmarks,
      bookmarks.map((b) => json.encode(b.toJson())).toList(),
    );
  }

  /// Hapus bookmark
  Future<void> removeBookmark(int nomorSurat, int nomorAyat) async {
    final prefs     = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    bookmarks.removeWhere(
      (b) => b.nomorSurat == nomorSurat && b.nomorAyat == nomorAyat,
    );

    await prefs.setStringList(
      _keyBookmarks,
      bookmarks.map((b) => json.encode(b.toJson())).toList(),
    );
  }

  /// Toggle bookmark — tambah jika belum ada, hapus jika sudah ada
  Future<bool> toggleBookmark(QuranBookmark bookmark) async {
    final already = await isBookmarked(bookmark.nomorSurat, bookmark.nomorAyat);
    if (already) {
      await removeBookmark(bookmark.nomorSurat, bookmark.nomorAyat);
      return false;
    } else {
      await addBookmark(bookmark);
      return true;
    }
  }

  // =========================================================================
  // LAST READ
  // =========================================================================

  /// Simpan riwayat terakhir dibaca
  Future<void> saveLastRead(QuranLastRead lastRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRead, json.encode(lastRead.toJson()));
  }

  /// Ambil riwayat terakhir dibaca
  Future<QuranLastRead?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_keyLastRead);
    if (raw == null) return null;
    return QuranLastRead.fromJson(json.decode(raw));
  }

  /// Hapus riwayat terakhir dibaca
  Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastRead);
  }
}

// ─────────────────────────────────────────────
// MODEL: Bookmark
// ─────────────────────────────────────────────
class QuranBookmark {
  final int    nomorSurat;
  final String namaSurat;
  final int    nomorAyat;
  final String teksArab;
  final String terjemahan;
  final DateTime savedAt;

  QuranBookmark({
    required this.nomorSurat,
    required this.namaSurat,
    required this.nomorAyat,
    required this.teksArab,
    required this.terjemahan,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'nomorSurat':  nomorSurat,
    'namaSurat':   namaSurat,
    'nomorAyat':   nomorAyat,
    'teksArab':    teksArab,
    'terjemahan':  terjemahan,
    'savedAt':     savedAt.toIso8601String(),
  };

  factory QuranBookmark.fromJson(Map<String, dynamic> j) => QuranBookmark(
    nomorSurat:  j['nomorSurat'],
    namaSurat:   j['namaSurat'],
    nomorAyat:   j['nomorAyat'],
    teksArab:    j['teksArab'],
    terjemahan:  j['terjemahan'],
    savedAt:     DateTime.parse(j['savedAt']),
  );
}

// ─────────────────────────────────────────────
// MODEL: Last Read
// ─────────────────────────────────────────────
class QuranLastRead {
  final int    nomorSurat;
  final String namaSurat;
  final int    nomorAyat;
  final DateTime readAt;

  QuranLastRead({
    required this.nomorSurat,
    required this.namaSurat,
    required this.nomorAyat,
    DateTime? readAt,
  }) : readAt = readAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'nomorSurat': nomorSurat,
    'namaSurat':  namaSurat,
    'nomorAyat':  nomorAyat,
    'readAt':     readAt.toIso8601String(),
  };

  factory QuranLastRead.fromJson(Map<String, dynamic> j) => QuranLastRead(
    nomorSurat: j['nomorSurat'],
    namaSurat:  j['namaSurat'],
    nomorAyat:  j['nomorAyat'],
    readAt:     DateTime.parse(j['readAt']),
  );
}