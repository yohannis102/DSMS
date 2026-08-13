import 'package:flutter/material.dart';
import 'admin_dashboard_model.dart';
import 'admin_dashboard_service.dart';

class AdminDashboardController extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AdminDashboardModel? _dashboardData;
  AdminDashboardModel? get dashboardData => _dashboardData;

  int get instructorCount => _dashboardData?.instructorCount ?? 8;
  int get studentCount => _dashboardData?.studentCount ?? 20;
  int get enrolmentCount => _dashboardData?.enrolmentCount ?? 15;
  double get totalIncome => _dashboardData?.totalIncome ?? 20000.0;
  List<MonthlyIncomeData> get monthlyIncomeData =>
      _dashboardData?.monthlyIncomeData ?? [];

  AdminDashboardController() {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardSummary();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshData() {
    loadDashboard();
  }
}
