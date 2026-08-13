import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'enrolment_model.dart';

class EnrolmentService {
  final Dio _dio = ApiClient().dio;

  Future<List<EnrolmentModel>> fetchEnrolments() async {
    try {
      final response = await _dio.get('/enrolments');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => EnrolmentModel.fromJson(e)).toList();
      }
    } catch (_) {}

    return const [
      EnrolmentModel(enrolmentId: 'ENR-2026-01', studentName: 'Alice Smith', packageName: 'Full Driving Course', enrolmentDate: '2026-08-01', paymentStatus: 'Paid'),
      EnrolmentModel(enrolmentId: 'ENR-2026-02', studentName: 'Bob Jones', packageName: 'Refresher Course', enrolmentDate: '2026-08-05', paymentStatus: 'Partial'),
    ];
  }
}
