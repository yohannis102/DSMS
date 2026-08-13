import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'auth_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Perform login HTTP POST request via Dio.
  /// Falls back to stubbed mock login response if server is unreachable.
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        _apiClient.setMockMode(false);
        final authResponse = AuthResponseModel.fromJson(response.data);
        await _apiClient.setAuthToken(
          authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to authenticate.',
        );
      }
    } on DioException catch (e) {
      // If server responded (e.g. 400, 401, 403, 500), throw real server message
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        String? serverMsg;
        if (data is Map) {
          serverMsg = data['message']?.toString() ?? data['error']?.toString();
        } else if (data is String) {
          serverMsg = data;
        }
        throw Exception(serverMsg ?? 'Invalid credentials (${e.response?.statusCode}).');
      }

      // Fallback to mock only if server is unreachable / offline
      _apiClient.setMockMode(true);
      await Future.delayed(const Duration(milliseconds: 1200));

      final isEmail = request.identifier.contains('@');
      final mockUser = UserModel(
        id: 'usr_001',
        username: request.identifier,
        firstName: isEmail ? 'Demo' : request.identifier,
        lastName: isEmail ? 'User' : 'Admin',
        email: isEmail ? request.identifier : '${request.identifier}@dsms.com',
        phone: '+251911223344',
        role: 'admin',
      );

      final mockResponse = AuthResponseModel(
        accessToken: 'mock_jwt_token_dsms_2026',
        refreshToken: 'mock_refresh_token_dsms_2026',
        user: mockUser,
      );

      await _apiClient.setAuthToken(
        mockResponse.accessToken,
        refreshToken: mockResponse.refreshToken,
      );
      return mockResponse;
    }
  }

  /// Logout HTTP call.
  Future<bool> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore network failures on logout mock
    } finally {
      await _apiClient.clearAuthToken();
    }
    return true;
  }
}
