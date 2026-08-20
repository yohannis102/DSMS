import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  /// Fetches payments list from API with caching
  Future<List<PaymentModel>> fetchPayments({bool forceRefresh = false}) async {
    Response response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
    try {
      response = await _dio.get('/api/payments', options: options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get('/payments', options: options);
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['payments'] is List) {
          list = data['payments'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        } else if (data['payment'] is Map) {
          list = [data['payment']];
        }
      } else if (data is List) {
        list = data;
      }

      return list
          .whereType<Map>()
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Fetches a single payment by ID
  Future<PaymentModel> getPaymentById(String paymentId) async {
    Response response;
    try {
      response = await _dio.get('/api/payments/$paymentId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get('/payments/$paymentId');
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      if (data is Map && data['payment'] != null) {
        return PaymentModel.fromJson(data['payment']);
      }
      return PaymentModel.fromJson(data);
    }
    throw Exception('Payment not found');
  }

  /// Creates a new payment record (supports multipart for image upload or json)
  Future<PaymentModel> createPayment({
    required String enrollmentId,
    required double amount,
    String? remarks,
    String? status,
    XFile? proofImage,
  }) async {
    try {
      Response response;

      if (proofImage != null) {
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await proofImage.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: proofImage.name.isNotEmpty ? proofImage.name : 'proof.jpg',
          );
        } else {
          multipartFile = await MultipartFile.fromFile(
            proofImage.path,
            filename: proofImage.name.isNotEmpty ? proofImage.name : 'proof.jpg',
          );
        }

        final formData = FormData.fromMap({
          'enrollmentId': enrollmentId,
          'amount': amount,
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
          if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
          'proofOfPayment': multipartFile,
        });

        try {
          response = await _dio.post(
            '/api/payments',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            response = await _dio.post(
              '/payments',
              data: formData,
              options: Options(contentType: 'multipart/form-data'),
            );
          } else {
            rethrow;
          }
        }
      } else {
        final payload = {
          'enrollmentId': enrollmentId,
          'amount': amount,
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
          if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        };

        try {
          response = await _dio.post('/api/payments', data: payload);
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            response = await _dio.post('/payments', data: payload);
          } else {
            rethrow;
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = ApiClient.parseResponseData(response.data);
        if (data is Map && data['payment'] != null) {
          return PaymentModel.fromJson(data['payment']);
        }
        return PaymentModel.fromJson(data);
      }
      throw Exception('Failed to create payment record.');
    } on DioException catch (e) {
      final errorMsg = extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService createPayment error: $e');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Updates status and remarks for a payment
  Future<PaymentModel> updatePayment({
    required String id,
    required String status,
    String? remarks,
  }) async {
    final payload = {
      'status': status,
      if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
    };

    try {
      Response response;
      try {
        response = await _dio.put('/api/payments/$id', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          try {
            response = await _dio.patch('/api/payments/$id', data: payload);
          } on DioException {
            response = await _dio.put('/payments/$id', data: payload);
          }
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = ApiClient.parseResponseData(response.data);
        if (data is Map && data['payment'] != null) {
          return PaymentModel.fromJson(data['payment']);
        }
        return PaymentModel.fromJson(data);
      }
      throw Exception('Failed to update payment record.');
    } on DioException catch (e) {
      final errorMsg = extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService updatePayment error: $e');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Deletes a payment record
  Future<bool> deletePayment(String paymentId) async {
    try {
      Response response;
      try {
        response = await _dio.delete('/api/payments/$paymentId');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.delete('/payments/$paymentId');
        } else {
          rethrow;
        }
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final errorMsg = extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService deletePayment error: $e');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Extracts structured validation messages or error text from API responses
  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final dynamic data = ApiClient.parseResponseData(e.response!.data);
        if (data is Map) {
          // Check for validation errors array: { errors: [ { msg: "..." } ] }
          if (data['errors'] is List) {
            final errList = data['errors'] as List;
            final messages = errList
                .whereType<Map>()
                .map((err) => err['msg']?.toString() ?? err['message']?.toString() ?? '')
                .where((msg) => msg.isNotEmpty)
                .toList();
            if (messages.isNotEmpty) {
              return messages.join('\n');
            }
          }
          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['error'] != null) {
            return data['error'].toString();
          }
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      return e.message ?? 'An unexpected network error occurred';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
