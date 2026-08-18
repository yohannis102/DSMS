import 'package:flutter/material.dart';
import '../package/package_model.dart';
import '../package/package_service.dart';
import '../schedule/schedule_model.dart';
import '../schedule/schedule_service.dart';
import '../student/student_model.dart';
import '../student/student_service.dart';
import 'enrolment_model.dart';
import 'enrolment_service.dart';

class EnrolmentController extends ChangeNotifier {
  final EnrolmentService _service = EnrolmentService();
  final StudentService _studentService = StudentService();
  final ScheduleService _scheduleService = ScheduleService();
  final PackageService _packageService = PackageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<EnrolmentModel> _enrolments = [];
  List<EnrolmentModel> get enrolments => _enrolments;

  // Dropdown dependency caches
  List<StudentModel> _availableStudents = [];
  List<StudentModel> get availableStudents => _availableStudents;

  List<ScheduleModel> _availableSchedules = [];
  List<ScheduleModel> get availableSchedules => _availableSchedules;

  List<PackageModel> _availablePackages = [];
  List<PackageModel> get availablePackages => _availablePackages;

  // Search & Filter State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  // Pagination State
  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _pageSize = 8;
  int get pageSize => _pageSize;

  EnrolmentController() {
    loadEnrolments();
    loadDependencies();
  }

  // Filtered list
  List<EnrolmentModel> get filteredEnrolments {
    return _enrolments.where((e) {
      // Search matching (student name, schedule code, instructor, remarks, id)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchStudent = e.studentName.toLowerCase().contains(q);
        final matchEmail = (e.student?.email ?? '').toLowerCase().contains(q);
        final matchCode = e.scheduleCode.toLowerCase().contains(q);
        final matchInstructor = e.instructorName.toLowerCase().contains(q);
        final matchRemarks = e.remarks.toLowerCase().contains(q);
        final matchPackage = e.packageName.toLowerCase().contains(q);
        final matchId = e.id.toLowerCase().contains(q);

        if (!matchStudent &&
            !matchEmail &&
            !matchCode &&
            !matchInstructor &&
            !matchRemarks &&
            !matchPackage &&
            !matchId) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter != 'All') {
        if (e.status.toLowerCase() != _statusFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Pagination
  int get totalPages {
    final count = filteredEnrolments.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  List<EnrolmentModel> get paginatedEnrolments {
    final list = filteredEnrolments;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) return [];
    final endIndex = startIndex + _pageSize;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  // Metrics
  int get totalCount => _enrolments.length;

  int get activeCount =>
      _enrolments.where((e) => e.status.toLowerCase() == 'active').length;

  int get completedCount =>
      _enrolments.where((e) => e.status.toLowerCase() == 'completed').length;

  double get totalRevenue =>
      _enrolments.fold(0.0, (sum, e) => sum + e.amount);

  String get formattedTotalRevenue {
    final parts = totalRevenue.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return 'ETB $formattedInt.$decimalPart';
  }

  Future<void> loadEnrolments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _enrolments = await _service.fetchEnrolments();
      // Reset to first page if page is out of bounds
      if (_currentPage > totalPages) {
        _currentPage = 1;
      }
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDependencies() async {
    try {
      final results = await Future.wait([
        _studentService.fetchStudents(),
        _scheduleService.fetchSchedules(),
        _packageService.fetchPackages(),
      ]);

      _availableStudents = results[0] as List<StudentModel>;
      _availableSchedules = results[1] as List<ScheduleModel>;
      _availablePackages = results[2] as List<PackageModel>;
      notifyListeners();
    } catch (_) {
      // Dependencies fallback gracefully
    }
  }

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

  Future<bool> createEnrolment({
    required String scheduleId,
    required String packageId,
    required String studentId,
    String remarks = 'Enrolled by admin',
    Map<String, dynamic>? extraContext,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createEnrollment(
        scheduleId: scheduleId,
        packageId: packageId,
        studentId: studentId,
        remarks: remarks,
        extraContext: extraContext,
      );

      final index = _enrolments.indexWhere((e) => e.id == created.id);
      if (index != -1) {
        _enrolments[index] = created;
      } else {
        _enrolments.insert(0, created);
      }

      _currentPage = 1;
      return true;
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateEnrolment(String id, Map<String, dynamic> data) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateEnrollment(id, data);
      final index = _enrolments.indexWhere((e) => e.id == id);
      if (index != -1) {
        _enrolments[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEnrolment(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.deleteEnrollment(id);
      if (success) {
        _enrolments.removeWhere((e) => e.id == id);
        if (_currentPage > totalPages) {
          _currentPage = totalPages > 0 ? totalPages : 1;
        }
      }
      return success;
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String extractErrorMessage(dynamic e) => _service.extractErrorMessage(e);
}
