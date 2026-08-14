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

  StudentController() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _service.fetchStudents();
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


