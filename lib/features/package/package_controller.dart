import 'package:flutter/material.dart';
import 'package_model.dart';
import 'package_service.dart';

class PackageController extends ChangeNotifier {
  final PackageService _service = PackageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PackageModel> _packages = [];
  List<PackageModel> get packages => _packages;

  PackageController() {
    loadPackages();
  }

  Future<void> loadPackages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _packages = await _service.fetchPackages();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
