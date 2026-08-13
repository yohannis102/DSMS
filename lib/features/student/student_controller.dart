import 'package:flutter/material.dart';
import 'student_model.dart';
import 'student_service.dart';

class StudentController extends ChangeNotifier {
  final StudentService _service = StudentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  StudentController() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await _service.fetchStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
