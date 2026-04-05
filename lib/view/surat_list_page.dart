import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/surat_viewmodel.dart';
import 'surat_detail_page.dart';
import '../services/quran_bookmark_service.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

// Data pembagian juz (nomor surat & ayat awal setiap juz)
const List<Map<String, dynamic>> _juzData = [
  {'juz': 1,  'surat': 1,  'ayat': 1,   'nama': 'Al-Fatihah 1 - Al-Baqarah 141'},
  {'juz': 2,  'surat': 2,  'ayat': 142,  'nama': 'Al-Baqarah 142 - 252'},
  {'juz': 3,  'surat': 2,  'ayat': 253,  'nama': 'Al-Baqarah 253 - Ali Imran 92'},
  {'juz': 4,  'surat': 3,  'ayat': 93,   'nama': 'Ali Imran 93 - An-Nisa 23'},
  {'juz': 5,  'surat': 4,  'ayat': 24,   'nama': 'An-Nisa 24 - 147'},
  {'juz': 6,  'surat': 4,  'ayat': 148,  'nama': 'An-Nisa 148 - Al-Maidah 81'},
  {'juz': 7,  'surat': 5,  'ayat': 82,   'nama': 'Al-Maidah 82 - Al-Anam 110'},
  {'juz': 8,  'surat': 6,  'ayat': 111,  'nama': 'Al-Anam 111 - Al-Araf 87'},
  {'juz': 9,  'surat': 7,  'ayat': 88,   'nama': 'Al-Araf 88 - Al-Anfal 40'},
  {'juz': 10, 'surat': 8,  'ayat': 41,   'nama': 'Al-Anfal 41 - At-Taubah 92'},
  {'juz': 11, 'surat': 9,  'ayat': 93,   'nama': 'At-Taubah 93 - Hud 5'},
  {'juz': 12, 'surat': 11, 'ayat': 6,    'nama': 'Hud 6 - Yusuf 52'},
  {'juz': 13, 'surat': 12, 'ayat': 53,   'nama': 'Yusuf 53 - Ibrahim 52'},
  {'juz': 14, 'surat': 15, 'ayat': 1,    'nama': 'Al-Hijr 1 - An-Nahl 128'},
  {'juz': 15, 'surat': 17, 'ayat': 1,    'nama': 'Al-Isra 1 - Al-Kahfi 74'},
  {'juz': 16, 'surat': 18, 'ayat': 75,   'nama': 'Al-Kahfi 75 - Ta-Ha 135'},
  {'juz': 17, 'surat': 21, 'ayat': 1,    'nama': 'Al-Anbiya 1 - Al-Hajj 78'},
  {'juz': 18, 'surat': 23, 'ayat': 1,    'nama': 'Al-Muminun 1 - Al-Furqan 20'},
  {'juz': 19, 'surat': 25, 'ayat': 21,   'nama': 'Al-Furqan 21 - An-Naml 55'},
  {'juz': 20, 'surat': 27, 'ayat': 56,   'nama': 'An-Naml 56 - Al-Ankabut 45'},
  {'juz': 21, 'surat': 29, 'ayat': 46,   'nama': 'Al-Ankabut 46 - Al-Ahzab 30'},
  {'juz': 22, 'surat': 33, 'ayat': 31,   'nama': 'Al-Ahzab 31 - Ya-Sin 27'},
  {'juz': 23, 'surat': 36, 'ayat': 28,   'nama': 'Ya-Sin 28 - Az-Zumar 31'},
  {'juz': 24, 'surat': 39, 'ayat': 32,   'nama': 'Az-Zumar 32 - Fussilat 46'},
  {'juz': 25, 'surat': 41, 'ayat': 47,   'nama': 'Fussilat 47 - Al-Jasiyah 37'},
  {'juz': 26, 'surat': 46, 'ayat': 1,    'nama': 'Al-Ahqaf 1 - Az-Zariyat 30'},
  {'juz': 27, 'surat': 51, 'ayat': 31,   'nama': 'Az-Zariyat 31 - Al-Hadid 29'},
  {'juz': 28, 'surat': 58, 'ayat': 1,    'nama': 'Al-Mujadila 1 - At-Tahrim 12'},
  {'juz': 29, 'surat': 67, 'ayat': 1,    'nama': 'Al-Mulk 1 - Al-Mursalat 50'},
  {'juz': 30, 'surat': 78, 'ayat': 1,    'nama': 'An-Naba 1 - An-Nas 6'},
];

class SuratListPage extends StatefulWidget {
  const SuratListPage({super.key});

  @override
  State<SuratListPage> createState() => _SuratListPageState();
}

