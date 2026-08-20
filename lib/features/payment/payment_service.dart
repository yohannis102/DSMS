import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  // In-memory mock store for offline/demo resilience
  static final List<PaymentModel> _mockPayments = [
    const PaymentModel(
      id: '6a85509696d9bde990a96de1',
      referenceNo: 'REF-3AZMXV',
      enrollment: PaymentEnrollmentInfo(
        id: '6a8305cd202b3c28eeaa69cc',
        schedule: PaymentScheduleInfo(
          id: '6a82f6accd0cd07e2458540b',
          scheduleCode: 'SCHD-5AW4QZ',
          date: '2026-09-01T09:00:00.000Z',
        ),
        studentId: '6a8305a9202b3c28eeaa69cb',
        instructorId: '6a82f418cd0cd07e2458540a',
      ),
      student: PaymentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cb',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        username: 'jane',
      ),
      amount: 3500.0,
      dateOfPayment: '2026-08-19T06:43:34.207Z',
      status: 'paid',
      remarks: 'Verified and marked paid',
      createdAt: '2026-08-19T06:43:34.209Z',
      updatedAt: '2026-08-20T07:42:41.279Z',
    ),
    const PaymentModel(
      id: '6a86b1610297a063ec8ec53f',
      referenceNo: 'REF-7XPWEW',
      enrollment: PaymentEnrollmentInfo(
        id: '6a8305cd202b3c28eeaa69cc',
        schedule: PaymentScheduleInfo(
          id: '6a82f6accd0cd07e2458540b',
          scheduleCode: 'SCHD-5AW4QZ',
          date: '2026-09-01T09:00:00.000Z',
        ),
        studentId: '6a8305a9202b3c28eeaa69cb',
        instructorId: '6a82f418cd0cd07e2458540a',
      ),
      student: PaymentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cb',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        username: 'jane',
      ),
      amount: 3500.0,
      dateOfPayment: '2026-08-20T07:48:49.148Z',
      status: 'unpaid',
      remarks: 'Pending bank transfer verification',
      createdAt: '2026-08-20T07:48:49.148Z',
      updatedAt: '2026-08-20T07:48:49.148Z',
    ),
    const PaymentModel(
      id: '6a86b5810297a063ec8ec540',
      referenceNo: 'REF-E4RPSS',
      enrollment: PaymentEnrollmentInfo(
        id: '6a8305cd202b3c28eeaa69cd',
        schedule: PaymentScheduleInfo(
          id: '6a82f6accd0cd07e2458540c',
          scheduleCode: 'SCHD-7ZX9TY',
          date: '2026-08-25T10:30:00.000Z',
        ),
        studentId: '6a8305a9202b3c28eeaa69cc',
        instructorId: '6a82f418cd0cd07e2458540b',
      ),
      student: PaymentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cc',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael.b@example.com',
        username: 'mbrown',
      ),
      amount: 2500.0,
      dateOfPayment: '2026-08-20T08:06:25.102Z',
      status: 'unpaid',
      remarks: 'First installment',
      createdAt: '2026-08-20T08:06:25.102Z',
      updatedAt: '2026-08-20T08:06:25.102Z',
    ),
    const PaymentModel(
      id: '6a86b5fe0297a063ec8ec541',
      referenceNo: 'REF-FY2WVZ',
      enrollment: PaymentEnrollmentInfo(
        id: '6a8305cd202b3c28eeaa69cc',
        schedule: PaymentScheduleInfo(
          id: '6a82f6accd0cd07e2458540b',
          scheduleCode: 'SCHD-5AW4QZ',
          date: '2026-09-01T09:00:00.000Z',
        ),
        studentId: '6a8305a9202b3c28eeaa69cb',
        instructorId: '6a82f418cd0cd07e2458540a',
      ),
      student: PaymentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cb',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        username: 'jane',
      ),
      amount: 3500.0,
      dateOfPayment: '2026-08-20T08:08:30.352Z',
      status: 'paid',
      remarks: 'Cash payment received at front desk',
      createdAt: '2026-08-20T08:08:30.352Z',
      updatedAt: '2026-08-20T08:08:30.352Z',
    ),
    const PaymentModel(
      id: '6a86b65f0297a063ec8ec542',
      referenceNo: 'REF-JUF7KT',
      enrollment: PaymentEnrollmentInfo(
        id: '6a8305cd202b3c28eeaa69ce',
        schedule: PaymentScheduleInfo(
          id: '6a82f6accd0cd07e2458540d',
          scheduleCode: 'SCHD-9KL3MN',
          date: '2026-08-10T14:00:00.000Z',
        ),
        studentId: '6a8305a9202b3c28eeaa69cd',
        instructorId: '6a82f418cd0cd07e2458540c',
      ),
      student: PaymentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cd',
        firstName: 'Samuel',
        lastName: 'Jackson',
        email: 'samuel.j@example.com',
        username: 'samuelj',
      ),
      amount: 3200.0,
      dateOfPayment: '2026-08-20T08:10:07.378Z',
      status: 'unpaid',
      remarks: 'Awaiting student confirmation',
      createdAt: '2026-08-20T08:10:07.378Z',
      updatedAt: '2026-08-20T08:10:07.378Z',
    ),
  ];

  /// Fetches payments list from API with caching and fallback support
  Future<List<PaymentModel>> fetchPayments({bool forceRefresh = false}) async {
    Response? response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
    try {
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
        ApiClient().setMockMode(false);
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

        final items = list
            .whereType<Map>()
            .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (items.isNotEmpty) {
          return items;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService fetchPayments error: $e, using mock fallback.');
      }
      ApiClient().setMockMode(true);
    }

    return List<PaymentModel>.from(_mockPayments);
  }

  /// Fetches a single payment by ID
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService getPaymentById error: $e');
      }
    }

    final match = _mockPayments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => _mockPayments.first,
    );
    return match;
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
        PaymentModel createdPayment;
        if (data is Map && data['payment'] != null) {
          createdPayment = PaymentModel.fromJson(data['payment']);
        } else {
          createdPayment = PaymentModel.fromJson(data);
        }
        _mockPayments.insert(0, createdPayment);
        return createdPayment;
      }
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService createPayment error: $e');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }

    // Mock fallback when offline
    final newId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final refNo = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final mockCreated = PaymentModel(
      id: newId,
      referenceNo: refNo,
      enrollment: PaymentEnrollmentInfo(id: enrollmentId),
      student: const PaymentStudentInfo(id: '', firstName: 'Student', lastName: 'User'),
      amount: amount,
      dateOfPayment: DateTime.now().toIso8601String(),
      status: status ?? 'unpaid',
      remarks: remarks ?? '',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _mockPayments.insert(0, mockCreated);
    return mockCreated;
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
        if (e.response?.statusCode == 404) {
          response = await _dio.put('/payments/$id', data: payload);
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = ApiClient.parseResponseData(response.data);
        PaymentModel updated;
        if (data is Map && data['payment'] != null) {
          updated = PaymentModel.fromJson(data['payment']);
        } else {
          updated = PaymentModel.fromJson(data);
        }

        final index = _mockPayments.indexWhere((p) => p.id == id);
        if (index != -1) {
          _mockPayments[index] = updated;
        }
        return updated;
      }
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService updatePayment error: $e');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }

    // Mock fallback
    final index = _mockPayments.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _mockPayments[index].copyWith(
        status: status,
        remarks: remarks ?? _mockPayments[index].remarks,
        updatedAt: DateTime.now().toIso8601String(),
      );
      _mockPayments[index] = updated;
      return updated;
    }

    return PaymentModel(
      id: id,
      status: status,
      remarks: remarks ?? '',
      updatedAt: DateTime.now().toIso8601String(),
    );
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        _mockPayments.removeWhere((p) => p.id == paymentId);
        return true;
      }
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        print('PaymentService deletePayment error: $e');
      }
      _mockPayments.removeWhere((p) => p.id == paymentId);
      return true;
    }

    _mockPayments.removeWhere((p) => p.id == paymentId);
    return true;
  }

  /// Extracts structured validation messages or error text from API responses
  String _extractErrorMessage(DioException e) {
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
      }
    }
    return e.message ?? 'An unexpected network error occurred';
  }
}
