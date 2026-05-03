import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../viewmodel/asmaul_husna_viewmodel.dart';
import '../model/asmaul_husna_model.dart';
import '../utils/theme_helper.dart';

const _kTeal = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold = Color(0xFFE8A020);

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});
  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<AsmaulHusnaViewModel>().fetchAsmaulHusna());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressCard(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<AsmaulHusnaViewModel>(
                builder: (_, vm, __) {
                  if (vm.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: _kTeal));
                  }
                  if (vm.asmaulHusnaList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 72, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context).tidakAdaHasil,
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: vm.asmaulHusnaList.length,
                    itemBuilder: (_, i) =>
                        _buildNameCard(vm.asmaulHusnaList[i]),
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
          colors: [_kTealDark, _kTeal, _kTealLight],
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
                Text(AppLocalizations.of(context).asmaulHusnaTitle,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(AppLocalizations.of(context).asmaulHusnaSubtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Text('الأسماء\nالحسنى',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 16,
                  fontFamily: 'serif',
                  height: 1.5)),
        ],
      ),
    );
  }

  // ─── PROGRESS CARD ────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Consumer<AsmaulHusnaViewModel>(
      builder: (_, vm, __) {
        final progress =
            vm.totalCount > 0 ? vm.memorizedCount / vm.totalCount : 0.0;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).progressHafalan,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text('${vm.memorizedCount} dari ${vm.totalCount} nama',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _kGold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Consumer<AsmaulHusnaViewModel>(
        builder: (_, vm, __) => TextField(
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).cariNamaAllah,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            prefixIcon: const Icon(Icons.search_rounded, color: _kTeal),
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: vm.setSearchQuery,
        ),
      ),
    );
  }

  // ─── NAME CARD ────────────────────────────────────────────────────────────
  Widget _buildNameCard(AsmaulHusnaModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: item.isMemorized
            ? Border.all(color: _kGold.withOpacity(0.4), width: 1.5)
            : null,
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
          onTap: () => _showDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Nomor badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('${item.number}',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),

                // Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.arab,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w600,
                              color:
                                  context.colors.onSurface)), // ✅ tanpa const
                      const SizedBox(height: 3),
                      Text(item.latin,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface)),
                      Text(item.arti,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: context.colors.textHint)),
                    ],
                  ),
                ),

                // Badge hafal
                if (item.isMemorized)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _kGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── DETAIL BOTTOM SHEET ──────────────────────────────────────────────────
  void _showDetail(AsmaulHusnaModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Nomor badge besar
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _kTeal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('${item.number}',
                              style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Arab besar
                    Center(
                      child: Text(item.arab,
                          style: TextStyle(
                              fontSize: 48,
                              fontFamily: 'serif',
                              height: 1.5,
                              color: context.colors.onSurface)),
                    ),
                    const SizedBox(height: 12),

                    // Latin
                    Center(
                      child: Text(item.latin,
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _kTeal)),
                    ),
                    const SizedBox(height: 6),

                    // Arti
                    Center(
                      child: Text(item.arti,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: context.colors.textSecondary)),
                    ),
                    const SizedBox(height: 20),

                    // Penjelasan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _kTeal.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kTeal.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(AppLocalizations.of(context).pelajaran,
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _kTeal)),
                          ),
                          const SizedBox(height: 10),
                          Text(item.penjelasan,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.8,
                                  color: context.colors.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol hafal & salin
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<AsmaulHusnaViewModel>(
                            builder: (_, vm, __) => ElevatedButton.icon(
                              onPressed: () => vm.toggleMemorized(item.id),
                              icon: Icon(
                                item.isMemorized
                                    ? Icons.check_circle_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 16,
                                color: item.isMemorized ? Colors.white : _kGold,
                              ),
                              label: Text(
                                item.isMemorized
                                    ? 'Sudah Hafal'
                                    : 'Tandai Hafal',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: item.isMemorized
                                        ? Colors.white
                                        : _kGold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.isMemorized
                                    ? _kGold
                                    : _kGold.withOpacity(0.1),
                                padding: const EdgeInsets.all(14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text:
                                    '${item.arab}\n${item.latin}\n${item.arti}\n\n${item.penjelasan}',
                              ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context).berhasilDisalin,
                                    style: GoogleFonts.poppins()),
                                backgroundColor: _kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            icon: const Icon(Icons.copy_rounded,
                                size: 16, color: Colors.white),
                            label: Text(AppLocalizations.of(context).salin,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kTeal,
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
}
