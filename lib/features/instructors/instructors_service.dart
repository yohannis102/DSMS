import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'instructors_model.dart';

class InstructorsService {
  final Dio _dio = ApiClient().dio;

  Future<List<InstructorsModel>> fetchInstructors() async {
    Response response;
    try {
      response = await _dio.get('/api/instructors');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get('/instructors');
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        if (data['instructors'] is List) {
          list = data['instructors'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .map((e) => InstructorsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<InstructorsModel> createInstructor(
      Map<String, dynamic> instructorData) async {
    Response response;
    try {
      response = await _dio.post('/api/instructors', data: instructorData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.post('/instructors', data: instructorData);
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['instructor'] is Map<String, dynamic>) {
          return InstructorsModel.fromJson(
              data['instructor'] as Map<String, dynamic>);
        }
        return InstructorsModel.fromJson(data);
      }
    }
    return InstructorsModel.fromJson(instructorData);
  }

  Future<InstructorsModel> updateInstructor(
      String id, Map<String, dynamic> instructorData) async {
    Response response;
    try {
      response = await _dio.put('/api/instructors/$id', data: instructorData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          response =
              await _dio.patch('/api/instructors/$id', data: instructorData);
        } on DioException {
          response = await _dio.put('/instructors/$id', data: instructorData);
        }
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['instructor'] is Map<String, dynamic>) {
          return InstructorsModel.fromJson(
              data['instructor'] as Map<String, dynamic>);
        }
        return InstructorsModel.fromJson(data);
      }
    }
    return InstructorsModel.fromJson(instructorData);
  }

  Future<bool> deleteInstructor(String id) async {
    Response response;
    try {
      response = await _dio.delete('/api/instructors/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.delete('/instructors/$id');
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
          return data['message']?.toString() ??
              data['error']?.toString() ??
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
