import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'student_model.dart';

class StudentService {
  final Dio _dio = ApiClient().dio;

  Future<List<StudentModel>> fetchStudents() async {
    final response = await _dio.get('/api/students');
    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        if (data['students'] is List) {
          list = data['students'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<StudentModel> createStudent(Map<String, dynamic> studentData) async {
    final response = await _dio.post('/api/students', data: studentData);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['student'] is Map<String, dynamic>) {
          return StudentModel.fromJson(data['student'] as Map<String, dynamic>);
        }
        return StudentModel.fromJson(data);
      }
    }
    return StudentModel.fromJson(studentData);
  }

  Future<StudentModel> updateStudent(
      String id, Map<String, dynamic> studentData) async {
    Response response;
    try {
      response = await _dio.put('/api/students/$id', data: studentData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        response = await _dio.patch('/api/students/$id', data: studentData);
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['student'] is Map<String, dynamic>) {
          return StudentModel.fromJson(data['student'] as Map<String, dynamic>);
        }
        return StudentModel.fromJson(data);
      }
    }
    return StudentModel.fromJson(studentData);
  }

  Future<bool> deleteStudent(String id) async {
    final response = await _dio.delete('/api/students/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
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
    return e.toString();
  }
}

