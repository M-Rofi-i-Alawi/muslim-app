import 'package:flutter/material.dart';
import '../model/zakat_model.dart';
import '../services/zakat_calculator.dart';

class ZakatViewModel extends ChangeNotifier {
  // Current gold price (update periodically)
  double _hargaEmasPerGram = 1100000.0;
  
  // Input models
  ZakatMaalInput _maalInput = ZakatMaalInput();
  ZakatPenghasilanInput _penghasilanInput = ZakatPenghasilanInput();
  ZakatPerdaganganInput _perdaganganInput = ZakatPerdaganganInput();
  ZakatPertanianInput _pertanianInput = ZakatPertanianInput();
  ZakatFitrahInput _fitrahInput = ZakatFitrahInput();
  
  // Results
  ZakatResult? _maalResult;
  ZakatResult? _penghasilanResult;
  ZakatResult? _perdaganganResult;
  ZakatResult? _pertanianResult;
  ZakatResult? _fitrahResult;
  
  // Getters
  double get hargaEmasPerGram => _hargaEmasPerGram;
  ZakatMaalInput get maalInput => _maalInput;
  ZakatPenghasilanInput get penghasilanInput => _penghasilanInput;
  ZakatPerdaganganInput get perdaganganInput => _perdaganganInput;
  ZakatPertanianInput get pertanianInput => _pertanianInput;
  ZakatFitrahInput get fitrahInput => _fitrahInput;
  
  ZakatResult? get maalResult => _maalResult;
  ZakatResult? get penghasilanResult => _penghasilanResult;
  ZakatResult? get perdaganganResult => _perdaganganResult;
  ZakatResult? get pertanianResult => _pertanianResult;
  ZakatResult? get fitrahResult => _fitrahResult;
  
  // Update harga emas
  void updateHargaEmas(double harga) {
    _hargaEmasPerGram = harga;
    notifyListeners();
  }
  
  // Calculate Zakat Maal
  void hitungZakatMaal() {
    _maalResult = ZakatCalculator.hitungZakatMaal(_maalInput, _hargaEmasPerGram);
    notifyListeners();
  }
  
  // Calculate Zakat Penghasilan
  void hitungZakatPenghasilan() {
    _penghasilanResult = ZakatCalculator.hitungZakatPenghasilan(_penghasilanInput, _hargaEmasPerGram);
    notifyListeners();
  }
  
  // Calculate Zakat Perdagangan
  void hitungZakatPerdagangan() {
    _perdaganganResult = ZakatCalculator.hitungZakatPerdagangan(_perdaganganInput, _hargaEmasPerGram);
    notifyListeners();
  }
  
  // Calculate Zakat Pertanian
  void hitungZakatPertanian() {
    _pertanianResult = ZakatCalculator.hitungZakatPertanian(_pertanianInput);
    notifyListeners();
  }
  
  // Calculate Zakat Fitrah
  void hitungZakatFitrah() {
    _fitrahResult = ZakatCalculator.hitungZakatFitrah(_fitrahInput);
    notifyListeners();
  }
  
  // Reset specific zakat
  void resetZakatMaal() {
    _maalInput = ZakatMaalInput();
    _maalResult = null;
    notifyListeners();
  }
  
  void resetZakatPenghasilan() {
    _penghasilanInput = ZakatPenghasilanInput();
    _penghasilanResult = null;
    notifyListeners();
  }
  
  void resetZakatPerdagangan() {
    _perdaganganInput = ZakatPerdaganganInput();
    _perdaganganResult = null;
    notifyListeners();
  }
  
  void resetZakatPertanian() {
    _pertanianInput = ZakatPertanianInput();
    _pertanianResult = null;
    notifyListeners();
  }
  
  void resetZakatFitrah() {
    _fitrahInput = ZakatFitrahInput();
    _fitrahResult = null;
    notifyListeners();
  }
  
  // Format currency
  String formatRupiah(double amount) {
    final formatter = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatter';
  }
}