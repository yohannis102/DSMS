import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_model.dart';
import '../auth/auth_service.dart';
import '../enrolment/enrolment_model.dart';
import '../enrolment/enrolment_service.dart';
import 'payment_model.dart';
import 'payment_service.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();
  final EnrolmentService _enrolmentService = EnrolmentService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  List<EnrolmentModel> _availableEnrolments = [];
  List<EnrolmentModel> get availableEnrolments => _availableEnrolments;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAdmin {
    if (_currentUser == null) return true; // Default admin if not specified
    final r = _currentUser!.role.trim().toLowerCase();
    return r == 'admin' || r == 'superadmin' || r == 'manager';
  }

  // Filter and Pagination State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _pageSize = 8;
  int get pageSize => _pageSize;

  PaymentController() {
    loadPayments();
    loadDependencies();
  }

  /// Filtered list of payments based on query and status filter
  List<PaymentModel> get filteredPayments {
    return _payments.where((p) {
      // 1. Status Filter
      if (_statusFilter != 'All') {
        if (_statusFilter.toLowerCase() == 'paid' && !p.isPaid) return false;
        if (_statusFilter.toLowerCase() == 'unpaid' && p.isPaid) return false;
      }

      // 2. Search Query (Reference No, Student Name, Email, Schedule Code, Remarks)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final refMatch = p.referenceNo.toLowerCase().contains(query);
        final nameMatch = p.student.fullName.toLowerCase().contains(query);
        final emailMatch = p.student.email.toLowerCase().contains(query);
        final schedMatch = p.enrollment.schedule.scheduleCode.toLowerCase().contains(query);
        final remarksMatch = p.remarks.toLowerCase().contains(query);
        final amountMatch = p.amount.toString().contains(query);

        return refMatch || nameMatch || emailMatch || schedMatch || remarksMatch || amountMatch;
      }

      return true;
    }).toList();
  }

  /// Paginated payments slice
  List<PaymentModel> get paginatedPayments {
    final list = filteredPayments;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) {
      return [];
    }
    final endIndex = (startIndex + _pageSize) > list.length ? list.length : startIndex + _pageSize;
    return list.sublist(startIndex, endIndex);
  }

  int get totalPages {
    final count = filteredPayments.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  // KPI Metrics
  double get totalRevenue {
    return _payments
        .where((p) => p.isPaid)
        .fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  int get totalCount => _payments.length;

  int get paidCount => _payments.where((p) => p.isPaid).length;

  int get unpaidCount => _payments.where((p) => !p.isPaid).length;

  /// Loads all payments from service
  Future<void> loadPayments({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _service.fetchPayments(forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads enrollments and current user info
  Future<void> loadDependencies() async {
    try {
      final user = await _authService.getSavedUser();
      _currentUser = user;
    } catch (_) {}

    try {
      final enrollments = await _enrolmentService.fetchEnrolments();
      _availableEnrolments = enrollments;
    } catch (_) {}

    notifyListeners();
  }

  /// Record a new payment
  Future<PaymentModel> createPayment({
    required String enrollmentId,
    required double amount,
    String? remarks,
    String? status,
    XFile? proofImage,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final created = await _service.createPayment(
        enrollmentId: enrollmentId,
        amount: amount,
        remarks: remarks,
        status: status,
        proofImage: proofImage,
      );

      // Add to list and sort by date
      _payments.insert(0, created);
      notifyListeners();
      return created;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update payment status / remarks
  Future<PaymentModel> updatePayment({
    required String id,
    required String status,
    String? remarks,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final updated = await _service.updatePayment(
        id: id,
        status: status,
        remarks: remarks,
      );

      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updated;
      }
      notifyListeners();
      return updated;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Delete a payment record
  Future<bool> deletePayment(String id) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final success = await _service.deletePayment(id);
      if (success) {
        _payments.removeWhere((p) => p.id == id);
      }
      notifyListeners();
      return success;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Filter & Search Updaters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
}
