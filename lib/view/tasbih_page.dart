import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';  // ← IMPORT PACKAGE
import '../viewmodel/tasbih_viewmodel.dart';
import '../model/tasbih_model.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with SingleTickerProviderStateMixin {
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
    // Store current state before increment
    final wasCompleted = vm.currentTasbih.isCompleted;
    final currentCount = vm.currentTasbih.count;
    final target = vm.currentTasbih.target;
    
    // Haptic feedback
    if (vm.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    // Animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Increment
    vm.increment();
    
    // Check if just reached target (count + 1 == target)
    if (!wasCompleted && currentCount + 1 == target) {
      _showTargetReachedCelebration(vm);
    }
  }

  // ✅ HANYA 1 FUNCTION - PAKAI VIBRATION PACKAGE
  void _showTargetReachedCelebration(TasbihViewModel vm) {
    // STRONG Vibration pattern (bukan HapticFeedback)
    if (vm.vibrationEnabled) {
      // Vibrate 3 times - PASTI TERASA!
      Vibration.vibrate(duration: 500);
      Future.delayed(const Duration(milliseconds: 700), () {
        Vibration.vibrate(duration: 500);
      });
      Future.delayed(const Duration(milliseconds: 1400), () {
        Vibration.vibrate(duration: 500);
      });
    }
    
    // Show celebration dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF00A86B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Alhamdulillah!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Target ${vm.currentTasbih.target}x tercapai',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              vm.currentTasbih.nama,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Lanjut Dzikir',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF00A86B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00A86B),
              Color(0xFF00C87D),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.3],
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
                  builder: (context, vm, _) {
                    return GestureDetector(
                      onTap: () => _onTap(vm),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCounter(vm.currentTasbih),
                            const SizedBox(height: 60),
                            _buildActionButtons(vm),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomText(),
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
          Text(
            'TASBIH DIGITAL',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Consumer<TasbihViewModel>(
            builder: (context, vm, _) {
              return IconButton(
                icon: Icon(
                  vm.vibrationEnabled ? Icons.vibration : Icons.phone_android,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  vm.toggleVibration();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        vm.vibrationEnabled ? 'Getaran aktif' : 'Getaran nonaktif',
                        style: GoogleFonts.poppins(),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF00A86B),
                    ),
                  );
                },
              );
            },
          ),
          Consumer<TasbihViewModel>(
            builder: (context, vm, _) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                onPressed: () => _showAddCustomTasbih(vm),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Consumer<TasbihViewModel>(
      builder: (context, vm, _) {
        return SizedBox(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => vm.selectTasbih(index),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tasbih.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF00A86B) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCounter(TasbihModel tasbih) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${tasbih.count}',
              style: GoogleFonts.poppins(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00A86B),
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DARI ${tasbih.target}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(TasbihViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Reset',
            onTap: () {
              HapticFeedback.lightImpact();
              vm.reset();
            },
          ),
          _buildActionButton(
            icon: Icons.history,
            label: 'Riwayat',
            onTap: () => _showHistory(vm),
          ),
          _buildActionButton(
            icon: Icons.track_changes,
            label: 'Target',
            onTap: () => _showTargetDialog(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00A86B),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomText() {
    return Text(
      'Ketuk lingkaran besar untuk menghitung dzikir',
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey[400],
      ),
    );
  }

  void _showTargetDialog(TasbihViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Pilih Target',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
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
                label: Text('Custom Target', style: GoogleFonts.poppins()),
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
      title: Text(
        '$target kali',
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF00A86B) : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF00A86B))
          : null,
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
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Custom Target',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Target',
              hintText: 'Misal: 500',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                final target = int.tryParse(controller.text);
                if (target != null && target > 0) {
                  vm.setTarget(target);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Dzikir',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vm.history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          vm.clearHistory();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text('Hapus', style: GoogleFonts.poppins(fontSize: 12)),
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
                            Icon(Icons.history, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada riwayat',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: vm.history.length,
                        itemBuilder: (context, index) {
                          final history = vm.history[index];
                          return _buildHistoryCard(history);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TasbihHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF00A86B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.namaZikir,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${history.totalCount} kali (Target: ${history.target})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(history.completedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                _formatTime(history.completedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
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
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Tambah Dzikir Custom',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama (Latin)',
                  hintText: 'Misal: Subhanallah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: arabController,
                decoration: InputDecoration(
                  labelText: 'Arab',
                  hintText: 'سُبْحَانَ اللهِ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isNotEmpty && arabController.text.isNotEmpty) {
                  vm.addCustomTasbih(namaController.text, arabController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Tambah', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}