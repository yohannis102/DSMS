import 'package:flutter/material.dart';
import 'enrolment_model.dart';
import 'enrolment_service.dart';

class EnrolmentController extends ChangeNotifier {
  final EnrolmentService _service = EnrolmentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<EnrolmentModel> _enrolments = [];
  List<EnrolmentModel> get enrolments => _enrolments;

  EnrolmentController() {
    loadEnrolments();
  }

  Future<void> loadEnrolments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _enrolments = await _service.fetchEnrolments();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
