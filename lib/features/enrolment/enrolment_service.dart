import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'enrolment_model.dart';

class EnrolmentService {
  final Dio _dio = ApiClient().dio;

  // In-memory mock store for offline/demo resilience
  static final List<EnrolmentModel> _mockEnrolments = [
    const EnrolmentModel(
      id: '6a8305cd202b3c28eeaa69cc',
      schedule: EnrolmentScheduleInfo(
        id: '6a82f6accd0cd07e2458540b',
        scheduleCode: 'SCHD-5AW4QZ',
        date: '2026-09-01T09:00:00.000Z',
        slotsAvailable: 7,
        amount: 4000.0,
      ),
      student: EnrolmentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cb',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        username: 'jane',
        phone: '+251 911 234567',
      ),
      instructor: EnrolmentInstructorInfo(
        id: '6a82f418cd0cd07e2458540a',
        firstName: 'Juan',
        lastName: 'Cruz',
        email: 'juan.delacruz@example.com',
        username: 'juandelacruz',
      ),
      package: EnrolmentPackageInfo(
        id: 'pkg-001',
        name: 'Full Driver License Course',
        price: 4000.0,
        description: 'Complete comprehensive theory & practical driving package',
      ),
      remarks: 'Enrolled by admin',
      status: 'Active',
      paymentStatus: 'Paid',
      createdAt: '2026-08-17T12:59:57.422Z',
      updatedAt: '2026-08-17T12:59:57.422Z',
    ),
    const EnrolmentModel(
      id: '6a8305cd202b3c28eeaa69cd',
      schedule: EnrolmentScheduleInfo(
        id: '6a82f6accd0cd07e2458540c',
        scheduleCode: 'SCHD-7ZX9TY',
        date: '2026-08-25T10:30:00.000Z',
        slotsAvailable: 2,
        amount: 2500.0,
      ),
      student: EnrolmentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cc',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael.b@example.com',
        username: 'mbrown',
        phone: '+251 922 887766',
      ),
      instructor: EnrolmentInstructorInfo(
        id: '6a82f418cd0cd07e2458540b',
        firstName: 'Pamela',
        lastName: 'Beesly',
        email: 'pamela.b@example.com',
        username: 'pambeesly',
      ),
      package: EnrolmentPackageInfo(
        id: 'pkg-002',
        name: 'Refresher & Parallel Parking',
        price: 2500.0,
        description: 'Targeted skill booster sessions for intermediate drivers',
      ),
      remarks: 'Student requested morning slot',
      status: 'Active',
      paymentStatus: 'Paid',
      createdAt: '2026-08-15T08:30:12.110Z',
      updatedAt: '2026-08-15T08:30:12.110Z',
    ),
    const EnrolmentModel(
      id: '6a8305cd202b3c28eeaa69ce',
      schedule: EnrolmentScheduleInfo(
        id: '6a82f6accd0cd07e2458540d',
        scheduleCode: 'SCHD-9KL3MN',
        date: '2026-08-10T14:00:00.000Z',
        slotsAvailable: 0,
        amount: 3200.0,
      ),
      student: EnrolmentStudentInfo(
        id: '6a8305a9202b3c28eeaa69cd',
        firstName: 'Samuel',
        lastName: 'Jackson',
        email: 'samuel.j@example.com',
        username: 'samuelj',
        phone: '+251 933 554433',
      ),
      instructor: EnrolmentInstructorInfo(
        id: '6a82f418cd0cd07e2458540c',
        firstName: 'Dwight',
        lastName: 'Schrute',
        email: 'dwight.s@example.com',
        username: 'dwights',
      ),
      package: EnrolmentPackageInfo(
        id: 'pkg-003',
        name: 'Express Highway & Night Driving',
        price: 3200.0,
        description: 'Advanced road awareness & emergency handling',
      ),
      remarks: 'Completed all required driving hours and passed assessment',
      status: 'Completed',
      paymentStatus: 'Paid',
      createdAt: '2026-08-01T09:15:00.000Z',
      updatedAt: '2026-08-12T16:45:00.000Z',
    ),
  ];

  Future<List<EnrolmentModel>> fetchEnrolments() async {
    Response? response;
    try {
      try {
        response = await _dio.get('/api/enrollments');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          try {
            response = await _dio.get('/api/enrolments');
          } on DioException {
            response = await _dio.get('/enrollments');
          }
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        ApiClient().setMockMode(false);
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          if (data['enrollments'] is List) {
            list = data['enrollments'] as List<dynamic>;
          } else if (data['enrolments'] is List) {
            list = data['enrolments'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          list = data;
        }
        return list
            .map((e) => EnrolmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      ApiClient().setMockMode(true);
    }

    return List<EnrolmentModel>.from(_mockEnrolments);
  }

  Future<EnrolmentModel?> getEnrollmentById(String id) async {
    try {
      final response = await _dio.get('/api/enrollments/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['enrollment'] is Map<String, dynamic>) {
            return EnrolmentModel.fromJson(data['enrollment'] as Map<String, dynamic>);
          }
          return EnrolmentModel.fromJson(data);
        }
      }
    } catch (_) {}

    return _mockEnrolments.firstWhere(
      (e) => e.id == id,
      orElse: () => _mockEnrolments.first,
    );
  }

  Future<EnrolmentModel> createEnrollment({
    required String scheduleId,
    required String packageId,
    required String studentId,
    String remarks = 'Enrolled by admin',
    Map<String, dynamic>? extraContext,
  }) async {
    final payload = {
      'scheduleId': scheduleId.trim(),
      'packageId': packageId.trim(),
      'student': studentId.trim(),
      'remarks': remarks.trim().isEmpty ? 'Enrolled by admin' : remarks.trim(),
    };

    try {
      Response response;
      try {
        response = await _dio.post('/api/enrollments', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          try {
            response = await _dio.post('/api/enrolments', data: payload);
          } on DioException {
            response = await _dio.post('/enrollments', data: payload);
          }
        } else {
          rethrow;
        }
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['enrollment'] is Map<String, dynamic>) {
            final created = EnrolmentModel.fromJson(
              data['enrollment'] as Map<String, dynamic>,
            );
            _mockEnrolments.insert(0, created);
            return created;
          }
          final created = EnrolmentModel.fromJson(data);
          _mockEnrolments.insert(0, created);
          return created;
        }
      }
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
    } catch (e) {
      if (e is! DioException) rethrow;
    }

    // Offline mock fallback
    final now = DateTime.now().toUtc().toIso8601String();
    final newId = '6a83${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    
    // Extract context for mock display
    EnrolmentScheduleInfo? scheduleInfo;
    if (extraContext?['schedule'] != null) {
      scheduleInfo = EnrolmentScheduleInfo.fromJson(extraContext!['schedule']);
    } else {
      scheduleInfo = EnrolmentScheduleInfo(
        id: scheduleId,
        scheduleCode: 'SCHD-${scheduleId.substring(scheduleId.length > 6 ? scheduleId.length - 6 : 0).toUpperCase()}',
        date: now,
        slotsAvailable: 5,
        amount: 4000.0,
      );
    }

    EnrolmentStudentInfo? studentInfo;
    if (extraContext?['student'] != null) {
      studentInfo = EnrolmentStudentInfo.fromJson(extraContext!['student']);
    } else {
      studentInfo = EnrolmentStudentInfo(
        id: studentId,
        firstName: 'Student',
        lastName: '($studentId)',
        email: 'student@example.com',
      );
    }

    EnrolmentPackageInfo? packageInfo;
    if (extraContext?['package'] != null) {
      packageInfo = EnrolmentPackageInfo.fromJson(extraContext!['package']);
    } else {
      packageInfo = EnrolmentPackageInfo(
        id: packageId,
        name: 'Selected Driving Package',
        price: scheduleInfo.amount > 0 ? scheduleInfo.amount : 4000.0,
      );
    }

    final newEnrolment = EnrolmentModel(
      id: newId,
      schedule: scheduleInfo,
      student: studentInfo,
      instructor: const EnrolmentInstructorInfo(
        id: 'ins-assigned',
        firstName: 'Juan',
        lastName: 'Cruz',
        email: 'juan.delacruz@example.com',
      ),
      package: packageInfo,
      remarks: payload['remarks']?.toString() ?? 'Enrolled by admin',
      status: 'Active',
      paymentStatus: 'Paid',
      createdAt: now,
      updatedAt: now,
    );

    _mockEnrolments.insert(0, newEnrolment);
    return newEnrolment;
  }

  Future<EnrolmentModel> updateEnrollment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      Response response;
      try {
        response = await _dio.put('/api/enrollments/$id', data: data);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          try {
            response = await _dio.patch('/api/enrollments/$id', data: data);
          } on DioException {
            response = await _dio.put('/enrollments/$id', data: data);
          }
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final dynamic resData = response.data;
        if (resData is Map<String, dynamic>) {
          if (resData['enrollment'] is Map<String, dynamic>) {
            final updated = EnrolmentModel.fromJson(
              resData['enrollment'] as Map<String, dynamic>,
            );
            _updateLocalMock(id, updated);
            return updated;
          }
          final updated = EnrolmentModel.fromJson(resData);
          _updateLocalMock(id, updated);
          return updated;
        }
      }
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
    } catch (e) {
      if (e is! DioException) rethrow;
    }

    final index = _mockEnrolments.indexWhere((e) => e.id == id);
    if (index != -1) {
      final existing = _mockEnrolments[index];
      final updated = existing.copyWith(
        remarks: data['remarks']?.toString() ?? existing.remarks,
        status: data['status']?.toString() ?? existing.status,
        paymentStatus: data['paymentStatus']?.toString() ?? existing.paymentStatus,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      _mockEnrolments[index] = updated;
      return updated;
    }

    return EnrolmentModel.fromJson({'_id': id, ...data});
  }

  Future<bool> deleteEnrollment(String id) async {
    try {
      Response response;
      try {
        response = await _dio.delete('/api/enrollments/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.delete('/enrollments/$id');
        } else {
          rethrow;
        }
      }
      final success = response.statusCode == 200 || response.statusCode == 204;
      if (success) {
        _mockEnrolments.removeWhere((e) => e.id == id);
      }
      return success;
    } on DioException catch (e) {
      if (!ApiClient().isMockMode.value &&
          e.response != null &&
          e.response!.data != null &&
          (e.response!.data is Map ||
              (e.response!.data is String &&
                  (e.response!.data as String).isNotEmpty))) {
        rethrow;
      }
      _mockEnrolments.removeWhere((e) => e.id == id);
      return true;
    } catch (_) {
      _mockEnrolments.removeWhere((e) => e.id == id);
      return true;
    }
  }

  void _updateLocalMock(String id, EnrolmentModel updated) {
    final index = _mockEnrolments.indexWhere((e) => e.id == id);
    if (index != -1) {
      _mockEnrolments[index] = updated;
    } else {
      _mockEnrolments.insert(0, updated);
    }
  }

  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          // 1. Check validation errors array from express-validator
          if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            final messages = (data['errors'] as List)
                .map((item) {
                  if (item is Map) {
                    return item['msg']?.toString() ??
                        item['message']?.toString() ??
                        item['error']?.toString();
                  }
                  return item?.toString();
                })
                .where((msg) => msg != null && msg.trim().isNotEmpty)
                .join(', ');
            if (messages.isNotEmpty) return messages;
          }
          // 2. Check top-level message (e.g. duplicate / student required)
          if (data['message'] != null && data['message'].toString().isNotEmpty) {
            return data['message'].toString();
          }
          if (data['error'] != null && data['error'].toString().isNotEmpty) {
            return data['error'].toString();
          }
          if (data['msg'] != null && data['msg'].toString().isNotEmpty) {
            return data['msg'].toString();
          }
          return 'Server error (${e.response?.statusCode})';
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      return e.message ?? 'Network connection error';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
