import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/hadist_viewmodel.dart';
import '../model/hadist_model.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

class HadistPage extends StatefulWidget {
  const HadistPage({super.key});
  @override
  State<HadistPage> createState() => _HadistPageState();
}

class _HadistPageState extends State<HadistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    Future.microtask(
        () => context.read<HadistViewModel>().fetchHadist());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Hadist of the Day
            Consumer<HadistViewModel>(
              builder: (_, vm, __) => vm.hadistOfDay == null
                  ? const SizedBox.shrink()
                  : _buildHadistOfDay(vm.hadistOfDay!),
            ),

            // Tab Bar
            _buildTabBar(),

            // Search & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Consumer<HadistViewModel>(
                builder: (_, vm, __) => _buildSearchAndFilter(vm),
              ),
            ),

            const SizedBox(height: 8),

            // List
            Expanded(
              child: Consumer<HadistViewModel>(
                builder: (_, vm, __) {
                  if (vm.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: _kTeal));
                  }
                  final list = _tabCtrl.index == 0
                      ? vm.hadistList
                      : vm.getFavorites();
                  if (list.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _buildCard(list[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hadist Arbain Nawawi',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('40 Hadist pilihan untuk kehidupan sehari-hari',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Text('الحديث',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 22,
                  fontFamily: 'serif')),
        ],
      ),
    );
  }

  Widget _buildHadistOfDay(HadistModel hadist) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGold, _kGold.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _kGold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(hadist),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Hadist Hari Ini',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Hadist ${hadist.number}',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _kGold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(hadist.arti,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.6),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('— ${hadist.rawi}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_kTealDark, _kTeal]),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Semua Hadist'),
          Tab(text: 'Favorit ❤️'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(HadistViewModel vm) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari hadist...',
            hintStyle:
                GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            prefixIcon:
                const Icon(Icons.search_rounded, color: _kTeal),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: vm.setSearchQuery,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vm.temaList.length,
            itemBuilder: (_, i) {
              final tema       = vm.temaList[i];
              final isSelected = vm.selectedTema == tema;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(tema,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                  selected: isSelected,
                  onSelected: (_) => vm.setSelectedTema(tema),
                  backgroundColor: Colors.white,
                  selectedColor: _kTeal,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? _kTeal
                          : Colors.grey[300]!,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(HadistModel hadist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetail(hadist),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _kTeal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('${hadist.number}',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hadist ${hadist.number}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(hadist.tema,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: _kTeal)),
                        ],
                      ),
                    ),
                    Consumer<HadistViewModel>(
                      builder: (_, vm, __) => IconButton(
                        icon: Icon(
                          hadist.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: hadist.isFavorite
                              ? Colors.red
                              : Colors.grey[400],
                          size: 22,
                        ),
                        onPressed: () =>
                            vm.toggleFavorite(hadist.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(hadist.arti,
                    style: GoogleFonts.poppins(
                        fontSize: 13, height: 1.6,
                        color: Colors.grey[800]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('Rawi: ${hadist.rawi}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _tabCtrl.index == 0
                ? 'Tidak ada hadist ditemukan'
                : 'Belum ada hadist favorit',
            style: GoogleFonts.poppins(
                fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDetail(HadistModel hadist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kTealDark, _kTeal]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Text('${hadist.number}',
                              style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Hadist Arbain',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('Rawi: ${hadist.rawi}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white
                                            .withOpacity(0.9))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _hadistSection('Teks Arab', _kTeal.withOpacity(0.06),
                        Text(hadist.arab,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'serif',
                                height: 2.2))),

                    _hadistSection('Transliterasi Latin',
                        const Color(0xFF7B1FA2).withOpacity(0.06),
                        Text(hadist.latin,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.8,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700]))),

                    _hadistSection('Terjemahan',
                        _kGold.withOpacity(0.08),
                        Text(hadist.arti,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.8,
                                color: Colors.grey[800]))),

                    _hadistSection('Penjelasan',
                        _kTeal.withOpacity(0.05),
                        Text(hadist.penjelasan,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.8,
                                color: Colors.grey[700]))),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text:
                                    '${hadist.arab}\n\n${hadist.latin}\n\n${hadist.arti}\n\nRawi: ${hadist.rawi}',
                              ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Hadist disalin!',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: _kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            icon: const Icon(Icons.copy_rounded,
                                size: 16),
                            label: Text('Salin',
                                style:
                                    GoogleFonts.poppins(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kTeal,
                              side: const BorderSide(color: _kTeal),
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded,
                                size: 16, color: Colors.white),
                            label: Text('Tutup',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kTeal,
                              padding: const EdgeInsets.all(14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadistSection(String title, Color bg, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kTeal)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kTeal.withOpacity(0.1)),
          ),
          child: child,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}