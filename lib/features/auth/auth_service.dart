import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import 'auth_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const String _kRememberMeKey = 'remember_me';
  static const String _kUserDataKey = 'current_user_data';

  /// Reactive notifier for the currently active/logged-in user
  static final ValueNotifier<UserModel?> currentUserNotifier =
      ValueNotifier<UserModel?>(null);

  /// Save session details locally
  Future<void> _saveSession(
    AuthResponseModel authResponse, {
    required bool rememberMe,
  }) async {
    currentUserNotifier.value = authResponse.user;

    await _apiClient.setAuthToken(
      authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRememberMeKey, rememberMe);
      // Persist user data in storage for session UI display
      await prefs.setString(
        _kUserDataKey,
        jsonEncode(authResponse.user.toJson()),
      );
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
        await getSavedUser();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve saved user if available
  Future<UserModel?> getSavedUser() async {
    if (currentUserNotifier.value != null) {
      return currentUserNotifier.value;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_kUserDataKey);
      if (data != null && data.isNotEmpty) {
        final user = UserModel.fromJson(jsonDecode(data));
        currentUserNotifier.value = user;
        return user;
      }
    } catch (_) {}
    return null;
  }

  /// Perform login HTTP POST request via Dio.
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
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
      throw Exception(
        e.message ?? 'Cannot connect to server. Please check your network connection.',
      );
    }
  }

  /// Logout HTTP call and clean up local session.
  Future<bool> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore network failures on logout
    } finally {
      currentUserNotifier.value = null;
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
