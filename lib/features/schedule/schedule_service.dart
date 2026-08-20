import 'dart:math';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'schedule_model.dart';

class ScheduleService {
  final Dio _dio = ApiClient().dio;

  static String generateScheduleCode() {
    final now = DateTime.now();
    final year = now.year;
    final randomSuffix = (100 + Random().nextInt(900)).toString();
    return 'SCH-$year-$randomSuffix';
  }

  Future<List<ScheduleModel>> fetchSchedules({bool forceRefresh = false}) async {
    Response response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
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
    return [];
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
      final dynamic data = ApiClient.parseResponseData(response.data);
      if (data is Map<String, dynamic>) {
        if (data['schedule'] is Map<String, dynamic>) {
          return ScheduleModel.fromJson(
            data['schedule'] as Map<String, dynamic>,
          );
        }
        return ScheduleModel.fromJson(data);
      }
    }
    return ScheduleModel.fromJson(payload);
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
      final dynamic data = ApiClient.parseResponseData(response.data);
      if (data is Map<String, dynamic>) {
        if (data['schedule'] is Map<String, dynamic>) {
          return ScheduleModel.fromJson(
            data['schedule'] as Map<String, dynamic>,
          );
        }
        return ScheduleModel.fromJson(data);
      }
    }
    return ScheduleModel.fromJson(payload);
  }

  Future<bool> deleteSchedule(String id) async {
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
    return response.statusCode == 200 || response.statusCode == 204;
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
