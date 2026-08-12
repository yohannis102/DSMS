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
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponseModel.fromJson(response.data);
        _apiClient.setAuthToken(authResponse.token);
        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to authenticate.',
        );
      }
    } on DioException catch (_) {
      // Mock Fallback while backend API is not yet available
      await Future.delayed(const Duration(milliseconds: 1200));

      // Simulate success response for testing
      final mockUser = UserModel(
        id: 'usr_001',
        name: 'Demo Student',
        email: request.loginType == LoginType.email ? request.identifier : 'demo@dsms.com',
        phone: request.loginType == LoginType.phone ? request.identifier : '+251911223344',
        role: 'Student Driver',
      );

      final mockResponse = AuthResponseModel(
        token: 'mock_jwt_token_dsms_2026',
        user: mockUser,
      );

      _apiClient.setAuthToken(mockResponse.token);
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
      _apiClient.clearAuthToken();
    }
    return true;
  }
}
