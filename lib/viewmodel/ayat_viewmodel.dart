import 'package:flutter/material.dart';
import '../model/ayat_model.dart';
import '../repository/ayat_repository.dart';

class AyatViewModel extends ChangeNotifier {
  final AyatRepository repository;

  AyatViewModel(this.repository);

  bool isLoading = false;
  String error = '';
  List<AyatModel> ayatList = [];

  Future<void> getAyat(int nomorSurat) async {
    try {
      isLoading = true;
      error = '';
      ayatList = []; // Reset list
      notifyListeners();

      ayatList = await repository.fetchAyat(nomorSurat);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}