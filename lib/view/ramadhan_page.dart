import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/ramadhan_viewmodel.dart';
import '../model/ramadhan_model.dart';
import '../utils/theme_helper.dart';

class RamadhanPage extends StatefulWidget {
  const RamadhanPage({super.key});
  @override
  State<RamadhanPage> createState() => _RamadhanPageState();
}

class _RamadhanPageState extends State<RamadhanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
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
            _buildAppBar(context, c),
            _buildTabBar(c),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _AmalanTab(),
                  _StatistikTab(),
                  _KaromahTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final vm = context.read<RamadhanViewModel>();
          await vm.loadTodayEntry();
          if (vm.currentEntry != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _EditEntryPage(entry: vm.currentEntry!),
              ),
            );
          }
        },
        backgroundColor: kTeal,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
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
                Text('Catatan Ramadhan',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Consumer<RamadhanViewModel>(
                  builder: (_, vm, __) {
                    final entry = vm.currentEntry;
                    if (entry == null) return const SizedBox.shrink();
                    return Text(
                      'Hari ke-${entry.ramadhanDay} · ${_formatDate(entry.date)}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9)),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            onPressed: () {
              context.read<RamadhanViewModel>().saveCurrentEntry();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('✅ Data berhasil disimpan',
                    style: GoogleFonts.poppins()),
                backgroundColor: kTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            },
          ),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────────────────
  Widget _buildTabBar(AppColors c) {
    final tabs = ['Amalan', 'Statistik', 'Karomah'];

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
          final isSelected = _tabCtrl.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {});
                _tabCtrl.animateTo(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  String _formatDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────
// TAB 1: AMALAN
// ─────────────────────────────────────────────
class _AmalanTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator(color: kTeal));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildUserHeader(context, c),
              const SizedBox(height: 20),
              _buildTimelineList(context, vm, c),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(BuildContext context, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kTealDark, kTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kTeal.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JURNAL HARIAN',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('Catatan Ibadah Ramadhan',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Ramadhan 1447H',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Export PDF coming soon',
                    style: GoogleFonts.poppins()),
                backgroundColor: kTeal,
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, RamadhanViewModel vm, AppColors c) {
    return FutureBuilder<List<RamadhanEntry>>(
      future: vm.getAllEntries(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: kTeal));
        }
        final entries = snap.data!;
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.edit_calendar_rounded,
                      size: 64, color: c.textHint),
                  const SizedBox(height: 12),
                  Text('Belum ada catatan',
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: c.textSecondary)),
                  const SizedBox(height: 6),
                  Text('Tap tombol + untuk mulai',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: c.textHint)),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (_, i) => _TimelineItem(entry: entries[i]),
        );
      },
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final RamadhanEntry entry;
  const _TimelineItem({required this.entry});
  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entry = widget.entry;
    final isPuasa = entry.puasa;
    final shalatCount = entry.completedShalatCount;
    final puasaColor =
        isPuasa ? const Color(0xFF388E3C) : const Color(0xFFD32F2F);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: puasaColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: puasaColor, width: 1.5),
                ),
                child: Icon(
                  isPuasa ? Icons.wb_sunny_rounded : Icons.no_food_rounded,
                  color: puasaColor,
                  size: 22,
                ),
              ),
              if (!_expanded)
                Container(width: 2, height: 36, color: c.divider),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_formatDate(entry.date),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: c.onSurface)),
                              ),
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: c.textHint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isPuasa
                                ? 'Puasa Lancar · Shalat $shalatCount/5'
                                : 'Tidak Puasa',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: puasaColor),
                          ),
                          if (entry.tadarusJuz > 0 ||
                              entry.infakAmount > 0 ||
                              entry.shalatTarawih) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (entry.tadarusJuz > 0)
                                  _badge('Tadarus ${entry.tadarusJuz} Juz', kTeal),
                                if (entry.infakAmount > 0)
                                  _badge('Infak Rp ${_fmtMoney(entry.infakAmount)}', kGold),
                                if (entry.shalatTarawih)
                                  _badge('Tarawih', const Color(0xFF7B1FA2)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_expanded) ...[
                      Divider(height: 1, color: c.divider),
                      _buildExpandedDetail(context, entry, c),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildExpandedDetail(BuildContext context, RamadhanEntry entry, AppColors c) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailSection('Shalat', Icons.self_improvement_rounded, kTeal, c,
              Column(children: [
                _checkRow('Subuh', entry.shalatSubuh, c),
                _checkRow('Dzuhur', entry.shalatDzuhur, c),
                _checkRow('Ashar', entry.shalatAshar, c),
                _checkRow('Maghrib', entry.shalatMaghrib, c),
                _checkRow('Isya', entry.shalatIsya, c),
                if (entry.shalatTarawih || entry.shalatTahajud) ...[
                  Divider(color: c.divider),
                  if (entry.shalatTarawih) _checkRow('Tarawih', true, c),
                  if (entry.shalatTahajud) _checkRow('Tahajud', true, c),
                ],
              ])),
          if (entry.tadarusJuz > 0)
            _detailSection('Tadarus', Icons.menu_book_rounded,
                const Color(0xFF388E3C), c,
                Text('Juz ${entry.tadarusJuz}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: c.onSurface))),
          if (entry.infakAmount > 0)
            _detailSection('Infak', Icons.volunteer_activism_rounded, kGold, c,
                Text('Rp ${_fmtMoney(entry.infakAmount)}',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.onSurface))),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text('Edit Catatan',
                  style: GoogleFonts.poppins(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: kTeal),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => _EditEntryPage(entry: entry)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(
      String title, IconData icon, Color color, AppColors c, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ]),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            checked
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: checked ? kTeal : c.textHint,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: checked ? c.onSurface : c.textSecondary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────
// TAB 2: STATISTIK
// ─────────────────────────────────────────────
class _StatistikTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        final stats = vm.statistics;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgress(stats),
              const SizedBox(height: 18),
              _buildGrid(context, stats, c),
              const SizedBox(height: 18),
              _buildDetailStats(stats, c),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgress(RamadhanStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kTealDark, kTeal]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kTeal.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text('Progress Ramadhan',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          Text('${stats.totalDays}/30 Hari',
              style: GoogleFonts.poppins(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: stats.totalDays / 30,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, RamadhanStatistics stats, AppColors c) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(c, 'Puasa', '${stats.puasaCount}',
            '${stats.puasaPercentage.toStringAsFixed(0)}%',
            Icons.wb_sunny_rounded, const Color(0xFFE8650A)),
        _StatCard(c, 'Shalat Lengkap', '${stats.allShalatCompleteCount}',
            '${stats.shalatPercentage.toStringAsFixed(0)}%',
            Icons.self_improvement_rounded, kTeal),
        _StatCard(c, 'Tadarus', '${stats.totalTadarusJuz} Juz', 'Total',
            Icons.menu_book_rounded, const Color(0xFF388E3C)),
        _StatCard(c, 'Infak', 'Rp ${_fmtNum(stats.totalInfak)}', 'Total',
            Icons.volunteer_activism_rounded, kGold),
      ],
    );
  }

  Widget _buildDetailStats(RamadhanStatistics stats, AppColors c) {
    return _SectionCard(
      c: c,
      title: 'Detail Statistik',
      icon: Icons.bar_chart_rounded,
      color: kTeal,
      child: Column(
        children: [
          _row(c, 'Hari dicatat', '${stats.totalDays} hari'),
          _row(c, 'Puasa', '${stats.puasaCount} hari'),
          _row(c, 'Shalat 5 waktu', '${stats.allShalatCompleteCount} hari'),
          _row(c, 'Tarawih', '${stats.tarawihCount} hari'),
          _row(c, 'Tahajud', '${stats.tahajudCount} hari'),
          _row(c, 'Total tadarus', '${stats.totalTadarusJuz} juz'),
          _row(c, 'Total infak', 'Rp ${_fmtNum(stats.totalInfak)}'),
          _row(c, 'Ceramah dirangkum', '${stats.ceramahCount} ceramah'),
        ],
      ),
    );
  }

  Widget _row(AppColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: c.textSecondary)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.onSurface)),
        ],
      ),
    );
  }

  String _fmtNum(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)} jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)} rb';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────
