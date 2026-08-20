import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'enrolment_model.dart';

class EnrolmentService {
  final Dio _dio = ApiClient().dio;

  Future<List<EnrolmentModel>> fetchEnrolments({
    bool forceRefresh = false,
  }) async {
    Response response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
    try {
      response = await _dio.get('/api/enrollments', options: options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          response = await _dio.get('/api/enrolments', options: options);
        } on DioException {
          response = await _dio.get('/enrollments', options: options);
        }
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['enrollments'] is List) {
          list = data['enrollments'] as List<dynamic>;
        } else if (data['enrolments'] is List) {
          list = data['enrolments'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => EnrolmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<EnrolmentModel?> getEnrollmentById(String id) async {
    Response response;
    try {
      response = await _dio.get('/api/enrollments/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get('/enrollments/$id');
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final data = ApiClient.parseResponseData(response.data);
      if (data is Map<String, dynamic>) {
        if (data['enrollment'] is Map<String, dynamic>) {
          return EnrolmentModel.fromJson(
            data['enrollment'] as Map<String, dynamic>,
          );
        }
        return EnrolmentModel.fromJson(data);
      }
    }
    return null;
  }

  Future<EnrolmentModel> createEnrollment({
    required String scheduleId,
    required String packageId,
    required String studentId,
    String remarks = 'Enrolled by admin',
    Map<String, dynamic>? extraContext,
  }) async {
    final payload = {
      'scheduleId': scheduleId.trim(),
      'packageId': packageId.trim(),
      'student': studentId.trim(),
      'remarks': remarks.trim().isEmpty ? 'Enrolled by admin' : remarks.trim(),
    };

    Response response;
    try {
      response = await _dio.post('/api/enrollments', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          response = await _dio.post('/api/enrolments', data: payload);
        } on DioException {
          response = await _dio.post('/enrollments', data: payload);
        }
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      if (data is Map<String, dynamic>) {
        if (data['enrollment'] is Map<String, dynamic>) {
          return EnrolmentModel.fromJson(
            data['enrollment'] as Map<String, dynamic>,
          );
        }
        return EnrolmentModel.fromJson(data);
      }
    }
    return EnrolmentModel.fromJson(payload);
  }

  Future<EnrolmentModel> updateEnrollment(
    String id,
    Map<String, dynamic> data,
  ) async {
    Response response;
    try {
      response = await _dio.put('/api/enrollments/$id', data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          response = await _dio.patch('/api/enrollments/$id', data: data);
        } on DioException {
          response = await _dio.put('/enrollments/$id', data: data);
        }
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic resData = ApiClient.parseResponseData(response.data);
      if (resData is Map<String, dynamic>) {
        if (resData['enrollment'] is Map<String, dynamic>) {
          return EnrolmentModel.fromJson(
            resData['enrollment'] as Map<String, dynamic>,
          );
        }
        return EnrolmentModel.fromJson(resData);
      }
    }
    return EnrolmentModel.fromJson({'_id': id, ...data});
  }

  Future<bool> deleteEnrollment(String id) async {
    Response response;
    try {
      response = await _dio.delete('/api/enrollments/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.delete('/enrollments/$id');
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
          // 1. Check validation errors array from express-validator
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
          // 2. Check top-level message (e.g. duplicate / student required)
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            return data['message'].toString();
          }
          if (data['error'] != null && data['error'].toString().isNotEmpty) {
            return data['error'].toString();
          }
          if (data['msg'] != null && data['msg'].toString().isNotEmpty) {
            return data['msg'].toString();
          }
          return 'Server error (${e.response?.statusCode})';
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      return e.message ?? 'Network connection error';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
