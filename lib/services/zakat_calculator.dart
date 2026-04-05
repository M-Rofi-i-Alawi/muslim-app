import '../model/zakat_model.dart';

class ZakatCalculator {

  // ===============================
  // ZAKAT MAAL (2.5%)
  // ===============================
  static ZakatResult hitungZakatMaal(
      ZakatMaalInput input, double hargaEmasPerGram) {

    final double nisab = NisabConstants.emasGram * hargaEmasPerGram;
    final double totalHarta = input.totalHarta;

    final bool wajibZakat = totalHarta >= nisab;
    final double jumlahZakat = wajibZakat ? totalHarta * 0.025 : 0.0;

    String keterangan;

    if (wajibZakat) {
      keterangan =
          'Harta Anda mencapai nisab (${_formatRupiah(nisab)}). Wajib zakat 2.5%.';
    } else {
      final double kurang = nisab - totalHarta;
      keterangan =
          'Harta belum mencapai nisab. Kurang ${_formatRupiah(kurang)}.';
    }

    return ZakatResult(
      jenisZakat: 'Zakat Maal',
      totalHarta: totalHarta,
      nisab: nisab,
      wajibZakat: wajibZakat,
      jumlahZakat: jumlahZakat,
      keterangan: keterangan,
    );
  }

  // ===============================
  // ZAKAT PENGHASILAN
  // ===============================
  static ZakatResult hitungZakatPenghasilan(
      ZakatPenghasilanInput input, double hargaEmasPerGram) {

    final double nisabPerBulan =
        (NisabConstants.emasGram * hargaEmasPerGram) / 12;

    final double totalPenghasilan = input.totalPenghasilan;

    final bool wajibZakat = totalPenghasilan >= nisabPerBulan;

    final double jumlahZakat =
        wajibZakat ? totalPenghasilan * 0.025 : 0.0;

    String keterangan;

    if (wajibZakat) {
      keterangan =
          'Penghasilan Anda mencapai nisab bulanan (${_formatRupiah(nisabPerBulan)}). Wajib zakat 2.5%.';
    } else {
      final double kurang = nisabPerBulan - totalPenghasilan;

      keterangan =
          'Penghasilan belum mencapai nisab. Kurang ${_formatRupiah(kurang)}.';
    }

    return ZakatResult(
      jenisZakat: 'Zakat Penghasilan',
      totalHarta: totalPenghasilan,
      nisab: nisabPerBulan,
      wajibZakat: wajibZakat,
      jumlahZakat: jumlahZakat,
      keterangan: keterangan,
    );
  }

  // ===============================
  // ZAKAT PERDAGANGAN
  // ===============================
  static ZakatResult hitungZakatPerdagangan(
      ZakatPerdaganganInput input, double hargaEmasPerGram) {

    final double nisab = NisabConstants.emasGram * hargaEmasPerGram;
    final double totalHarta = input.totalHarta;

    final bool wajibZakat = totalHarta >= nisab;

    final double jumlahZakat =
        wajibZakat ? totalHarta * 0.025 : 0.0;

    String keterangan;

    if (wajibZakat) {
      keterangan =
          'Harta perdagangan mencapai nisab (${_formatRupiah(nisab)}). Wajib zakat 2.5%.';
    } else {
      final double kurang = nisab - totalHarta;

      keterangan =
          'Harta perdagangan belum mencapai nisab. Kurang ${_formatRupiah(kurang)}.';
    }

    return ZakatResult(
      jenisZakat: 'Zakat Perdagangan',
      totalHarta: totalHarta,
      nisab: nisab,
      wajibZakat: wajibZakat,
      jumlahZakat: jumlahZakat,
      keterangan: keterangan,
    );
  }

  // ===============================
  // ZAKAT PERTANIAN
  // ===============================
  static ZakatResult hitungZakatPertanian(
      ZakatPertanianInput input) {

    final double nisab = NisabConstants.gabahKg;
    final double totalPanen = input.hasilPanen;

    final bool wajibZakat = totalPanen >= nisab;

    // 10% tanpa irigasi
    // 5% pakai irigasi
    final double persentase =
        input.menggunakanIrigasi ? 0.05 : 0.10;

    final double jumlahZakat =
        wajibZakat ? totalPanen * persentase : 0.0;

    String keterangan;

    if (wajibZakat) {
      final jenis =
          input.menggunakanIrigasi ? '5% (pakai irigasi)' : '10% (tanpa irigasi)';

      keterangan =
          'Hasil panen mencapai nisab (${nisab.toStringAsFixed(0)} kg). Wajib zakat $jenis.';
    } else {
      final double kurang = nisab - totalPanen;

      keterangan =
          'Hasil panen belum mencapai nisab. Kurang ${kurang.toStringAsFixed(0)} kg.';
    }

    return ZakatResult(
      jenisZakat: 'Zakat Pertanian',
      totalHarta: totalPanen,
      nisab: nisab,
      wajibZakat: wajibZakat,
      jumlahZakat: jumlahZakat,
      keterangan: keterangan,
    );
  }

  // ===============================
  // ZAKAT FITRAH
  // ===============================
  static ZakatResult hitungZakatFitrah(
      ZakatFitrahInput input) {

    final int jumlahJiwa = input.jumlahJiwa;
    final double hargaBeras = input.hargaBeras;

    final double berasPerJiwa = NisabConstants.berasKg;

    double jumlahZakat;
    String keterangan;

    if (input.bayarDenganUang) {
      jumlahZakat = jumlahJiwa * berasPerJiwa * hargaBeras;

      keterangan =
          '$jumlahJiwa jiwa × ${berasPerJiwa.toStringAsFixed(1)} kg × ${_formatRupiah(hargaBeras)}/kg';
    } else {
      jumlahZakat = jumlahJiwa * berasPerJiwa;

      keterangan =
          '$jumlahJiwa jiwa × ${berasPerJiwa.toStringAsFixed(1)} kg = ${jumlahZakat.toStringAsFixed(1)} kg beras';
    }

    return ZakatResult(
      jenisZakat: 'Zakat Fitrah',
      totalHarta: jumlahJiwa.toDouble(),
      nisab: 1,
      wajibZakat: true,
      jumlahZakat: jumlahZakat,
      keterangan: keterangan,
    );
  }

  // ===============================
  // FORMAT RUPIAH
  // ===============================
  static String _formatRupiah(double amount) {

    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(2)} M';
    } 
    else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(2)} Jt';
    } 
    else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    } 
    else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }

  }

}