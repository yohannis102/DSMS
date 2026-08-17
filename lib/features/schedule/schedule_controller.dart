import 'package:flutter/material.dart';
import 'schedule_model.dart';
import 'schedule_service.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> get schedules => _schedules;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  String _instructorFilter = 'All';
  String get instructorFilter => _instructorFilter;

  ScheduleController() {
    loadSchedules();
  }

  String generateNextCode() {
    return ScheduleService.generateScheduleCode();
  }

  List<String> get availableInstructors {
    final list = _schedules
        .map((s) => s.instructor.trim())
        .where((name) => name.isNotEmpty && name != 'Unassigned')
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<ScheduleModel> get filteredSchedules {
    return _schedules.where((schedule) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          schedule.scheduleCode.toLowerCase().contains(query) ||
          schedule.instructor.toLowerCase().contains(query) ||
          schedule.remarks.toLowerCase().contains(query) ||
          schedule.date.toLowerCase().contains(query) ||
          schedule.time.toLowerCase().contains(query);

      bool matchesStatus = true;
      if (_statusFilter != 'All') {
        if (_statusFilter == 'Available') {
          matchesStatus = schedule.isAvailable;
        } else if (_statusFilter == 'Full') {
          matchesStatus = schedule.isFull || schedule.status.toLowerCase() == 'full';
        } else {
          matchesStatus = schedule.status.toLowerCase() == _statusFilter.toLowerCase();
        }
      }

      final matchesInstructor = _instructorFilter == 'All' ||
          schedule.instructor.toLowerCase() == _instructorFilter.toLowerCase();

      return matchesSearch && matchesStatus && matchesInstructor;
    }).toList();
  }

  int get totalCount => _schedules.length;

  int get availableSlotsCount => _schedules.fold<int>(
        0,
        (sum, s) => sum + (s.status.toLowerCase() != 'cancelled' ? s.slotsAvailable : 0),
      );

  int get activeCount => _schedules.where((s) => s.isAvailable).length;

  int get fullyBookedCount => _schedules.where((s) => s.isFull || s.status.toLowerCase() == 'full').length;

  double get totalExpectedValue => _schedules.fold<double>(
        0.0,
        (sum, s) => sum + s.amount,
      );

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setInstructorFilter(String instructor) {
    _instructorFilter = instructor;
    notifyListeners();
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules = await _service.fetchSchedules();
    } catch (e) {
      _errorMessage = _service.extractErrorMessage(e);
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSchedule(Map<String, dynamic> scheduleData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.createSchedule(scheduleData);
      await loadSchedules();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> scheduleData) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.updateSchedule(id, scheduleData);
      await loadSchedules();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String id) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.deleteSchedule(id);
      await loadSchedules();
    } catch (e) {
      final msg = _service.extractErrorMessage(e);
      throw Exception(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