// TAB 3: KAROMAH
// ─────────────────────────────────────────────
class _KaromahTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        final entry = vm.currentEntry;
        if (entry == null) {
          return Center(
              child: Text('Tidak ada data',
                  style: GoogleFonts.poppins(color: c.textSecondary)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateNav(context, vm, c),
              const SizedBox(height: 16),
              _DiaryCard(
                  c: c,
                  title: 'Doa yang Terkabul',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFD32F2F),
                  child: TextField(
                    style: TextStyle(color: c.onSurface),
                    decoration: InputDecoration(
                        hintText: 'Doa yang dikabulkan hari ini...',
                        hintStyle: TextStyle(color: c.textHint),
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateDoaTerkabul,
                    controller:
                        TextEditingController(text: entry.doaTerkabul),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(
                  c: c,
                  title: 'Momen Spesial',
                  icon: Icons.star_rounded,
                  color: kGold,
                  child: TextField(
                    style: TextStyle(color: c.onSurface),
                    decoration: InputDecoration(
                        hintText: 'Momen berkesan hari ini...',
                        hintStyle: TextStyle(color: c.textHint),
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateMomenSpesial,
                    controller:
                        TextEditingController(text: entry.momenSpesial),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(
                  c: c,
                  title: 'Refleksi & Muhasabah',
                  icon: Icons.self_improvement_rounded,
                  color: kTeal,
                  child: TextField(
                    style: TextStyle(color: c.onSurface),
                    decoration: InputDecoration(
                        hintText: 'Apa yang kamu rasakan hari ini?',
                        hintStyle: TextStyle(color: c.textHint),
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateRefleksi,
                    controller:
                        TextEditingController(text: entry.refleksi),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(
                  c: c,
                  title: 'Pembelajaran & Hikmah',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF1565C0),
                  child: TextField(
                    style: TextStyle(color: c.onSurface),
                    decoration: InputDecoration(
                        hintText: 'Hikmah hari ini...',
                        hintStyle: TextStyle(color: c.textHint),
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updatePembelajaran,
                    controller:
                        TextEditingController(text: entry.pembelajaran),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateNav(BuildContext context, RamadhanViewModel vm, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: vm.previousDay,
            color: kTeal,
          ),
          Column(
            children: [
              Text('Hari ke-${vm.currentEntry?.ramadhanDay ?? 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: c.onSurface)),
              Text(
                '${vm.selectedDate.day}/${vm.selectedDate.month}/${vm.selectedDate.year}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: c.textSecondary),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: vm.nextDay,
            color: kTeal,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final AppColors c;

  const _SectionCard({
    required this.c,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: c.isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final AppColors c;
  final String title, value, subtitle;
  final IconData icon;
  final Color color;

  const _StatCard(
      this.c, this.title, this.value, this.subtitle, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: c.textSecondary)),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: c.textHint)),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final AppColors c;
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DiaryCard({
    required this.c,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDIT ENTRY PAGE
// ─────────────────────────────────────────────
class _EditEntryPage extends StatefulWidget {
  final RamadhanEntry entry;
  const _EditEntryPage({required this.entry});
  @override
  State<_EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<_EditEntryPage> {
  late RamadhanEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final vm = context.read<RamadhanViewModel>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: kTealDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Catatan',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            onPressed: () async {
              await vm.saveCurrentEntry();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ Catatan disimpan',
                      style: GoogleFonts.poppins()),
                  backgroundColor: kTeal,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
        child: Column(
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: c.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_calendar_rounded, color: kTeal),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hari ke-${_entry.ramadhanDay}',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: c.onSurface)),
                      Text(_formatDate(_entry.date),
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: c.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Puasa
            _SectionCard(
              c: c,
              title: 'Puasa',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFE8650A),
              child: CheckboxListTile(
                title: Text('Puasa hari ini',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: c.onSurface)),
                value: _entry.puasa,
                onChanged: (v) {
                  setState(() => _entry = _entry.copyWith(puasa: v));
                  vm.updatePuasa(v ?? false);
                },
                activeColor: const Color(0xFFE8650A),
              ),
            ),
            const SizedBox(height: 14),

            // Shalat
            _SectionCard(
              c: c,
              title: 'Shalat',
              icon: Icons.self_improvement_rounded,
              color: kTeal,
              child: Column(
                children: [
                  for (final pair in [
                    ['Subuh',   _entry.shalatSubuh,   (v) { setState(() => _entry = _entry.copyWith(shalatSubuh:   v)); vm.updateShalatSubuh(v ?? false); }],
                    ['Dzuhur',  _entry.shalatDzuhur,  (v) { setState(() => _entry = _entry.copyWith(shalatDzuhur:  v)); vm.updateShalatDzuhur(v ?? false); }],
                    ['Ashar',   _entry.shalatAshar,   (v) { setState(() => _entry = _entry.copyWith(shalatAshar:   v)); vm.updateShalatAshar(v ?? false); }],
                    ['Maghrib', _entry.shalatMaghrib, (v) { setState(() => _entry = _entry.copyWith(shalatMaghrib: v)); vm.updateShalatMaghrib(v ?? false); }],
                    ['Isya',    _entry.shalatIsya,    (v) { setState(() => _entry = _entry.copyWith(shalatIsya:    v)); vm.updateShalatIsya(v ?? false); }],
                  ])
                    CheckboxListTile(
                      title: Text(pair[0] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: c.onSurface)),
                      value: pair[1] as bool,
                      onChanged: pair[2] as Function(bool?),
                      activeColor: kTeal,
                      dense: true,
                    ),
                  Divider(color: c.divider),
                  CheckboxListTile(
                    title: Text('Tarawih',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.onSurface)),
                    value: _entry.shalatTarawih,
                    onChanged: (v) {
                      setState(() => _entry = _entry.copyWith(shalatTarawih: v));
                      vm.updateShalatTarawih(v ?? false);
                    },
                    activeColor: const Color(0xFF7B1FA2),
                    dense: true,
                  ),
                  CheckboxListTile(
                    title: Text('Tahajud',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.onSurface)),
                    value: _entry.shalatTahajud,
                    onChanged: (v) {
                      setState(() => _entry = _entry.copyWith(shalatTahajud: v));
                      vm.updateShalatTahajud(v ?? false);
                    },
                    activeColor: const Color(0xFF7B1FA2),
                    dense: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tadarus
            _SectionCard(
              c: c,
              title: 'Tadarus Al-Quran',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF388E3C),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Juz yang dibaca',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: c.onSurface)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.remove_circle_outline_rounded),
                          color: c.textSecondary,
                          onPressed: () {
                            if (_entry.tadarusJuz > 0) {
                              setState(() => _entry = _entry.copyWith(
                                  tadarusJuz: _entry.tadarusJuz - 1));
                              vm.updateTadarusJuz(_entry.tadarusJuz);
                            }
                          },
                        ),
                        Text('${_entry.tadarusJuz}',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: c.onSurface)),
                        IconButton(
                          icon: const Icon(
                              Icons.add_circle_outline_rounded),
                          color: c.textSecondary,
                          onPressed: () {
                            if (_entry.tadarusJuz < 30) {
                              setState(() => _entry = _entry.copyWith(
                                  tadarusJuz: _entry.tadarusJuz + 1));
                              vm.updateTadarusJuz(_entry.tadarusJuz);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      style: TextStyle(color: c.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Surat yang dibaca',
                        labelStyle: TextStyle(color: c.textSecondary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      controller: TextEditingController(
                          text: _entry.tadarusSurah),
                      onChanged: vm.updateTadarusSurah,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Catatan harian
            _SectionCard(
              c: c,
              title: 'Catatan Tambahan',
              icon: Icons.note_rounded,
              color: const Color(0xFF546E7A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  style: TextStyle(color: c.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    labelStyle: TextStyle(color: c.textSecondary),
                    hintText: 'Tulis catatan atau refleksi...',
                    hintStyle: TextStyle(color: c.textHint),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 4,
                  controller: TextEditingController(
                      text: _entry.catatanHarian),
                  onChanged: vm.updateCatatanHarian,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}