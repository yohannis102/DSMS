import 'package:flutter/material.dart';
import 'package_model.dart';
import 'package_service.dart';

class PackageController extends ChangeNotifier {
  final PackageService _service = PackageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PackageModel> _packages = [];
  List<PackageModel> get packages => _packages;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _sortFilter = 'all'; // 'all', 'price_asc', 'price_desc', 'under_10k', '10k_to_20k', 'over_20k'
  String get sortFilter => _sortFilter;

  PackageController() {
    loadPackages();
  }

  List<PackageModel> get filteredPackages {
    var result = _packages.where((pkg) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          pkg.name.toLowerCase().contains(query) ||
          pkg.description.toLowerCase().contains(query) ||
          pkg.id.toLowerCase().contains(query) ||
          pkg.price.toString().contains(query);

      bool matchesFilter = true;
      if (_sortFilter == 'under_10k') {
        matchesFilter = pkg.price < 10000;
      } else if (_sortFilter == '10k_to_20k') {
        matchesFilter = pkg.price >= 10000 && pkg.price <= 20000;
      } else if (_sortFilter == 'over_20k') {
        matchesFilter = pkg.price > 20000;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    if (_sortFilter == 'price_asc') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortFilter == 'price_desc') {
      result.sort((a, b) => b.price.compareTo(a.price));
    }

    return result;
  }

  int get totalCount => _packages.length;

  double get averagePrice {
    if (_packages.isEmpty) return 0.0;
    final total = _packages.fold<double>(0.0, (sum, item) => sum + item.price);
    return total / _packages.length;
  }

  double get highestPrice {
    if (_packages.isEmpty) return 0.0;
    return _packages.map((e) => e.price).reduce((a, b) => a > b ? a : b);
  }

  double get lowestPrice {
    if (_packages.isEmpty) return 0.0;
    return _packages.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortFilter(String filter) {
    _sortFilter = filter;
    notifyListeners();
  }

  Future<void> loadPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _packages = await _service.fetchPackages();
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      _packages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPackage(Map<String, dynamic> packageData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.createPackage(packageData);
      await loadPackages();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updatePackage(
      String id, Map<String, dynamic> packageData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.updatePackage(id, packageData);
      await loadPackages();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deletePackage(String id) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.deletePackage(id);
      await loadPackages();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
