import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'admin_dashboard_model.dart';

class AdminDashboardService {
  final Dio _dio = ApiClient().dio;

  /// 1. GET /api/dashboard
  Future<DashboardStats> getStats({bool forceRefresh = false}) async {
    final response = await _dio.get(
      '/api/dashboard',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      if (data is Map) {
        if (data['stats'] is Map) {
          return DashboardStats.fromJson(
              Map<String, dynamic>.from(data['stats'] as Map));
        }
        if (data['data'] is Map) {
          return DashboardStats.fromJson(
              Map<String, dynamic>.from(data['data'] as Map));
        }
        return DashboardStats.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return const DashboardStats();
  }

  /// 2. GET /api/dashboard/payment-status-breakdown
  Future<List<PaymentStatusBreakdown>> getPaymentStatusBreakdown({
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/payment-status-breakdown',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['breakdown'] is List) {
          list = data['breakdown'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) =>
              PaymentStatusBreakdown.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 3. GET /api/dashboard/monthly-income
  Future<List<MonthlyIncome>> getMonthlyIncome({
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/monthly-income',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['monthlyIncome'] is List) {
          list = data['monthlyIncome'] as List<dynamic>;
        } else if (data['income'] is List) {
          list = data['income'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => MonthlyIncome.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 4. GET /api/dashboard/monthly-enrollments
  Future<List<MonthlyEnrollment>> getMonthlyEnrollments({
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/monthly-enrollments',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['monthlyEnrollments'] is List) {
          list = data['monthlyEnrollments'] as List<dynamic>;
        } else if (data['enrollments'] is List) {
          list = data['enrollments'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => MonthlyEnrollment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 5. GET /api/dashboard/package-popularity
  Future<List<PackagePopularity>> getPackagePopularity({
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/package-popularity',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['popularity'] is List) {
          list = data['popularity'] as List<dynamic>;
        } else if (data['packages'] is List) {
          list = data['packages'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => PackagePopularity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 6. GET /api/dashboard/instructor-workload
  Future<List<InstructorWorkload>> getInstructorWorkload({
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/instructor-workload',
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['workload'] is List) {
          list = data['workload'] as List<dynamic>;
        } else if (data['instructors'] is List) {
          list = data['instructors'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => InstructorWorkload.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 7. GET /api/dashboard/recent-payments?limit=5
  Future<List<RecentPayment>> getRecentPayments({
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    final response = await _dio.get(
      '/api/dashboard/recent-payments',
      queryParameters: {'limit': limit},
      options: ApiClient().cacheOptions(forceRefresh: forceRefresh),
    );
    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['recentPayments'] is List) {
          list = data['recentPayments'] as List<dynamic>;
        } else if (data['payments'] is List) {
          list = data['payments'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => RecentPayment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Concurrently fetch all 7 dashboard endpoints
  Future<AdminDashboardData> getDashboardData({
    bool forceRefresh = false,
  }) async {
    final results = await Future.wait([
      getStats(forceRefresh: forceRefresh),
      getPaymentStatusBreakdown(forceRefresh: forceRefresh),
      getMonthlyIncome(forceRefresh: forceRefresh),
      getMonthlyEnrollments(forceRefresh: forceRefresh),
      getPackagePopularity(forceRefresh: forceRefresh),
      getInstructorWorkload(forceRefresh: forceRefresh),
      getRecentPayments(limit: 5, forceRefresh: forceRefresh),
    ]);

    return AdminDashboardData(
      stats: results[0] as DashboardStats,
      paymentBreakdown: results[1] as List<PaymentStatusBreakdown>,
      monthlyIncome: results[2] as List<MonthlyIncome>,
      monthlyEnrollments: results[3] as List<MonthlyEnrollment>,
      packagePopularity: results[4] as List<PackagePopularity>,
      instructorWorkload: results[5] as List<InstructorWorkload>,
      recentPayments: results[6] as List<RecentPayment>,
    );
  }
}
