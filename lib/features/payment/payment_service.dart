import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  Future<List<PaymentModel>> fetchPayments() async {
    try {
      final response = await _dio.get('/payments');
      if (response.statusCode == 200 && response.data != null) {
        ApiClient().setMockMode(false);
        final list = response.data as List<dynamic>;
        return list.map((e) => PaymentModel.fromJson(e)).toList();
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
