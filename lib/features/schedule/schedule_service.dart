import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'schedule_model.dart';

class ScheduleService {
  final Dio _dio = ApiClient().dio;

  Future<List<ScheduleModel>> fetchSchedules() async {
    try {
      final response = await _dio.get('/schedules');
      if (response.statusCode == 200 && response.data != null) {
        ApiClient().setMockMode(false);
        final list = response.data as List<dynamic>;
        return list.map((e) => ScheduleModel.fromJson(e)).toList();
      }
    } catch (_) {
      ApiClient().setMockMode(true);
    }

    return const [
      ScheduleModel(id: 'SCH-01', title: 'Beginner Road Practice', date: '2026-08-15', time: '09:00 AM - 11:00 AM', instructor: 'Michael Scott'),
      ScheduleModel(id: 'SCH-02', title: 'Refresher Parallel Parking', date: '2026-08-16', time: '02:00 PM - 04:00 PM', instructor: 'Pam Beesly'),
    ];
  }
}
