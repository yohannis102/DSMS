import 'package:flutter/material.dart';
import 'schedule_model.dart';
import 'schedule_service.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> get schedules => _schedules;

  ScheduleController() {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await _service.fetchSchedules();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
