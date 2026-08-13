import 'package:flutter/material.dart';
import 'instructors_model.dart';
import 'instructors_service.dart';

class InstructorsController extends ChangeNotifier {
  final InstructorsService _service = InstructorsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<InstructorsModel> _instructors = [];
  List<InstructorsModel> get instructors => _instructors;

  InstructorsController() {
    loadInstructors();
  }

  Future<void> loadInstructors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _instructors = await _service.fetchInstructors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
