import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'package_model.dart';

class PackageService {
  final Dio _dio = ApiClient().dio;

  Future<List<PackageModel>> fetchPackages() async {
    try {
      final response = await _dio.get('/packages');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => PackageModel.fromJson(e)).toList();
      }
    } catch (_) {}

    return const [
      PackageModel(id: 'PKG-01', packageName: 'Beginner Driving Training', price: 12000.0, duration: '30 Days', description: 'Complete course from theory to practical road test'),
      PackageModel(id: 'PKG-02', packageName: 'Refresher Courses', price: 6000.0, duration: '14 Days', description: 'Skill enhancement for licensed drivers'),
    ];
  }
}
