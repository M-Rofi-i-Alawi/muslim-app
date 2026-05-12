import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/zakat_viewmodel.dart';
import '../model/zakat_model.dart';
import '../utils/theme_helper.dart';

class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});
  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging)
        setState(() => _selectedTab = _tabCtrl.index);
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
            _buildAppBar(),
            _buildTabBar(c),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  _ZakatMaalTab(),
                  _ZakatPenghasilanTab(),
                  _ZakatFitrahTab(),
                  _ZakatPerdaganganTab(),
                  _ZakatPertanianTab(),
                ],
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
                TrText('Kalkulator Zakat',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                TrText('Hitung zakat maal, penghasilan, fitrah & lainnya',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Text('الزكاة',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 22,
                  fontFamily: 'serif')),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────────────────
  Widget _buildTabBar(AppColors c) {
    final tabs = [context.tr('Maal'), context.tr('Penghasilan'), context.tr('Fitrah'), context.tr('Perdagangan'), context.tr('Pertanian')];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = _selectedTab == i;
            return Padding(
              padding: EdgeInsets.only(right: i < tabs.length - 1 ? 4 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = i);
                  _tabCtrl.animateTo(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tabs[i],
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1: ZAKAT MAAL
// ─────────────────────────────────────────────
class _ZakatMaalTab extends StatelessWidget {
  const _ZakatMaalTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<ZakatViewModel>(
      builder: (_, vm, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(
              c: c,
              title: context.tr('Zakat Maal (Harta)'),
              desc:
                  context.tr('Zakat dari harta yang dimiliki selama 1 tahun (haul) dan mencapai nisab.'),
              color: kTeal,
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 14),
            _InputField(
                c: c,
                label: 'Uang Tunai',
                hint: 'Jumlah uang tunai',
                value: vm.maalInput.uangTunai,
                onChanged: (v) => vm.maalInput.uangTunai = v),
            _InputField(
                c: c,
                label: 'Tabungan / Deposito',
                hint: 'Saldo tabungan di bank',
                value: vm.maalInput.tabungan,
                onChanged: (v) => vm.maalInput.tabungan = v),
            _InputField(
                c: c,
                label: 'Saham / Investasi',
                hint: 'Nilai saham atau investasi',
                value: vm.maalInput.saham,
                onChanged: (v) => vm.maalInput.saham = v),
            _InputField(
                c: c,
                label: 'Piutang (yang dapat dicairkan)',
                hint: 'Piutang lancar yang bisa ditagih',
                value: vm.maalInput.piutang,
                onChanged: (v) => vm.maalInput.piutang = v),
            const SizedBox(height: 8),
            const _HitungButton(label: 'Hitung Zakat Maal'),
            if (vm.maalResult != null) ...[
              const SizedBox(height: 20),
              _ResultCard(
                  c: c,
                  result: vm.maalResult!,
                  vm: vm,
                  onReset: () => vm.resetZakatMaal()),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2: ZAKAT PENGHASILAN
// ─────────────────────────────────────────────
class _ZakatPenghasilanTab extends StatelessWidget {
  const _ZakatPenghasilanTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<ZakatViewModel>(
      builder: (_, vm, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(
                c: c,
                title: context.tr('Zakat Penghasilan / Profesi'),
                desc:
                    context.tr('Zakat dari gaji, honorarium, atau penghasilan profesi sebesar 2.5%.'),
                color: const Color(0xFF1565C0),
                icon: Icons.work_rounded),
            const SizedBox(height: 14),
            _InputField(
                c: c,
                label: 'Gaji per Bulan',
                hint: 'Gaji bersih setelah potongan',
                value: vm.penghasilanInput.gajiPerBulan,
                onChanged: (v) => vm.penghasilanInput.gajiPerBulan = v),
            _InputField(
                c: c,
                label: 'Bonus / THR',
                hint: 'Bonus, THR, atau tunjangan',
                value: vm.penghasilanInput.bonus,
                onChanged: (v) => vm.penghasilanInput.bonus = v),
            _InputField(
                c: c,
                label: 'Penghasilan Lain',
                hint: 'Freelance, bisnis sampingan, dll',
                value: vm.penghasilanInput.penghasilanLain,
                onChanged: (v) => vm.penghasilanInput.penghasilanLain = v),
            const SizedBox(height: 8),
            const _HitungButton(label: 'Hitung Zakat Penghasilan'),
            if (vm.penghasilanResult != null) ...[
              const SizedBox(height: 20),
              _ResultCard(
                  c: c,
                  result: vm.penghasilanResult!,
                  vm: vm,
                  onReset: () => vm.resetZakatPenghasilan()),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3: ZAKAT FITRAH
// ─────────────────────────────────────────────
class _ZakatFitrahTab extends StatelessWidget {
  const _ZakatFitrahTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<ZakatViewModel>(
      builder: (_, vm, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(
                c: c,
                title: context.tr('Zakat Fitrah'),
                desc:
                    context.tr('Wajib dikeluarkan setiap Muslim di bulan Ramadan. 2.5 kg atau 3.5 liter beras per jiwa.'),
                color: const Color(0xFF388E3C),
                icon: Icons.people_rounded),
            const SizedBox(height: 14),
            _InputField(
                c: c,
                label: 'Jumlah Jiwa',
                hint: 'Berapa orang yang dizakati',
                value: vm.fitrahInput.jumlahJiwa.toDouble(),
                onChanged: (v) => vm.fitrahInput.jumlahJiwa = v.toInt(),
                isInteger: true,
                isRupiah: false,
                suffixText: 'jiwa'),
            _InputField(
                c: c,
                label: 'Harga Beras per Kg',
                hint: 'Harga beras yang dikonsumsi',
                value: vm.fitrahInput.hargaBeras,
                onChanged: (v) => vm.fitrahInput.hargaBeras = v),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(
                      color: c.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: vm.fitrahInput.bayarDenganUang,
                    onChanged: (v) {
                      vm.fitrahInput.bayarDenganUang = v ?? true;
                      vm.hitungZakatFitrah();
                    },
                    activeColor: kTeal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: TrText('Bayar dengan uang (bukan beras)',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: c.onSurface)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _HitungButton(label: 'Hitung Zakat Fitrah'),
            if (vm.fitrahResult != null) ...[
              const SizedBox(height: 20),
              _ResultCard(
                  c: c,
                  result: vm.fitrahResult!,
                  vm: vm,
                  onReset: () => vm.resetZakatFitrah(),
                  isFitrah: true),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 4: ZAKAT PERDAGANGAN
// ─────────────────────────────────────────────
class _ZakatPerdaganganTab extends StatelessWidget {
  const _ZakatPerdaganganTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<ZakatViewModel>(
      builder: (_, vm, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(
                c: c,
                title: context.tr('Zakat Perdagangan'),
                desc:
                    context.tr('Zakat dari (modal + keuntungan + piutang - hutang) sebesar 2.5% yang mencapai nisab dan haul.'),
                color: const Color(0xFF00838F),
                icon: Icons.storefront_rounded),
            const SizedBox(height: 14),
            _InputField(
                c: c,
                label: 'Modal Usaha',
                hint: 'Nilai modal dagang saat ini',
                value: vm.perdaganganInput.modalUsaha,
                onChanged: (v) => vm.perdaganganInput.modalUsaha = v),
            _InputField(
                c: c,
                label: 'Keuntungan',
                hint: 'Total keuntungan usaha',
                value: vm.perdaganganInput.keuntungan,
                onChanged: (v) => vm.perdaganganInput.keuntungan = v),
            _InputField(
                c: c,
                label: 'Piutang Dagang',
                hint: 'Piutang yang dapat ditagih',
                value: vm.perdaganganInput.piutangDagang,
                onChanged: (v) => vm.perdaganganInput.piutangDagang = v),
            _InputField(
                c: c,
                label: 'Hutang Jatuh Tempo',
                hint: 'Hutang yang harus dibayar',
                value: vm.perdaganganInput.hutangJatuhTempo,
                onChanged: (v) => vm.perdaganganInput.hutangJatuhTempo = v),
            const SizedBox(height: 8),
            const _HitungButton(label: 'Hitung Zakat Perdagangan'),
            if (vm.perdaganganResult != null) ...[
              const SizedBox(height: 20),
              _ResultCard(
                  c: c,
                  result: vm.perdaganganResult!,
                  vm: vm,
                  onReset: () => vm.resetZakatPerdagangan()),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 5: ZAKAT PERTANIAN
// ─────────────────────────────────────────────
class _ZakatPertanianTab extends StatelessWidget {
  const _ZakatPertanianTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<ZakatViewModel>(
      builder: (_, vm, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(
                c: c,
                title: context.tr('Zakat Pertanian'),
                desc:
                    context.tr('Nisab 520 kg. Zakat 10% jika tanpa irigasi (air hujan), 5% jika menggunakan irigasi/pompa.'),
                color: const Color(0xFF558B2F),
                icon: Icons.grass_rounded),
            const SizedBox(height: 14),
            _InputField(
                c: c,
                label: 'Hasil Panen',
                hint: 'Total hasil panen',
                value: vm.pertanianInput.hasilPanen,
                onChanged: (v) => vm.pertanianInput.hasilPanen = v,
                isRupiah: false,
                suffixText: 'kg'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(
                      color: c.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrText('Sistem Pengairan:',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _IrigasiOption(
                          c: c,
                          icon: Icons.wb_sunny_rounded,
                          label: context.tr('Hujan / Alami'),
                          sub: context.tr('Zakat 10%'),
                          selected: !vm.pertanianInput.menggunakanIrigasi,
                          onTap: () {
                            vm.pertanianInput.menggunakanIrigasi = false;
                            vm.hitungZakatPertanian();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IrigasiOption(
                          c: c,
                          icon: Icons.water_drop_rounded,
                          label: context.tr('Irigasi / Pompa'),
                          sub: context.tr('Zakat 5%'),
                          selected: vm.pertanianInput.menggunakanIrigasi,
                          onTap: () {
                            vm.pertanianInput.menggunakanIrigasi = true;
                            vm.hitungZakatPertanian();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _HitungButton(label: 'Hitung Zakat Pertanian'),
            if (vm.pertanianResult != null) ...[
              const SizedBox(height: 20),
              _ResultCard(
                  c: c,
                  result: vm.pertanianResult!,
                  vm: vm,
                  onReset: () => vm.resetZakatPertanian()),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final AppColors c;
  final String title, desc;
  final Color color;
  final IconData icon;

  const _InfoCard(
      {required this.c,
      required this.title,
      required this.desc,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: c.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final AppColors c;
  final String label, hint;
  final double value;
  final Function(double) onChanged;
  final bool isInteger;
  final bool isRupiah;
  final String? suffixText;

  const _InputField({
    required this.c,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.isInteger = false,
    this.isRupiah = true,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(
      text: value > 0
          ? (isInteger ? value.toInt().toString() : value.toString())
          : '',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: TextStyle(color: c.onSurface),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(
          labelText: context.tr(label),
          labelStyle: GoogleFonts.poppins(fontSize: 13, color: c.textSecondary),
          hintText: context.tr(hint),
          hintStyle: GoogleFonts.poppins(fontSize: 12, color: c.textHint),
          prefixText: isRupiah ? 'Rp ' : null,
          prefixStyle: TextStyle(color: c.onSurface),
          suffixText: suffixText,
          suffixStyle: TextStyle(color: c.textSecondary),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kTeal, width: 1.5)),
          filled: true,
          fillColor: c.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onChanged: (val) {
          final parsed =
              double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          onChanged(parsed);
        },
      ),
    );
  }
}

class _HitungButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const _HitungButton({this.onPressed, this.label = 'Hitung Zakat'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon:
            const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
        label: Text(context.tr(label),
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          padding: const EdgeInsets.all(16),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final AppColors c;
  final ZakatResult result;
  final ZakatViewModel vm;
  final VoidCallback onReset;
  final bool isFitrah;

  const _ResultCard(
      {required this.c,
      required this.result,
      required this.vm,
      required this.onReset,
      this.isFitrah = false});

  @override
  Widget build(BuildContext context) {
    final isWajib = result.wajibZakat;
    final cardColor = isWajib ? kTeal : Colors.grey[500]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isWajib
              ? [kTealDark, kTeal]
              : [Colors.grey[500]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5))
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
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: Icon(
                    isWajib ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: Colors.white,
                    size: 24),
              ),
              const SizedBox(width: 12),
              Text(isWajib ? context.tr('Wajib Zakat') : context.tr('Belum Wajib Zakat'),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 14),
          _resultRow(context.tr('Total Harta'), vm.formatRupiah(result.totalHarta)),
          _resultRow(context.tr('Nisab'), vm.formatRupiah(result.nisab)),
          if (isWajib) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TrText('Jumlah Zakat:',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(
                    isFitrah && !result.keterangan.contains('Rp')
                        ? '${result.jumlahZakat.toStringAsFixed(1)} kg'
                        : vm.formatRupiah(result.jumlahZakat),
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(result.keterangan,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.6)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded,
                size: 16, color: Colors.white),
            label: TrText('Reset',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white.withOpacity(0.85))),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _IrigasiOption extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;

  const _IrigasiOption(
      {required this.c,
      required this.icon,
      required this.label,
      required this.sub,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kTeal : c.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kTeal : c.border, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? Colors.white : c.textSecondary, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : c.onSurface)),
            Text(sub,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: selected
                        ? Colors.white.withOpacity(0.85)
                        : c.textHint)),
          ],
        ),
      ),
    );
  }
}