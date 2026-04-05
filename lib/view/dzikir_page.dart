import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/dzikir_viewmodel.dart';
import '../model/dzikir_model.dart';

// ─────────────────────────────────────────────
// KONSTANTA — konsisten dengan seluruh app
// ─────────────────────────────────────────────
const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

// Warna per kategori — tetap dibedakan tapi harmonis dengan teal
const _kPagi    = Color(0xFF1976D2); // biru fajar
const _kPetang  = Color.fromARGB(255, 237, 155, 3); // oren
const _kShalat  = Color(0xFF00897B); // teal hijau (dekat dengan tema utama)

class DzikirPage extends StatefulWidget {
  const DzikirPage({super.key});

  @override
  State<DzikirPage> createState() => _DzikirPageState();
}

class _DzikirPageState extends State<DzikirPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(
        () => context.read<DzikirViewModel>().fetchAllDzikir());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: Consumer<DzikirViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: _kTeal));
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDzikirList(vm.dzikirPagi,    'pagi',   vm.pagiProgress,   vm.pagiTotal,   vm.pagiPercentage),
                      _buildDzikirList(vm.dzikirPetang,  'petang', vm.petangProgress, vm.petangTotal, vm.petangPercentage),
                      _buildDzikirList(vm.dzikirShalat,  'shalat', vm.shalatProgress, vm.shalatTotal, vm.shalatPercentage),
                    ],
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
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dzikir & Wirid',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Dzikir pagi, petang, dan setelah shalat',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          // Dekorasi Arab
          Text(
            'الذكر',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 24,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────────────────
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kTealDark, _kTeal],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '🌅 Pagi'),
          Tab(text: '🌆 Petang'),
          Tab(text: '🕌 Shalat'),
        ],
      ),
    );
  }

  // ─── LIST DZIKIR ──────────────────────────────────────────────────────────
  Widget _buildDzikirList(
    List<DzikirModel> dzikirList,
    String kategori,
    int progress,
    int total,
    double percentage,
  ) {
    final color = _categoryColor(kategori);
    return Column(
      children: [
        _buildProgressCard(progress, total, percentage, color, kategori),
        Expanded(
          child: dzikirList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: dzikirList.length,
                  itemBuilder: (_, i) =>
                      _buildDzikirCard(dzikirList[i], kategori, color),
                ),
        ),
      ],
    );
  }

  // ─── PROGRESS CARD ────────────────────────────────────────────────────────
  Widget _buildProgressCard(
    int progress,
    int total,
    double percentage,
    Color color,
    String kategori,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
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
                  Text('Progress Hari Ini',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    '$progress dari $total dzikir selesai',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (progress < total) ...[
            const SizedBox(height: 10),
            Consumer<DzikirViewModel>(
              builder: (context, vm, _) => TextButton.icon(
                onPressed: () => vm.resetAll(kategori),
                icon: const Icon(Icons.refresh_rounded,
                    size: 16, color: Colors.white),
                label: Text('Reset Semua',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── DZIKIR CARD ──────────────────────────────────────────────────────────
  Widget _buildDzikirCard(
      DzikirModel dzikir, String kategori, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dzikir.isCompleted
              ? color.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDzikirDetail(dzikir, kategori, color),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dzikir.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    if (dzikir.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text('Selesai',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Arab
                Text(
                  dzikir.arab,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'serif',
                    height: 1.9,
                    color: const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Latin
                Text(
                  dzikir.latin,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress + tombol
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${dzikir.currentCount} / ${dzikir.jumlahBaca}x',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: dzikir.progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCounterButton(dzikir, kategori, color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── COUNTER BUTTON ───────────────────────────────────────────────────────
  Widget _buildCounterButton(
      DzikirModel dzikir, String kategori, Color color) {
    return Consumer<DzikirViewModel>(
      builder: (context, vm, _) => GestureDetector(
        onTap: () {
          if (!dzikir.isCompleted) {
            HapticFeedback.mediumImpact();
            vm.incrementCount(kategori, dzikir.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: dzikir.isCompleted
                ? color.withOpacity(0.2)
                : color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: dzikir.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Text(
            dzikir.isCompleted ? '✓' : '+1',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: dzikir.isCompleted ? color : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Belum ada dzikir',
              style: GoogleFonts.poppins(
                  fontSize: 15, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ─── BOTTOM SHEET DETAIL ──────────────────────────────────────────────────
  void _showDzikirDetail(
      DzikirModel dzikir, String kategori, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Judul
                    Text(
                      dzikir.nama,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Arab
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: color.withOpacity(0.15), width: 1),
                      ),
                      child: Text(
                        dzikir.arab,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'serif',
                          height: 2.0,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Latin
                    _DetailSection(
                      title: 'Transliterasi',
                      labelColor: _kTeal,
                      labelBg: _kTeal.withOpacity(0.08),
                      child: Text(
                        dzikir.latin,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                          height: 1.8,
                        ),
                      ),
                    ),

                    // Arti
                    _DetailSection(
                      title: 'Artinya',
                      labelColor: const Color(0xFF388E3C),
                      labelBg:
                          const Color(0xFF388E3C).withOpacity(0.08),
                      child: Text(
                        dzikir.arti,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF1A1A2E),
                          height: 1.8,
                        ),
                      ),
                    ),

                    // Keutamaan
                    _DetailSection(
                      title: 'Keutamaan',
                      labelColor: _kGold,
                      labelBg: _kGold.withOpacity(0.08),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: _kGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dzikir.keutamaan,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.8,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Counter section
                    Consumer<DzikirViewModel>(
                      builder: (context, vm, _) => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: color.withOpacity(0.2), width: 1),
                        ),
                        child: Column(
                          children: [
                            Text('Counter',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                // Minus
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    vm.decrementCount(
                                        kategori, dzikir.id);
                                  },
                                  icon: const Icon(
                                      Icons.remove_circle_outline_rounded),
                                  color: color,
                                  iconSize: 36,
                                ),
                                const SizedBox(width: 20),
                                // Display
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            color.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${dzikir.currentCount} / ${dzikir.jumlahBaca}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Plus
                                IconButton(
                                  onPressed: () {
                                    if (!dzikir.isCompleted) {
                                      HapticFeedback.mediumImpact();
                                      vm.incrementCount(
                                          kategori, dzikir.id);
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.add_circle_rounded),
                                  color: color,
                                  iconSize: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: dzikir.progress,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            if (dzikir.isCompleted) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF388E3C),
                                      size: 18),
                                  const SizedBox(width: 20),
                                  Text(
                                    'Selesai! Alhamdulillah',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF388E3C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () =>
                                  vm.resetCount(kategori, dzikir.id),
                              icon: const Icon(Icons.refresh_rounded,
                                  size: 16),
                              label: Text('Reset Counter',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13)),
                              style: TextButton.styleFrom(
                                  foregroundColor: color),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol salin & tutup
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text:
                                    '${dzikir.arab}\n\n${dzikir.latin}\n\n${dzikir.arti}',
                              ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Dzikir disalin!',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: _kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                duration:
                                    const Duration(seconds: 2),
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

  // ─── HELPER ───────────────────────────────────────────────────────────────
  Color _categoryColor(String kategori) {
    switch (kategori) {
      case 'pagi':    return _kPagi;
      case 'petang':  return _kPetang;
      case 'shalat':  return _kShalat;
      default:        return _kTeal;
    }
  }
}

// ─────────────────────────────────────────────
// SECTION WIDGET
// ─────────────────────────────────────────────
class _DetailSection extends StatelessWidget {
  final String title;
  final Color  labelColor;
  final Color  labelBg;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.labelColor,
    required this.labelBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: labelBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: labelColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}