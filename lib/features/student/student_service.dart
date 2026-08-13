import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'student_model.dart';

class StudentService {
  final Dio _dio = ApiClient().dio;

  Future<List<StudentModel>> fetchStudents() async {
    try {
      final response = await _dio.get('/students');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => StudentModel.fromJson(e)).toList();
      }
    } catch (_) {}

    return const [
      StudentModel(id: 'ST-001', name: 'Alice Smith', email: 'alice@example.com', phone: '+123456789', status: 'Active'),
      StudentModel(id: 'ST-002', name: 'Bob Jones', email: 'bob@example.com', phone: '+987654321', status: 'Pending'),
      StudentModel(id: 'ST-003', name: 'Charlie Brown', email: 'charlie@example.com', phone: '+555666777', status: 'Active'),
    ];
  }
}
