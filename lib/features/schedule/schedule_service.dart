import 'dart:math';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'schedule_model.dart';

class ScheduleService {
  final Dio _dio = ApiClient().dio;

  // In-memory mock store for offline/demo mode CRUD operations
  static final List<ScheduleModel> _mockSchedules = [
    const ScheduleModel(
      id: 'SCH-2026-001',
      scheduleCode: 'SCH-2026-001',
      date: '2026-08-18',
      time: '08:00 AM - 10:00 AM',
      instructor: 'Michael Scott',
      slotsAvailable: 4,
      totalSlots: 5,
      amount: 1500.0,
      remarks: 'Beginner Traffic & Basic Road Navigation Lesson',
      status: 'Available',
    ),
    const ScheduleModel(
      id: 'SCH-2026-002',
      scheduleCode: 'SCH-2026-002',
      date: '2026-08-19',
      time: '10:30 AM - 12:30 PM',
      instructor: 'Pam Beesly',
      slotsAvailable: 2,
      totalSlots: 4,
      amount: 1800.0,
      remarks: 'Parallel Parking & Defensive Driving Techniques',
      status: 'Available',
    ),
    const ScheduleModel(
      id: 'SCH-2026-003',
      scheduleCode: 'SCH-2026-003',
      date: '2026-08-20',
      time: '01:00 PM - 03:00 PM',
      instructor: 'Jim Halpert',
      slotsAvailable: 0,
      totalSlots: 3,
      amount: 2000.0,
      remarks: 'Expressway & Night Driving Simulation (Fully Booked)',
      status: 'Full',
    ),
    const ScheduleModel(
      id: 'SCH-2026-004',
      scheduleCode: 'SCH-2026-004',
      date: '2026-08-22',
      time: '03:30 PM - 05:30 PM',
      instructor: 'Dwight Schrute',
      slotsAvailable: 5,
      totalSlots: 5,
      amount: 2500.0,
      remarks: 'Advanced Hazard Perception & Emergency Braking',
      status: 'Available',
    ),
    const ScheduleModel(
      id: 'SCH-2026-005',
      scheduleCode: 'SCH-2026-005',
      date: '2026-08-25',
      time: '08:30 AM - 10:30 AM',
      instructor: 'Stanley Hudson',
      slotsAvailable: 1,
      totalSlots: 4,
      amount: 1500.0,
      remarks: 'Manual Transmission Clutch Control Refresher',
      status: 'Available',
    ),
  ];

  static String generateScheduleCode() {
    final now = DateTime.now();
    final year = now.year;
    final randomSuffix = (100 + Random().nextInt(900)).toString();
    final code = 'SCH-$year-$randomSuffix';
    // Ensure uniqueness
    if (_mockSchedules.any((s) => s.scheduleCode == code)) {
      return 'SCH-$year-${Random().nextInt(9000) + 1000}';
    }
    return code;
  }

  Future<List<ScheduleModel>> fetchSchedules() async {
    Response? response;
    try {
      try {
        response = await _dio.get('/api/schedules');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get('/schedules');
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        ApiClient().setMockMode(false);
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          if (data['schedules'] is List) {
            list = data['schedules'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          list = data;
        }
        return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      ApiClient().setMockMode(true);
    }

    // Return in-memory mock schedules copy
    return List<ScheduleModel>.from(_mockSchedules);
  }

  Future<ScheduleModel> createSchedule(Map<String, dynamic> scheduleData) async {
    final code = scheduleData['scheduleCode']?.toString().isNotEmpty == true
        ? scheduleData['scheduleCode'].toString()
        : generateScheduleCode();

    final payload = Map<String, dynamic>.from(scheduleData);
    payload['scheduleCode'] = code;
    if (!payload.containsKey('_id') && !payload.containsKey('id')) {
      payload['id'] = code;
    }

    try {
      Response response;
      try {
        response = await _dio.post('/api/schedules', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.post('/schedules', data: payload);
        } else {
          rethrow;
        }
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['schedule'] is Map<String, dynamic>) {
            final created = ScheduleModel.fromJson(data['schedule'] as Map<String, dynamic>);
            _mockSchedules.insert(0, created);
            return created;
          }
          final created = ScheduleModel.fromJson(data);
          _mockSchedules.insert(0, created);
          return created;
        }
      }
    } catch (_) {
      // Backend unreachable; persist in mock state
    }

    final newSchedule = ScheduleModel.fromJson(payload);
    _mockSchedules.insert(0, newSchedule);
    return newSchedule;
  }

  Future<ScheduleModel> updateSchedule(String id, Map<String, dynamic> scheduleData) async {
    final payload = Map<String, dynamic>.from(scheduleData);
    if (!payload.containsKey('id') && !payload.containsKey('_id')) {
      payload['id'] = id;
    }

    try {
      Response response;
      try {
        response = await _dio.put('/api/schedules/$id', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          try {
            response = await _dio.patch('/api/schedules/$id', data: payload);
          } on DioException {
            response = await _dio.put('/schedules/$id', data: payload);
          }
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['schedule'] is Map<String, dynamic>) {
            final updated = ScheduleModel.fromJson(data['schedule'] as Map<String, dynamic>);
            _updateLocalMock(id, updated);
            return updated;
          }
          final updated = ScheduleModel.fromJson(data);
          _updateLocalMock(id, updated);
          return updated;
        }
      }
    } catch (_) {
      // Backend unreachable; persist in mock state
    }

    final updated = ScheduleModel.fromJson(payload);
    _updateLocalMock(id, updated);
    return updated;
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      Response response;
      try {
        response = await _dio.delete('/api/schedules/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.delete('/schedules/$id');
        } else {
          rethrow;
        }
      }
      final success = response.statusCode == 200 || response.statusCode == 204;
      if (success) {
        _mockSchedules.removeWhere((s) => s.id == id || s.scheduleCode == id);
      }
      return success;
    } catch (_) {
      _mockSchedules.removeWhere((s) => s.id == id || s.scheduleCode == id);
      return true;
    }
  }

  void _updateLocalMock(String id, ScheduleModel updated) {
    final index = _mockSchedules.indexWhere((s) => s.id == id || s.scheduleCode == id);
    if (index != -1) {
      _mockSchedules[index] = updated;
    } else {
      _mockSchedules.insert(0, updated);
    }
  }

  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?.toString() ??
              'Server error (${e.response?.statusCode})';
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      return e.message ?? 'Network connection error';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
