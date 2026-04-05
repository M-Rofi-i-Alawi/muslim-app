import 'package:flutter/material.dart';
import '../model/surat_model.dart';
import '../repository/surat_repository.dart';

class SuratViewModel extends ChangeNotifier {
  final SuratRepository repository;

  SuratViewModel(this.repository);

  bool isLoading = false;
  String error = '';
  List<SuratModel> suratList = [];

  Future<void> getSurat() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      suratList = await repository.fetchSurat();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}