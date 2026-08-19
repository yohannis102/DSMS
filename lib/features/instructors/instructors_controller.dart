import 'package:flutter/material.dart';
import 'instructors_model.dart';
import 'instructors_service.dart';

class InstructorsController extends ChangeNotifier {
  final InstructorsService _service = InstructorsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<InstructorsModel> _instructors = [];
  List<InstructorsModel> get instructors => _instructors;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  InstructorsController() {
    loadInstructors();
  }

  List<InstructorsModel> get filteredInstructors {
    return _instructors.where((instructor) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          instructor.name.toLowerCase().contains(query) ||
          instructor.email.toLowerCase().contains(query) ||
          instructor.phone.toLowerCase().contains(query) ||
          instructor.username.toLowerCase().contains(query) ||
          (instructor.drivingExperience?.toLowerCase().contains(query) ?? false) ||
          (instructor.vehicleType?.toLowerCase().contains(query) ?? false);

      final matchesStatus = _statusFilter == 'All' ||
          instructor.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalCount => _instructors.length;
  int get activeCount =>
      _instructors.where((i) => i.status.toLowerCase() == 'active').length;
  int get pendingCount =>
      _instructors.where((i) => i.status.toLowerCase() == 'pending').length;
  int get inactiveCount =>
      _instructors.where((i) => i.status.toLowerCase() == 'inactive').length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> loadInstructors({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _instructors = await _service.fetchInstructors(forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      _instructors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInstructor(Map<String, dynamic> instructorData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.createInstructor(instructorData);
      await loadInstructors();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateInstructor(
      String id, Map<String, dynamic> instructorData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.updateInstructor(id, instructorData);
      await loadInstructors();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteInstructor(String id) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.deleteInstructor(id);
      await loadInstructors();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
