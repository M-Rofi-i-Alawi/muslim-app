import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/hadist_viewmodel.dart';
import '../model/hadist_model.dart';
import '../utils/theme_helper.dart';

class HadistPage extends StatefulWidget {
  const HadistPage({super.key});
  @override
  State<HadistPage> createState() => _HadistPageState();
}

class _HadistPageState extends State<HadistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _selectedTab = _tabCtrl.index);
      }
    });
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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Consumer<HadistViewModel>(
              builder: (_, vm, __) => vm.hadistOfDay == null
                  ? const SizedBox.shrink()
                  : _buildHadistOfDay(vm.hadistOfDay!),
            ),
            _buildTabBar(c),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Consumer<HadistViewModel>(
                builder: (_, vm, __) => _buildSearchAndFilter(vm, c),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<HadistViewModel>(
                builder: (_, vm, __) {
                  if (vm.isLoading) {
                    return Center(
                        child: CircularProgressIndicator(color: kTeal));
                  }
                  final list = _selectedTab == 0
                      ? vm.hadistList
                      : vm.getFavorites();
                  if (list.isEmpty) return _buildEmptyState(c);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _buildCard(list[i], c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kTealDark, kTeal, kTealLight],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText('Hadist Arbain Nawawi',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                TrText('40 Hadist pilihan untuk kehidupan sehari-hari',
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

  // ─── HADIST OF THE DAY ────────────────────────────────────────────────────
  Widget _buildHadistOfDay(HadistModel hadist) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kGold, kGold.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kGold.withOpacity(0.3),
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
                    TrText('Hadist Hari Ini',
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
                      child: Text('${context.tr('Hadist')} ${hadist.number}',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: kGold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(hadist.arti,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.white, height: 1.6),
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

  // ─── CUSTOM TAB BAR ───────────────────────────────────────────────────────
  Widget _buildTabBar(AppColors c) {
    final tabs = [context.tr('Semua Hadist'), context.tr('Favorit')];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: c.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                _tabCtrl.animateTo(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TrText(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── SEARCH & FILTER ──────────────────────────────────────────────────────
  Widget _buildSearchAndFilter(HadistViewModel vm, AppColors c) {
    return Column(
      children: [
        TextField(
          style: TextStyle(color: c.onSurface),
          decoration: InputDecoration(
            hintText: context.tr('Cari hadist...'),
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: c.textHint),
            prefixIcon: const Icon(Icons.search_rounded, color: kTeal),
            filled: true,
            fillColor: c.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
              final tema = vm.temaList[i];
              final isSelected = vm.selectedTema == tema;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(tema,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected ? Colors.white : c.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                  selected: isSelected,
                  onSelected: (_) => vm.setSelectedTema(tema),
                  backgroundColor: c.surface,
                  selectedColor: kTeal,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: isSelected ? kTeal : c.border),
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

  // ─── CARD ─────────────────────────────────────────────────────────────────
  Widget _buildCard(HadistModel hadist, AppColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: c.isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: c.shadow,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kTeal,
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
                          Text('${context.tr('Hadist')} ${hadist.number}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: c.onSurface)),
                          Text(hadist.tema,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: kTeal)),
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
                              : c.textHint,
                          size: 22,
                        ),
                        onPressed: () => vm.toggleFavorite(hadist.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(hadist.arti,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.6,
                        color: c.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('${context.tr('Rawi')}: ${hadist.rawi}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: c.textHint,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: c.textHint),
          const SizedBox(height: 12),
          Text(
            _selectedTab == 0
                ? context.tr('Tidak ada hadist ditemukan')
                : context.tr('Belum ada hadist favorit'),
            style: GoogleFonts.poppins(
                fontSize: 15, color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── DETAIL BOTTOM SHEET ──────────────────────────────────────────────────
  void _showDetail(HadistModel hadist) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [kTealDark, kTeal]),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TrText('Hadist Arbain',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('${context.tr('Rawi')}: ${hadist.rawi}',
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
                    _hadistSection(c, context.tr('Teks Arab'),
                        kTeal.withOpacity(0.06),
                        Text(hadist.arab,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'serif',
                                height: 2.2,
                                color: c.onSurface))),
                    _hadistSection(c, context.tr('Transliterasi Latin'),
                        const Color(0xFF7B1FA2).withOpacity(0.06),
                        Text(hadist.latin,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.8,
                                fontStyle: FontStyle.italic,
                                color: c.textSecondary))),
                    _hadistSection(c, context.tr('Terjemahan'),
                        kGold.withOpacity(0.08),
                        Text(hadist.arti,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.8,
                                color: c.onSurface))),
                    _hadistSection(c, context.tr('Penjelasan'),
                        kTeal.withOpacity(0.05),
                        Text(hadist.penjelasan,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.8,
                                color: c.textSecondary))),
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
                                content: TrText('Hadist disalin!',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: TrText('Salin',
                                style: GoogleFonts.poppins(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kTeal,
                              side: const BorderSide(color: kTeal),
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded,
                                size: 16, color: Colors.white),
                            label: TrText('Tutup',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              padding: const EdgeInsets.all(14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
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

  Widget _hadistSection(AppColors c, String title, Color bg, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TrText(title,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kTeal)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.isDark ? c.surfaceVariant : bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kTeal.withOpacity(0.1)),
          ),
          child: child,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}