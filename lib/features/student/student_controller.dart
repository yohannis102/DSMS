import 'package:flutter/material.dart';
import 'student_model.dart';
import 'student_service.dart';

class StudentController extends ChangeNotifier {
  final StudentService _service = StudentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  StudentController() {
    loadStudents();
  }

  List<StudentModel> get filteredStudents {
    return _students.where((student) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.phone.toLowerCase().contains(query) ||
          student.username.toLowerCase().contains(query) ||
          student.address.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' ||
          student.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalCount => _students.length;
  int get activeCount =>
      _students.where((s) => s.status.toLowerCase() == 'active').length;
  int get pendingCount =>
      _students.where((s) => s.status.toLowerCase() == 'pending').length;
  int get inactiveCount =>
      _students.where((s) => s.status.toLowerCase() == 'inactive').length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> loadStudents({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _service.fetchStudents(forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStudent(Map<String, dynamic> studentData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.createStudent(studentData);
      await loadStudents();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(
      String id, Map<String, dynamic> studentData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.updateStudent(id, studentData);
      await loadStudents();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.deleteStudent(id);
      await loadStudents();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}


