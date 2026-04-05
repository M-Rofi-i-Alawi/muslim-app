import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/doa_viewmodel.dart';
import 'doa_detail_page.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kOrange    = Color(0xFFE8650A); // warna aksen Doa — oranye hangat
const _kBg        = Color(0xFFF2F4F7);

class DoaListPage extends StatefulWidget {
  const DoaListPage({super.key});

  @override
  State<DoaListPage> createState() => _DoaListPageState();
}

class _DoaListPageState extends State<DoaListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaViewModel>().getDoa();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<DoaViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              // ── APP BAR ───────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: _kTealDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text('Doa Harian',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                centerTitle: true,
              ),

              // ── SEARCH BAR ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) {
                      vm.searchDoa(v);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari doa...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: _kTeal),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                vm.searchDoa('');
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: _kTeal, width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── HERO BANNER ───────────────────────────────────
              SliverToBoxAdapter(child: _buildHeroBanner(vm)),

              // ── LOADING ───────────────────────────────────────
              if (vm.isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: _kTeal)),
                )

              // ── ERROR ─────────────────────────────────────────
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.grey, size: 60),
                        const SizedBox(height: 12),
                        Text('Gagal memuat doa',
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 15)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => vm.getDoa(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _kTeal),
                          child: Text('Coba Lagi',
                              style: GoogleFonts.poppins(
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )

              // ── EMPTY ─────────────────────────────────────────
              else if (vm.filteredDoa.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: Colors.grey[300], size: 70),
                        const SizedBox(height: 12),
                        Text('Doa tidak ditemukan',
                            style: GoogleFonts.poppins(
                                color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  ),
                )

              // ── LIST DOA ──────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        if (i >= vm.filteredDoa.length) return null;
                        return _buildDoaCard(
                            context, vm.filteredDoa[i], i);
                      },
                      childCount: vm.filteredDoa.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── HERO BANNER ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner(DoaViewModel vm) {
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
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Doa Harian',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(
                  vm.filteredDoa.isNotEmpty
                      ? '${vm.filteredDoa.length} doa tersedia'
                      : 'Koleksi doa sehari-hari',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Dekorasi tulisan Arab
          Text('الدعاء',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 28,
                  fontFamily: 'serif')),
        ],
      ),
    );
  }

  // ─── DOA CARD ─────────────────────────────────────────────────────────────
  Widget _buildDoaCard(BuildContext context, dynamic doa, int index) {
    // Warna icon bergilir agar tidak monoton
    final colors = [
      _kTeal,
      _kOrange,
      const Color(0xFF7B1FA2),
      const Color(0xFF1565C0),
      const Color(0xFF388E3C),
      const Color(0xFFF57F17),
    ];
    final color = colors[index % colors.length];

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
                builder: (_) => DoaDetailPage(doa: doa)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: color, size: 24),
                ),
                const SizedBox(width: 14),

                // Judul doa
                Expanded(
                  child: Text(
                    doa.judul,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),

                // Arrow
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}