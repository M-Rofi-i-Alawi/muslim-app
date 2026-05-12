import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../utils/theme_helper.dart';
import '../viewmodel/tasbih_viewmodel.dart';
import '../model/tasbih_model.dart';

const _kGreen = Color(0xFF00A86B);
const _kTeal = Color(0xFF00A086);

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap(TasbihViewModel vm) {
    final wasCompleted = vm.currentTasbih.isCompleted;
    final currentCount = vm.currentTasbih.count;
    final target = vm.currentTasbih.target;

    if (vm.vibrationEnabled) HapticFeedback.mediumImpact();
    _animationController.forward().then((_) => _animationController.reverse());
    vm.increment();

    if (!wasCompleted && currentCount + 1 == target) {
      _showTargetReachedCelebration(vm);
    }
  }

  void _showTargetReachedCelebration(TasbihViewModel vm) {
    if (vm.vibrationEnabled) {
      Vibration.vibrate(duration: 500);
      Future.delayed(const Duration(milliseconds: 700),
          () => Vibration.vibrate(duration: 500));
      Future.delayed(const Duration(milliseconds: 1400),
          () => Vibration.vibrate(duration: 500));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _kGreen,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 80),
            const SizedBox(height: 16),
            TrText('Alhamdulillah!',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
                '${context.tr('Target tercapai!')} ${vm.currentTasbih.target}x',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(vm.currentTasbih.nama,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: TrText('Lanjut Dzikir',
                  style: GoogleFonts.poppins(
                      color: _kGreen, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: ambil warna dari theme untuk bagian bawah (putih → adaptive)
    final c = context.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // FIX: bagian bawah dari Colors.white → c.background (adaptive)
            colors: [_kTeal, _kTeal, c.background],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 40),
              Expanded(
                child: Consumer<TasbihViewModel>(
                  builder: (context, vm, _) => GestureDetector(
                    onTap: () => _onTap(vm),
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCounter(context, vm.currentTasbih),
                          const SizedBox(height: 60),
                          _buildActionButtons(context, vm),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomText(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          TrText('TASBIH DIGITAL',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5)),
          const Spacer(),
          Consumer<TasbihViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: Icon(
                  vm.vibrationEnabled ? Icons.vibration : Icons.phone_android,
                  color: Colors.white,
                  size: 24),
              onPressed: () {
                vm.toggleVibration();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      vm.vibrationEnabled
                          ? context.tr('Getaran aktif')
                          : context.tr('Getaran nonaktif'),
                      style: GoogleFonts.poppins()),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _kGreen,
                ));
              },
            ),
          ),
          Consumer<TasbihViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.white, size: 28),
              onPressed: () => _showAddCustomTasbih(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Consumer<TasbihViewModel>(
      builder: (context, vm, _) => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.tasbihList.length,
          itemBuilder: (context, index) {
            final tasbih = vm.tasbihList[index];
            final isSelected = vm.selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              // FIX: GestureDetector → InkWell untuk ripple
              child: InkWell(
                onTap: () => vm.selectTasbih(index),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.5),
                        width: 1.5),
                  ),
                  child: Text(tasbih.nama,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? _kGreen : Colors.white)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context, TasbihModel tasbih) {
    // FIX: lingkaran counter adaptive
    final c = context.colors;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // FIX: Colors.white → c.surface
          color: c.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${tasbih.count}',
                style: GoogleFonts.poppins(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: _kGreen,
                    height: 1)),
            const SizedBox(height: 8),
            Text('${context.tr("DARI")} ${tasbih.target}',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    // FIX: Colors.grey[400] → c.textHint
                    color: c.textHint,
                    letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TasbihViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              context: context,
              icon: Icons.refresh,
              label: context.tr('Reset'),
              onTap: () {
                HapticFeedback.lightImpact();
                vm.reset();
              }),
          _buildActionButton(
              context: context,
              icon: Icons.history,
              label: context.tr('Riwayat'),
              onTap: () => _showHistory(vm)),
          _buildActionButton(
              context: context,
              icon: Icons.track_changes,
              label: context.tr('Target'),
              onTap: () => _showTargetDialog(vm)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // FIX: ambil warna label dari theme
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kGreen, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  // FIX: Colors.grey[600] → c.textSecondary
                  color: c.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomText(BuildContext context) {
    final c = context.colors;
    return TrText('Ketuk lingkaran besar untuk menghitung dzikir',
        // FIX: Colors.grey[400] → c.textHint
        style: GoogleFonts.poppins(fontSize: 12, color: c.textHint));
  }

  // ─── DIALOGS ──────────────────────────────────────────────────────────────

  void _showTargetDialog(TasbihViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        // FIX: dialog adaptive
        final c = context.colors;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: c.surface,
          title: TrText('Pilih Target',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: c.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTargetOption(vm, 33),
              _buildTargetOption(vm, 99),
              _buildTargetOption(vm, 100),
              _buildTargetOption(vm, 1000),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCustomTargetDialog(vm);
                },
                icon: const Icon(Icons.edit),
                label: TrText('Custom Target', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetOption(TasbihViewModel vm, int target) {
    final isSelected = vm.currentTasbih.target == target;
    return ListTile(
      title: Text('$target ${context.tr("kali")}',
          style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _kGreen : null)),
      trailing:
          isSelected ? const Icon(Icons.check_circle, color: _kGreen) : null,
      onTap: () {
        vm.setTarget(target);
        Navigator.pop(context);
      },
    );
  }

  void _showCustomTargetDialog(TasbihViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final c = context.colors;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: c.surface,
          title: TrText('Custom Target',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: c.onSurface)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.tr('Jumlah Target'),
              hintText: context.tr('Misal: 500'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: TrText('Batal', style: GoogleFonts.poppins())),
            ElevatedButton(
              onPressed: () {
                final target = int.tryParse(controller.text);
                if (target != null && target > 0) {
                  vm.setTarget(target);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: TrText('Simpan',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showHistory(TasbihViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // FIX: bottom sheet adaptive
        final c = context.colors;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              // FIX: Colors.white → c.surface
              color: c.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      // FIX: Colors.grey[300] → c.divider
                      color: c.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TrText('Riwayat Dzikir',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // FIX: default text → c.onSurface
                              color: c.onSurface)),
                      if (vm.history.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            vm.clearHistory();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: TrText('Hapus',
                              style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 80, color: c.textHint),
                              const SizedBox(height: 16),
                              TrText('Belum ada riwayat',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: c.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: vm.history.length,
                          itemBuilder: (context, index) =>
                              _buildHistoryCard(context, vm.history[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, TasbihHistory history) {
    // FIX: adaptive colors untuk history card
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // FIX: Colors.grey[50] → c.surfaceVariant
        color: c.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: _kGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(history.namaZikir,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        // FIX: default → c.onSurface
                        color: c.onSurface)),
                const SizedBox(height: 4),
                Text(
                    '${history.totalCount} ${context.tr("kali")} (Target: ${history.target})',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        // FIX: Colors.grey[600] → c.textSecondary
                        color: c.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatDate(context, history.completedAt),
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      // FIX: Colors.grey[500] → c.textHint
                      color: c.textHint)),
              Text(_formatTime(context, history.completedAt),
                  style: GoogleFonts.poppins(fontSize: 11, color: c.textHint)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCustomTasbih(TasbihViewModel vm) {
    final namaController = TextEditingController();
    final arabController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // FIX: dialog adaptive
        final c = context.colors;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                // FIX: Colors.white → c.surface
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header gradient — oke di kedua mode
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient:
                          LinearGradient(colors: [Color(0xFF007A68), _kTeal]),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_circle_outline_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TrText('Tambah Dzikir Custom',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TrText('Nama (Latin)',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  // FIX: hardcoded → c.onSurface
                                  color: c.onSurface)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: namaController,
                            decoration: InputDecoration(
                              hintText: 'Misal: Subhanallah',
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: c.textHint),
                              filled: true,
                              // FIX: hardcoded fillColor → c.surfaceVariant
                              fillColor: c.surfaceVariant,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: _kTeal, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: c.onSurface),
                          ),
                          const SizedBox(height: 16),
                          TrText('Arab',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: c.onSurface)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: arabController,
                            decoration: InputDecoration(
                              hintText: 'سُبْحَانَ اللّٰهِ',
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'serif',
                                  color: c.textHint),
                              filled: true,
                              // FIX: hardcoded → c.surfaceVariant
                              fillColor: c.surfaceVariant,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: _kTeal, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'serif',
                                color: c.onSurface),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: _kTeal.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: _kTeal, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    context.tr('Target default: 33x'),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: kTeal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kTeal,
                              side: const BorderSide(color: _kTeal, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: TrText('Batal',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final nama = namaController.text.trim();
                              final arab = arabController.text.trim();
                              if (nama.isEmpty || arab.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: TrText('Mohon isi semua field!',
                                      style: GoogleFonts.poppins()),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ));
                                return;
                              }
                              vm.addCustomTasbih(nama, arab);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('${context.tr('Dzikir')} "$nama" ${context.tr('ditambahkan!')}',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: _kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: TrText('Tambah',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final days = [
      // <-- hapus "const"
      context.tr('Minggu'),
      context.tr('Senin'),
      context.tr('Selasa'),
      context.tr('Rabu'),
      context.tr('Kamis'),
      context.tr('Jumat'),
      context.tr('Sabtu'),
    ];
    final months = [
      context.tr('Jan'),
      context.tr('Feb'),
      context.tr('Mar'),
      context.tr('Apr'),
      context.tr('Mei'),
      context.tr('Jun'),
      context.tr('Jul'),
      context.tr('Agu'),
      context.tr('Sep'),
      context.tr('Okt'),
      context.tr('Nov'),
      context.tr('Des'),
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
