import 'package:flutter/material.dart';
import 'admin_dashboard_model.dart';
import 'admin_dashboard_service.dart';

class AdminDashboardController extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AdminDashboardData? _dashboardData;
  AdminDashboardData? get dashboardData => _dashboardData;

  DashboardStats get stats =>
      _dashboardData?.stats ?? const DashboardStats();

  int get instructorCount => stats.instructorCount;
  int get studentCount => stats.studentCount;
  int get enrollmentCount => stats.enrollmentCount;
  double get totalIncome => stats.totalIncome;

  List<PaymentStatusBreakdown> get paymentBreakdown =>
      _dashboardData?.paymentBreakdown ?? [];

  List<MonthlyIncome> get monthlyIncome =>
      _dashboardData?.monthlyIncome ?? [];

  List<MonthlyEnrollment> get monthlyEnrollments =>
      _dashboardData?.monthlyEnrollments ?? [];

  List<PackagePopularity> get packagePopularity =>
      _dashboardData?.packagePopularity ?? [];

  List<InstructorWorkload> get instructorWorkload =>
      _dashboardData?.instructorWorkload ?? [];

  List<RecentPayment> get recentPayments =>
      _dashboardData?.recentPayments ?? [];

  AdminDashboardController() {
    loadDashboard();
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData =
          await _service.getDashboardData(forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshData() {
    loadDashboard(forceRefresh: true);
  }
}
