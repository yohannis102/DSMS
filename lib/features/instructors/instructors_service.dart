import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'instructors_model.dart';

class InstructorsService {
  final Dio _dio = ApiClient().dio;

  Future<List<InstructorsModel>> fetchInstructors() async {
    try {
      final response = await _dio.get('/instructors');
      if (response.statusCode == 200 && response.data != null) {
        ApiClient().setMockMode(false);
        final list = response.data as List<dynamic>;
        return list.map((e) => InstructorsModel.fromJson(e)).toList();
      }
    } catch (_) {
      ApiClient().setMockMode(true);
    }

    return const [
      InstructorsModel(id: 'INS-101', name: 'Michael Scott', vehicleType: 'Manual Sedan', totalStudents: 12),
      InstructorsModel(id: 'INS-102', name: 'Pam Beesly', vehicleType: 'Automatic SUV', totalStudents: 8),
    ];
  }
}
