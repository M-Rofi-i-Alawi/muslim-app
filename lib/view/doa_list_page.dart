import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme_helper.dart';
import '../viewmodel/doa_viewmodel.dart';
import 'doa_detail_page.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kOrange    = Color(0xFFE8650A);

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
    // FIX: adaptive background
    final c = context.colors;
    return Scaffold(
      // backgroundColor: auto dari ThemeData.scaffoldBackgroundColor
      body: Consumer<DoaViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: _kTealDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: TrText('Doa Harian',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                centerTitle: true,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) { vm.searchDoa(v); setState(() {}); },
                    style: TextStyle(color: c.onSurface),
                    decoration: InputDecoration(
                      hintText: context.tr('Cari doa...'),
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: c.textHint),
                      prefixIcon: const Icon(Icons.search_rounded, color: _kTeal),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: c.textHint),
                              onPressed: () { _searchCtrl.clear(); vm.searchDoa(''); setState(() {}); },
                            )
                          : null,
                      filled: true,
                      // FIX: Colors.white → c.surface
                      fillColor: c.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _kTeal, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: _buildHeroBanner(vm)),

              if (vm.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _kTeal)))
              else if (vm.error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.wifi_off_rounded, color: c.textHint, size: 60),
                    const SizedBox(height: 12),
                    TrText('Gagal memuat doa', style: GoogleFonts.poppins(color: c.textSecondary, fontSize: 15)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => vm.getDoa(),
                      style: ElevatedButton.styleFrom(backgroundColor: _kTeal),
                      child: TrText('Coba Lagi', style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ])),
                )
              else if (vm.filteredDoa.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off_rounded, color: c.textHint, size: 70),
                    const SizedBox(height: 12),
                    TrText('Doa tidak ditemukan', style: GoogleFonts.poppins(color: c.textSecondary, fontSize: 15)),
                  ])),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) { if (i >= vm.filteredDoa.length) return null; return _buildDoaCard(context, vm.filteredDoa[i], i); },
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

  Widget _buildHeroBanner(DoaViewModel vm) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _kTeal.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TrText('Doa Harian', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(vm.filteredDoa.isNotEmpty ? '${vm.filteredDoa.length} ${context.tr('doa tersedia')}' : context.tr('Koleksi doa sehari-hari'),
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        ])),
        Text('الدعاء', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 28, fontFamily: 'serif')),
      ]),
    );
  }

  Widget _buildDoaCard(BuildContext context, dynamic doa, int index) {
    final c = context.colors;
    final colors = [
      _kTeal, _kOrange,
      const Color(0xFF7B1FA2), const Color(0xFF1565C0),
      const Color(0xFF388E3C), const Color(0xFFF57F17),
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        // FIX: Colors.white → c.surface
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoaDetailPage(doa: doa))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.menu_book_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(context.tr(doa.judul),
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      // FIX: hardcoded 0xFF1A1A2E → c.onSurface
                      color: c.onSurface))),
              // FIX: Colors.grey[400] → c.textHint
              Icon(Icons.chevron_right_rounded, color: c.textHint, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}