class _SuratListPageState extends State<SuratListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  QuranLastRead?        _lastRead;
  List<QuranBookmark>   _bookmarks = [];
  final _svc = QuranBookmarkService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuratViewModel>().getSurat();
    });
    _loadData();
    // Refresh bookmark ketika pindah ke tab Bookmark
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 2) _loadData();
    });
  }

  Future<void> _loadData() async {
    final lastRead  = await _svc.getLastRead();
    final bookmarks = await _svc.getBookmarks();
    if (mounted) setState(() {
      _lastRead  = lastRead;
      _bookmarks = bookmarks;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<SuratViewModel>(
        builder: (context, vm, _) {
          final allSurat = vm.suratList;
          final filtered = _query.isEmpty
              ? allSurat
              : allSurat.where((s) {
                  final q = _query.toLowerCase();
                  return s.namaLatin.toLowerCase().contains(q) ||
                      s.arti.toLowerCase().contains(q) ||
                      s.nomor.toString().contains(q);
                }).toList();

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              // ── APP BAR ─────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: _kTealDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text('Al-Qur\'an',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                centerTitle: true,
                bottom: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: _kGold,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle:
                      GoogleFonts.poppins(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Surat'),
                    Tab(text: 'Juz'),
                    Tab(text: 'Bookmark'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                // ── TAB 1: SURAT ──────────────────────────────
                _buildSuratTab(vm, filtered),

                // ── TAB 2: JUZ ────────────────────────────────
                _buildJuzTab(vm),

                // ── TAB 3: BOOKMARK ───────────────────────────
                _buildBookmarkTab(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // TAB 1 — SURAT
  // =========================================================================
  Widget _buildSuratTab(SuratViewModel vm, List filtered) {
    return CustomScrollView(
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari surat, nomor, atau arti...',
                hintStyle:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: _kTeal),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Hero banner
        SliverToBoxAdapter(child: _buildHeroBanner(vm.suratList.length)),

        // Last read card
        if (_lastRead != null)
          SliverToBoxAdapter(child: _buildLastReadCard(vm)),

        // Loading
        if (vm.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _kTeal)),
          )
        // Error
        else if (vm.error.isNotEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Colors.grey, size: 60),
                  const SizedBox(height: 12),
                  Text('Gagal memuat',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => vm.getSurat(),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: _kTeal),
                    child: Text('Coba Lagi',
                        style:
                            GoogleFonts.poppins(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
        // List surat
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  if (i >= filtered.length) return null;
                  return _buildSuratCard(filtered[i]);
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // TAB 2 — JUZ
  // =========================================================================
  Widget _buildJuzTab(SuratViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _juzData.length,
      itemBuilder: (_, i) {
        final juz = _juzData[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _kTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${juz['juz']}',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            title: Text(
              'Juz ${juz['juz']}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              juz['nama'],
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: Colors.grey),
            onTap: () {
              // Cari surat berdasarkan nomor surat awal juz
              final surat = vm.suratList.firstWhere(
                (s) => s.nomor == juz['surat'],
                orElse: () => vm.suratList.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuratDetailPage(surat: surat),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 3 — BOOKMARK
  // =========================================================================
  Widget _buildBookmarkTab(SuratViewModel vm) {
    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded,
                color: Colors.grey[300], size: 80),
            const SizedBox(height: 16),
            Text('Belum ada bookmark',
                style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Tandai ayat favoritmu saat membaca',
                style: GoogleFonts.poppins(
                    color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _bookmarks.length,
      itemBuilder: (_, i) {
        final bm = _bookmarks[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bookmark_rounded,
                  color: _kGold, size: 24),
            ),
            title: Text(
              '${bm.namaSurat} · Ayat ${bm.nomorAyat}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  bm.teksArab,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'serif',
                      color: _kTeal,
                      height: 1.8),
                ),
                Text(
                  bm.terjemahan,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 20),
              onPressed: () async {
                await _svc.removeBookmark(bm.nomorSurat, bm.nomorAyat);
                _loadData();
              },
            ),
            onTap: () {
              // Buka surat langsung ke posisi ayat yang di-bookmark
              final surat = vm.suratList.firstWhere(
                (s) => s.nomor == bm.nomorSurat,
                orElse: () => vm.suratList.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuratDetailPage(
                    surat: surat,
                    scrollToAyat: bm.nomorAyat,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ─── HERO BANNER ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner(int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kTeal.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Al-Qur\'an Digital',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text('${total > 0 ? total : 114} Surat · Lengkap',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Text('القرآن',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 28,
                  fontFamily: 'serif')),
        ],
      ),
    );
  }

  // ─── LAST READ CARD ───────────────────────────────────────────────────────
  Widget _buildLastReadCard(SuratViewModel vm) {
    final lr = _lastRead!;
    return GestureDetector(
      onTap: () {
        final surat = vm.suratList.firstWhere(
          (s) => s.nomor == lr.nomorSurat,
          orElse: () => vm.suratList.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SuratDetailPage(
              surat: surat,
              scrollToAyat: lr.nomorAyat,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _kGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGold.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: _kGold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lanjutkan membaca',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _kGold,
                          fontWeight: FontWeight.w600)),
                  Text(
                    '${lr.namaSurat} · Ayat ${lr.nomorAyat}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: _kGold, size: 16),
          ],
        ),
      ),
    );
  }

  // ─── SURAT CARD ───────────────────────────────────────────────────────────
  Widget _buildSuratCard(dynamic surat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SuratDetailPage(surat: surat),
            ),
          ).then((_) => _loadData()), // refresh last read setelah balik
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Nomor
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _kTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('${surat.nomor}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 14),

                // Nama & chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(surat.namaLatin,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6, runSpacing: 4,
                        children: [
                          _tag(surat.arti,
                              const Color(0xFFE8F5F2), _kTeal),
                          _tag('${surat.jumlahAyat} Ayat',
                              const Color(0xFFFFF3E0), _kGold),
                          _tag(_cap(surat.tempatTurun),
                              const Color(0xFFE8F5E9),
                              const Color(0xFF388E3C)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Nama Arab
                SizedBox(
                  width: 72,
                  child: Text(
                    surat.nama,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _kTeal,
                        fontSize: 20,
                        fontFamily: 'serif',
                        height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor)),
    );
  }

  String _cap(String s) => s.isEmpty
      ? s
      : s[0].toUpperCase() + s.substring(1).toLowerCase();
}