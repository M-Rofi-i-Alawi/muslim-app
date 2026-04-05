import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/ramadhan_viewmodel.dart';
import '../model/ramadhan_model.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

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
            _buildAppBar(context),
            _buildTabBar(),
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
                builder: (_) =>
                    _EditEntryPage(entry: vm.currentEntry!),
              ),
            );
          }
        },
        backgroundColor: _kTeal,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
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
                backgroundColor: _kTeal,
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
          Tab(text: 'Amalan'),
          Tab(text: 'Statistik'),
          Tab(text: 'Karomah'),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days   = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────
// TAB 1: AMALAN
// ─────────────────────────────────────────────
class _AmalanTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _kTeal));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildUserHeader(context),
              const SizedBox(height: 20),
              _buildTimelineList(vm),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kTealDark, _kTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kTeal.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
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
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Export PDF coming soon',
                      style: GoogleFonts.poppins()),
                  backgroundColor: _kTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(RamadhanViewModel vm) {
    return FutureBuilder<List<RamadhanEntry>>(
      future: vm.getAllEntries(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: _kTeal));
        }
        final entries = snap.data!;
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.edit_calendar_rounded,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Belum ada catatan',
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Text('Tap tombol + untuk mulai',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[400])),
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
    final entry      = widget.entry;
    final isPuasa    = entry.puasa;
    final shalatCount = entry.completedShalatCount;
    final puasaColor = isPuasa
        ? const Color(0xFF388E3C)
        : const Color(0xFFD32F2F);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: puasaColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: puasaColor, width: 1.5),
                ),
                child: Icon(
                  isPuasa
                      ? Icons.wb_sunny_rounded
                      : Icons.no_food_rounded,
                  color: puasaColor, size: 22,
                ),
              ),
              if (!_expanded)
                Container(width: 2, height: 36,
                    color: Colors.grey[200]),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
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
                                        fontWeight: FontWeight.w600)),
                              ),
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[400],
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
                                  _badge(
                                      'Tadarus ${entry.tadarusJuz} Juz',
                                      _kTeal),
                                if (entry.infakAmount > 0)
                                  _badge(
                                      'Infak Rp ${_fmtMoney(entry.infakAmount)}',
                                      _kGold),
                                if (entry.shalatTarawih)
                                  _badge('Tarawih',
                                      const Color(0xFF7B1FA2)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_expanded) ...[
                      Divider(height: 1, color: Colors.grey[100]),
                      _buildExpandedDetail(entry),
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

  Widget _buildExpandedDetail(RamadhanEntry entry) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailSection('Shalat', Icons.self_improvement_rounded, _kTeal,
              Column(
                children: [
                  _checkRow('Subuh',   entry.shalatSubuh),
                  _checkRow('Dzuhur',  entry.shalatDzuhur),
                  _checkRow('Ashar',   entry.shalatAshar),
                  _checkRow('Maghrib', entry.shalatMaghrib),
                  _checkRow('Isya',    entry.shalatIsya),
                  if (entry.shalatTarawih || entry.shalatTahajud) ...[
                    const Divider(),
                    if (entry.shalatTarawih) _checkRow('Tarawih', true),
                    if (entry.shalatTahajud) _checkRow('Tahajud', true),
                  ],
                ],
              )),
          if (entry.tadarusJuz > 0)
            _detailSection('Tadarus', Icons.menu_book_rounded,
                const Color(0xFF388E3C),
                Text('Juz ${entry.tadarusJuz}',
                    style: GoogleFonts.poppins(fontSize: 13))),
          if (entry.infakAmount > 0)
            _detailSection('Infak', Icons.volunteer_activism_rounded,
                _kGold,
                Text('Rp ${_fmtMoney(entry.infakAmount)}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text('Edit Catatan',
                  style: GoogleFonts.poppins(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: _kTeal),
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
      String title, IconData icon, Color color, Widget child) {
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
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            checked
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: checked ? _kTeal : Colors.grey[300],
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: checked
                      ? Colors.black87
                      : Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days   = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────
// TAB 2: STATISTIK
// ─────────────────────────────────────────────
class _StatistikTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        final stats = vm.statistics;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgress(stats),
              const SizedBox(height: 18),
              _buildGrid(stats),
              const SizedBox(height: 18),
              _buildDetailStats(stats),
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
        gradient: const LinearGradient(
            colors: [_kTealDark, _kTeal]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kTeal.withOpacity(0.3),
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(RamadhanStatistics stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard('Puasa', '${stats.puasaCount}',
            '${stats.puasaPercentage.toStringAsFixed(0)}%',
            Icons.wb_sunny_rounded, const Color(0xFFE8650A)),
        _StatCard('Shalat Lengkap', '${stats.allShalatCompleteCount}',
            '${stats.shalatPercentage.toStringAsFixed(0)}%',
            Icons.self_improvement_rounded, _kTeal),
        _StatCard('Tadarus', '${stats.totalTadarusJuz} Juz', 'Total',
            Icons.menu_book_rounded, const Color(0xFF388E3C)),
        _StatCard('Infak', 'Rp ${_fmtNum(stats.totalInfak)}', 'Total',
            Icons.volunteer_activism_rounded, _kGold),
      ],
    );
  }

  Widget _buildDetailStats(RamadhanStatistics stats) {
    return _SectionCard(
      title: 'Detail Statistik',
      icon: Icons.bar_chart_rounded,
      color: _kTeal,
      child: Column(
        children: [
          _row('Hari dicatat',        '${stats.totalDays} hari'),
          _row('Puasa',               '${stats.puasaCount} hari'),
          _row('Shalat 5 waktu',      '${stats.allShalatCompleteCount} hari'),
          _row('Tarawih',             '${stats.tarawihCount} hari'),
          _row('Tahajud',             '${stats.tahajudCount} hari'),
          _row('Total tadarus',        '${stats.totalTadarusJuz} juz'),
          _row('Total infak',          'Rp ${_fmtNum(stats.totalInfak)}'),
          _row('Ceramah dirangkum',   '${stats.ceramahCount} ceramah'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[700])),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _fmtNum(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)} jt';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)} rb';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────
// TAB 3: KAROMAH
// ─────────────────────────────────────────────
class _KaromahTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (_, vm, __) {
        final entry = vm.currentEntry;
        if (entry == null) {
          return Center(
              child: Text('Tidak ada data',
                  style: GoogleFonts.poppins(color: Colors.grey)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateNav(context, vm),
              const SizedBox(height: 16),
              _DiaryCard(title: 'Doa yang Terkabul',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFD32F2F),
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Doa yang dikabulkan hari ini...',
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateDoaTerkabul,
                    controller: TextEditingController(
                        text: entry.doaTerkabul),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(title: 'Momen Spesial',
                  icon: Icons.star_rounded,
                  color: _kGold,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Momen berkesan hari ini...',
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateMomenSpesial,
                    controller: TextEditingController(
                        text: entry.momenSpesial),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(title: 'Refleksi & Muhasabah',
                  icon: Icons.self_improvement_rounded,
                  color: _kTeal,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Apa yang kamu rasakan hari ini?',
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updateRefleksi,
                    controller: TextEditingController(
                        text: entry.refleksi),
                  )),
              const SizedBox(height: 12),
              _DiaryCard(title: 'Pembelajaran & Hikmah',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF1565C0),
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Hikmah hari ini...',
                        border: InputBorder.none),
                    maxLines: 5,
                    onChanged: vm.updatePembelajaran,
                    controller: TextEditingController(
                        text: entry.pembelajaran),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateNav(BuildContext context, RamadhanViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: vm.previousDay,
            color: _kTeal,
          ),
          Column(
            children: [
              Text('Hari ke-${vm.currentEntry?.ramadhanDay ?? 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                '${vm.selectedDate.day}/${vm.selectedDate.month}/${vm.selectedDate.year}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: vm.nextDay,
            color: _kTeal,
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
  final String   title;
  final IconData icon;
  final Color    color;
  final Widget   child;
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
  final String   title, value, subtitle;
  final IconData icon;
  final Color    color;
  const _StatCard(this.title, this.value, this.subtitle, this.icon,
      this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  fontSize: 11, color: Colors.grey[600])),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Color    color;
  final Widget   child;
  const _DiaryCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
    final vm             = context.read<RamadhanViewModel>();
    final bottomPadding  = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kTealDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white),
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
                  backgroundColor: _kTeal,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_calendar_rounded, color: _kTeal),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hari ke-${_entry.ramadhanDay}',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text(_formatDate(_entry.date),
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Puasa
            _SectionCard(
              title: 'Puasa', icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFE8650A),
              child: CheckboxListTile(
                title: Text('Puasa hari ini',
                    style: GoogleFonts.poppins(fontSize: 14)),
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
              title: 'Shalat', icon: Icons.self_improvement_rounded,
              color: _kTeal,
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
                          style: GoogleFonts.poppins(fontSize: 14)),
                      value: pair[1] as bool,
                      onChanged: pair[2] as Function(bool?),
                      activeColor: _kTeal, dense: true,
                    ),
                  const Divider(),
                  CheckboxListTile(
                    title: Text('Tarawih',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    value: _entry.shalatTarawih,
                    onChanged: (v) {
                      setState(
                          () => _entry = _entry.copyWith(shalatTarawih: v));
                      vm.updateShalatTarawih(v ?? false);
                    },
                    activeColor: const Color(0xFF7B1FA2), dense: true,
                  ),
                  CheckboxListTile(
                    title: Text('Tahajud',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    value: _entry.shalatTahajud,
                    onChanged: (v) {
                      setState(
                          () => _entry = _entry.copyWith(shalatTahajud: v));
                      vm.updateShalatTahajud(v ?? false);
                    },
                    activeColor: const Color(0xFF7B1FA2), dense: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tadarus
            _SectionCard(
              title: 'Tadarus Al-Quran',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF388E3C),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Juz yang dibaca',
                        style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded),
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
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded),
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
                      decoration: InputDecoration(
                        labelText: 'Surat yang dibaca',
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
              title: 'Catatan Tambahan',
              icon: Icons.note_rounded,
              color: const Color(0xFF546E7A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Tulis catatan atau refleksi...',
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
    const days   = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}