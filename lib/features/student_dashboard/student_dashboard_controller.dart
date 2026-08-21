import 'package:flutter/material.dart';
import '../auth/auth_model.dart';
import '../auth/auth_service.dart';
import 'student_dashboard_service.dart';

class StudentDashboardController extends ChangeNotifier {
  final StudentDashboardService _service = StudentDashboardService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentDashboardData _data = const StudentDashboardData();
  StudentDashboardData get data => _data;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  StudentDashboardController() {
    init();
  }

  Future<void> init() async {
    _currentUser = await _authService.getSavedUser();
    notifyListeners();
    await loadDashboardData();
  }

  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final dashboardData = await _service.fetchDashboardData(
        forceRefresh: forceRefresh,
      );
      _data = dashboardData;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await loadDashboardData(forceRefresh: true);
  }
}
