class ZakatResult {
  final String jenisZakat;
  final double totalHarta;
  final double nisab;
  final bool wajibZakat;
  final double jumlahZakat;
  final String keterangan;

  ZakatResult({
    required this.jenisZakat,
    required this.totalHarta,
    required this.nisab,
    required this.wajibZakat,
    required this.jumlahZakat,
    required this.keterangan,
  });
}

class ZakatMaalInput {
  double emas; // gram
  double perak; // gram
  double uangTunai; // rupiah
  double tabungan; // rupiah
  double saham; // rupiah
  double piutang; // rupiah
  
  ZakatMaalInput({
    this.emas = 0,
    this.perak = 0,
    this.uangTunai = 0,
    this.tabungan = 0,
    this.saham = 0,
    this.piutang = 0,
  });
  
  double get totalHarta => uangTunai + tabungan + saham + piutang;
}

class ZakatPenghasilanInput {
  double gajiPerBulan;
  double bonus;
  double penghasilanLain;
  
  ZakatPenghasilanInput({
    this.gajiPerBulan = 0,
    this.bonus = 0,
    this.penghasilanLain = 0,
  });
  
  double get totalPenghasilan => gajiPerBulan + bonus + penghasilanLain;
}

class ZakatPerdaganganInput {
  double modalUsaha;
  double keuntungan;
  double piutangDagang;
  double hutangJatuhTempo;
  
  ZakatPerdaganganInput({
    this.modalUsaha = 0,
    this.keuntungan = 0,
    this.piutangDagang = 0,
    this.hutangJatuhTempo = 0,
  });
  
  double get totalHarta => modalUsaha + keuntungan + piutangDagang - hutangJatuhTempo;
}

class ZakatPertanianInput {
  double hasilPanen; // kg
  bool menggunakanIrigasi;
  
  ZakatPertanianInput({
    this.hasilPanen = 0,
    this.menggunakanIrigasi = false,
  });
}

class ZakatFitrahInput {
  int jumlahJiwa;
  double hargaBeras; // per kg atau langsung uang
  bool bayarDenganUang;
  
  ZakatFitrahInput({
    this.jumlahJiwa = 1,
    this.hargaBeras = 15000, // default harga beras
    this.bayarDenganUang = true,
  });
}

// Nisab constants (updated periodically)
class NisabConstants {
  static const double emasGram = 85.0; // 85 gram emas
  static const double perakGram = 595.0; // 595 gram perak
  static const double hargaEmasPerGram = 1100000.0; // Update sesuai harga pasar
  static const double hargaPerakPerGram = 15000.0; // Update sesuai harga pasar
  static const double berasKg = 2.5; // 2.5 kg beras untuk fitrah
  static const double gabahKg = 520.0; // 520 kg gabah (653 kg padi)
  
  static double get nisabEmasRupiah => emasGram * hargaEmasPerGram;
  static double get nisabPerakRupiah => perakGram * hargaPerakPerGram;
}