import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'package_model.dart';

class PackageService {
  final Dio _dio = ApiClient().dio;

  Future<List<PackageModel>> fetchPackages({bool forceRefresh = false}) async {
    Response response;
    final options = ApiClient().cacheOptions(forceRefresh: forceRefresh);
    try {
      response = await _dio.get('/api/packages', options: options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get('/packages', options: options);
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null) {
      final dynamic data = ApiClient.parseResponseData(response.data);
      List<dynamic> list = [];
      if (data is Map) {
        if (data['packages'] is List) {
          list = data['packages'] as List<dynamic>;
        } else if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map>()
          .map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<PackageModel> createPackage(Map<String, dynamic> packageData) async {
    Response response;
    try {
      response = await _dio.post('/api/packages', data: packageData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.post('/packages', data: packageData);
      } else {
        rethrow;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['package'] is Map<String, dynamic>) {
          return PackageModel.fromJson(data['package'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          return PackageModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        return PackageModel.fromJson(data);
      }
    }
    return PackageModel.fromJson(packageData);
  }

  Future<PackageModel> updatePackage(
      String id, Map<String, dynamic> packageData) async {
    Response response;
    try {
      response = await _dio.put('/api/packages/$id', data: packageData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          response = await _dio.patch('/api/packages/$id', data: packageData);
        } on DioException {
          response = await _dio.put('/packages/$id', data: packageData);
        }
      } else {
        rethrow;
      }
    }

    if (response.statusCode == 200 && response.data != null) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['package'] is Map<String, dynamic>) {
          return PackageModel.fromJson(data['package'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          return PackageModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        return PackageModel.fromJson(data);
      }
    }
    return PackageModel.fromJson(packageData);
  }

  Future<bool> deletePackage(String id) async {
    Response response;
    try {
      response = await _dio.delete('/api/packages/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.delete('/packages/$id');
      } else {
        rethrow;
      }
    }
    return response.statusCode == 200 || response.statusCode == 204;
  }

  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
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
          return data['message']?.toString() ??
              data['error']?.toString() ??
              data['msg']?.toString() ??
              'Server error (${e.response?.statusCode})';
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      return e.message ?? 'Network connection error';
    }
    return e.toString();
  }
}
