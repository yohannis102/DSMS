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
      instructorId: 'ins-001',
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
      instructorId: 'ins-002',
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
      instructorId: 'ins-003',
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
      instructorId: 'ins-004',
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
      instructorId: 'ins-005',
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

  Future<List<ScheduleModel>> fetchSchedules({bool forceRefresh = false}) async {
    Response? response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
    try {
      try {
        response = await _dio.get('/api/schedules', options: options);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get('/schedules', options: options);
        } else {
          rethrow;
        }
      }

      if ((response.statusCode == 200 || response.statusCode == 304) &&
          response.data != null) {
        ApiClient().setMockMode(false);
        final dynamic data = ApiClient.parseResponseData(response.data);
        List<dynamic> list = [];
        if (data is Map) {
          if (data['schedules'] is List) {
            list = data['schedules'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          list = data;
        }
        return list
            .whereType<Map>()
            .map((e) => ScheduleModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
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

    // Ensure instructor ID is passed
    if (payload['instructorId'] != null &&
        payload['instructorId'].toString().isNotEmpty) {
      payload['instructor'] = payload['instructorId'];
    }

    // Format date as ISO if YYYY-MM-DD
    final rawDate = payload['date']?.toString() ?? '';
    final rawTime = payload['time']?.toString() ?? '';
    if (rawDate.isNotEmpty && !rawDate.contains('T')) {
      try {
        final dateParts = rawDate.split('-');
        if (dateParts.length == 3) {
          int hour = 9;
          int minute = 0;
          if (rawTime.isNotEmpty) {
            final timeMatch = RegExp(
              r'(\d{1,2}):(\d{2})\s*(AM|PM)',
              caseSensitive: false,
            ).firstMatch(rawTime);
            if (timeMatch != null) {
              hour = int.parse(timeMatch.group(1)!);
              minute = int.parse(timeMatch.group(2)!);
              final period = timeMatch.group(3)!.toUpperCase();
              if (period == 'PM' && hour < 12) hour += 12;
              if (period == 'AM' && hour == 12) hour = 0;
            }
          }
          final dt = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            hour,
            minute,
          );
          payload['date'] = dt.toUtc().toIso8601String();
        }
      } catch (_) {}
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['schedule'] is Map<String, dynamic>) {
            final created = ScheduleModel.fromJson(
              data['schedule'] as Map<String, dynamic>,
            );
            _mockSchedules.insert(0, created);
            return created;
          }
          final created = ScheduleModel.fromJson(data);
          _mockSchedules.insert(0, created);
          return created;
        }
      }
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
      // Offline fallback
    } catch (e) {
      if (e is! DioException) rethrow;
    }

    final newSchedule = ScheduleModel.fromJson(payload);
    _mockSchedules.insert(0, newSchedule);
    return newSchedule;
  }

  Future<ScheduleModel> updateSchedule(
    String id,
    Map<String, dynamic> scheduleData,
  ) async {
    final payload = Map<String, dynamic>.from(scheduleData);
    if (!payload.containsKey('id') && !payload.containsKey('_id')) {
      payload['id'] = id;
    }

    // Ensure instructor ID is passed
    if (payload['instructorId'] != null &&
        payload['instructorId'].toString().isNotEmpty) {
      payload['instructor'] = payload['instructorId'];
    }

    // Format date as ISO if YYYY-MM-DD
    final rawDate = payload['date']?.toString() ?? '';
    final rawTime = payload['time']?.toString() ?? '';
    if (rawDate.isNotEmpty && !rawDate.contains('T')) {
      try {
        final dateParts = rawDate.split('-');
        if (dateParts.length == 3) {
          int hour = 9;
          int minute = 0;
          if (rawTime.isNotEmpty) {
            final timeMatch = RegExp(
              r'(\d{1,2}):(\d{2})\s*(AM|PM)',
              caseSensitive: false,
            ).firstMatch(rawTime);
            if (timeMatch != null) {
              hour = int.parse(timeMatch.group(1)!);
              minute = int.parse(timeMatch.group(2)!);
              final period = timeMatch.group(3)!.toUpperCase();
              if (period == 'PM' && hour < 12) hour += 12;
              if (period == 'AM' && hour == 12) hour = 0;
            }
          }
          final dt = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            hour,
            minute,
          );
          payload['date'] = dt.toUtc().toIso8601String();
        }
      } catch (_) {}
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
            final updated = ScheduleModel.fromJson(
              data['schedule'] as Map<String, dynamic>,
            );
            _updateLocalMock(id, updated);
            return updated;
          }
          final updated = ScheduleModel.fromJson(data);
          _updateLocalMock(id, updated);
          return updated;
        }
      }
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
    } catch (e) {
      if (e is! DioException) rethrow;
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
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
      _mockSchedules.removeWhere((s) => s.id == id || s.scheduleCode == id);
      return true;
    } catch (_) {
      _mockSchedules.removeWhere((s) => s.id == id || s.scheduleCode == id);
      return true;
    }
  }

  void _updateLocalMock(String id, ScheduleModel updated) {
    final index = _mockSchedules.indexWhere(
      (s) => s.id == id || s.scheduleCode == id,
    );
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
          // 1. Check express-validator errors array
          if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            final messages = (data['errors'] as List)
                .map((item) {
                  if (item is Map) {
                    return item['msg']?.toString() ??
                        item['message']?.toString() ??
                        item['error']?.toString();
                  }
                  return item?.toString();
                })
                .where((msg) => msg != null && msg.trim().isNotEmpty)
                .join(', ');
            if (messages.isNotEmpty) return messages;
          }
          // 2. Check message, error, or msg field
          return data['message']?.toString() ??
              data['error']?.toString() ??
              data['msg']?.toString() ??
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
