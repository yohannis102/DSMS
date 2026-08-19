import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  Future<List<PaymentModel>> fetchPayments({bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(
        '/payments',
        options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
      );
      if ((response.statusCode == 200 || response.statusCode == 304) &&
          response.data != null) {
        ApiClient().setMockMode(false);
        final dynamic data = ApiClient.parseResponseData(response.data);
        List<dynamic> list = [];
        if (data is Map) {
          if (data['payments'] is List) {
            list = data['payments'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          list = data;
        }
        return list
            .whereType<Map>()
            .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      ApiClient().setMockMode(true);
    }

    return const [
      PaymentModel(transactionId: 'TXN-9981', studentName: 'Alice Smith', amount: 12000.0, date: '2026-08-02', method: 'CBE Birr'),
      PaymentModel(transactionId: 'TXN-9982', studentName: 'Bob Jones', amount: 8000.0, date: '2026-08-06', method: 'Telebirr'),
    ];
  }
}
