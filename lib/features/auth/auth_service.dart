import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import 'auth_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const String _kRememberMeKey = 'remember_me';
  static const String _kUserDataKey = 'current_user_data';

  /// Save session details locally
  Future<void> _saveSession(
    AuthResponseModel authResponse, {
    required bool rememberMe,
  }) async {
    await _apiClient.setAuthToken(
      authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRememberMeKey, rememberMe);
      if (rememberMe) {
        await prefs.setString(
          _kUserDataKey,
          jsonEncode(authResponse.user.toJson()),
        );
      } else {
        await prefs.remove(_kUserDataKey);
      }
    } catch (_) {}
  }

  /// Check if user has an active session and opted into Remember Me
  Future<bool> isLoggedInAndRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isRemembered = prefs.getBool(_kRememberMeKey) ?? false;
      if (!isRemembered) return false;

      final token = await _apiClient.getStoredToken();
      if (token != null && token.isNotEmpty) {
        await _apiClient.setAuthToken(token);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve saved user if available
  Future<UserModel?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_kUserDataKey);
      if (data != null && data.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(data));
      }
    } catch (_) {}
    return null;
  }

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
        await _saveSession(authResponse, rememberMe: request.rememberMe);
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
        throw Exception(
          serverMsg ?? 'Invalid credentials (${e.response?.statusCode}).',
        );
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

      await _saveSession(mockResponse, rememberMe: request.rememberMe);
      return mockResponse;
    }
  }

  /// Logout HTTP call and clean up local session.
  Future<bool> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore network failures on logout mock
    } finally {
      await _apiClient.clearAuthToken();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kRememberMeKey, false);
        await prefs.remove(_kUserDataKey);
      } catch (_) {}
    }
    return true;
  }
}
