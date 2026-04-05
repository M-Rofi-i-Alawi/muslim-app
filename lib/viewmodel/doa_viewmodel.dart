import 'package:flutter/material.dart';
import '../model/doa_model.dart';
import '../repository/doa_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository repository;

  DoaViewModel(this.repository);

  bool isLoading = false;
  String error = '';

  List<DoaModel> doaList = [];
  List<DoaModel> filteredDoa = [];

  Future<void> getDoa() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      doaList = await repository.fetchDoa();
      filteredDoa = doaList;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchDoa(String keyword) {
    if (keyword.isEmpty) {
      filteredDoa = doaList;
    } else {
      filteredDoa = doaList
          .where((doa) =>
              doa.judul.toLowerCase().contains(keyword.toLowerCase()) ||
              doa.latin.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}