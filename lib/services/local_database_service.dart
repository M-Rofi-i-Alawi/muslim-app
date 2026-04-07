import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/ramadhan_model.dart';

/// Database lokal menggunakan sqflite untuk menyimpan data Ramadhan
/// Data tersimpan permanen di storage HP — tidak hilang saat app ditutup
class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._();

  Database? _db;

  // ─── INIT ─────────────────────────────────────────────────────────────────
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'muslim_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Ramadhan
    await db.execute('''
      CREATE TABLE ramadhan_entries (
        id              TEXT PRIMARY KEY,
        date            TEXT NOT NULL,
        ramadhan_day    INTEGER NOT NULL,
        puasa           INTEGER DEFAULT 0,
        shalat_subuh    INTEGER DEFAULT 0,
        shalat_dzuhur   INTEGER DEFAULT 0,
        shalat_ashar    INTEGER DEFAULT 0,
        shalat_maghrib  INTEGER DEFAULT 0,
        shalat_isya     INTEGER DEFAULT 0,
        shalat_tarawih  INTEGER DEFAULT 0,
        shalat_tahajud  INTEGER DEFAULT 0,
        tadarus_juz     INTEGER DEFAULT 0,
        tadarus_halaman INTEGER DEFAULT 0,
        tadarus_surah   TEXT DEFAULT '',
        infak_amount    REAL DEFAULT 0,
        infak_note      TEXT DEFAULT '',
        ceramah_title   TEXT DEFAULT '',
        ceramah_ustadz  TEXT DEFAULT '',
        ceramah_rangkuman TEXT DEFAULT '',
        ceramah_poin    TEXT DEFAULT '[]',
        catatan_harian  TEXT DEFAULT '',
        doa_terkabul    TEXT DEFAULT '',
        momen_spesial   TEXT DEFAULT '',
        refleksi        TEXT DEFAULT '',
        pembelajaran    TEXT DEFAULT '',
        created_at      TEXT,
        updated_at      TEXT
      )
    ''');

    // Tabel untuk bookmark Al-Qur'an (backup dari SharedPreferences)
    await db.execute('''
      CREATE TABLE quran_bookmarks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_surat INTEGER NOT NULL,
        nama_surat  TEXT NOT NULL,
        nomor_ayat  INTEGER NOT NULL,
        teks_arab   TEXT DEFAULT '',
        terjemahan  TEXT DEFAULT '',
        saved_at    TEXT NOT NULL
      )
    ''');

    // Tabel tasbih history (opsional)
    await db.execute('''
      CREATE TABLE tasbih_history (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal     TEXT NOT NULL,
        jumlah      INTEGER NOT NULL,
        created_at  TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Untuk versi mendatang
  }

  // =========================================================================
  // RAMADHAN ENTRIES
  // =========================================================================

  /// Simpan atau update entry Ramadhan
  Future<void> saveRamadhanEntry(RamadhanEntry entry) async {
    final db  = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'ramadhan_entries',
      {
        'id':               entry.id,
        'date':             entry.date.toIso8601String(),
        'ramadhan_day':     entry.ramadhanDay,
        'puasa':            entry.puasa ? 1 : 0,
        'shalat_subuh':     entry.shalatSubuh   ? 1 : 0,
        'shalat_dzuhur':    entry.shalatDzuhur  ? 1 : 0,
        'shalat_ashar':     entry.shalatAshar   ? 1 : 0,
        'shalat_maghrib':   entry.shalatMaghrib ? 1 : 0,
        'shalat_isya':      entry.shalatIsya    ? 1 : 0,
        'shalat_tarawih':   entry.shalatTarawih ? 1 : 0,
        'shalat_tahajud':   entry.shalatTahajud ? 1 : 0,
        'tadarus_juz':      entry.tadarusJuz,
        'tadarus_halaman':  entry.tadarusHalaman,
        'tadarus_surah':    entry.tadarusSurah,
        'infak_amount':     entry.infakAmount,
        'infak_note':       entry.infakNote,
        'ceramah_title':    entry.ceramahTitle,
        'ceramah_ustadz':   entry.ceramahUstadz,
        'ceramah_rangkuman': entry.ceramahRangkuman,
        'ceramah_poin':     json.encode(entry.ceramahPoinPenting),
        'catatan_harian':   entry.catatanHarian,
        'doa_terkabul':     entry.doaTerkabul,
        'momen_spesial':    entry.momenSpesial,
        'refleksi':         entry.refleksi,
        'pembelajaran':     entry.pembelajaran,
        'created_at':       now,
        'updated_at':       now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // upsert
    );
  }

  /// Ambil entry berdasarkan tanggal
  Future<RamadhanEntry?> getRamadhanEntryByDate(DateTime date) async {
    final db      = await database;
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

    final rows = await db.query(
      'ramadhan_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _rowToEntry(rows.first);
  }

  /// Ambil semua entry Ramadhan (diurutkan terbaru dulu)
  Future<List<RamadhanEntry>> getAllRamadhanEntries() async {
    final db   = await database;
    final rows = await db.query(
      'ramadhan_entries',
      orderBy: 'date DESC',
    );
    return rows.map(_rowToEntry).toList();
  }

  /// Hapus entry berdasarkan tanggal
  Future<void> deleteRamadhanEntry(DateTime date) async {
    final db      = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    await db.delete(
      'ramadhan_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );
  }

  /// Hapus semua data Ramadhan
  Future<void> clearAllRamadhanEntries() async {
    final db = await database;
    await db.delete('ramadhan_entries');
  }

  /// Hitung statistik Ramadhan
  Future<RamadhanStatistics> getRamadhanStatistics() async {
    final entries = await getAllRamadhanEntries();
    if (entries.isEmpty) return RamadhanStatistics();

    int puasaCount         = 0;
    int allShalatCount     = 0;
    int tarawihCount       = 0;
    int tahajudCount       = 0;
    int totalTadarusJuz    = 0;
    double totalInfak      = 0;
    int ceramahCount       = 0;

    for (final e in entries) {
      if (e.puasa)            puasaCount++;
      if (e.allShalatComplete) allShalatCount++;
      if (e.shalatTarawih)    tarawihCount++;
      if (e.shalatTahajud)    tahajudCount++;
      totalTadarusJuz        += e.tadarusJuz;
      totalInfak             += e.infakAmount;
      if (e.ceramahTitle.isNotEmpty) ceramahCount++;
    }

    return RamadhanStatistics(
      totalDays:            entries.length,
      puasaCount:           puasaCount,
      allShalatCompleteCount: allShalatCount,
      tarawihCount:         tarawihCount,
      tahajudCount:         tahajudCount,
      totalTadarusJuz:      totalTadarusJuz,
      totalInfak:           totalInfak,
      ceramahCount:         ceramahCount,
    );
  }

  // ─── ROW CONVERTER ────────────────────────────────────────────────────────
  RamadhanEntry _rowToEntry(Map<String, dynamic> row) {
    List<String> poin = [];
    try {
      poin = List<String>.from(json.decode(row['ceramah_poin'] ?? '[]'));
    } catch (_) {}

    return RamadhanEntry(
      id:                 row['id'],
      date:               DateTime.parse(row['date']),
      ramadhanDay:        row['ramadhan_day'],
      puasa:              row['puasa'] == 1,
      shalatSubuh:        row['shalat_subuh']   == 1,
      shalatDzuhur:       row['shalat_dzuhur']  == 1,
      shalatAshar:        row['shalat_ashar']   == 1,
      shalatMaghrib:      row['shalat_maghrib'] == 1,
      shalatIsya:         row['shalat_isya']    == 1,
      shalatTarawih:      row['shalat_tarawih'] == 1,
      shalatTahajud:      row['shalat_tahajud'] == 1,
      tadarusJuz:         row['tadarus_juz']    ?? 0,
      tadarusHalaman:     row['tadarus_halaman'] ?? 0,
      tadarusSurah:       row['tadarus_surah']  ?? '',
      infakAmount:        (row['infak_amount']  ?? 0).toDouble(),
      infakNote:          row['infak_note']     ?? '',
      ceramahTitle:       row['ceramah_title']  ?? '',
      ceramahUstadz:      row['ceramah_ustadz'] ?? '',
      ceramahRangkuman:   row['ceramah_rangkuman'] ?? '',
      ceramahPoinPenting: poin,
      catatanHarian:      row['catatan_harian'] ?? '',
      doaTerkabul:        row['doa_terkabul']   ?? '',
      momenSpesial:       row['momen_spesial']  ?? '',
      refleksi:           row['refleksi']       ?? '',
      pembelajaran:       row['pembelajaran']   ?? '',
    );
  }

  // =========================================================================
  // EXPORT / IMPORT
  // =========================================================================

  Future<String> exportRamadhanToJson() async {
    final entries = await getAllRamadhanEntries();
    final data    = entries.map((e) => e.toJson()).toList();
    return json.encode(data);
  }

  Future<void> importRamadhanFromJson(String jsonStr) async {
    final data    = json.decode(jsonStr) as List;
    final entries = data.map((d) => RamadhanEntry.fromJson(d)).toList();
    for (final entry in entries) {
      await saveRamadhanEntry(entry);
    }
  }

  // =========================================================================
  // CLOSE DB
  // =========================================================================
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}