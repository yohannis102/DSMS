import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  bool isServerAvailable = false;
  final ValueNotifier<bool> isMockMode = ValueNotifier<bool>(true);

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'dsms_secure_storage',
      publicKey: 'dsms_secure_storage',
    ),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // In-memory fallback cache to prevent app crashes if native plugin is missing/unrestarted
  final Map<String, String> _inMemoryCache = {};

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.100.34:5000',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors setup
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach auth headers or tokens here in the future
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

    // Load persisted token on init
    initToken();
  }

  /// Load stored auth token on startup and attach to Dio headers
  Future<void> initToken() async {
    final token = await getStoredToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Pings the root endpoint '/' to check if the backend API is live.
  /// Returns true if response contains {"status": "ok"}.
  Future<bool> checkBackendHealth() async {
    try {
      final response = await dio.get(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final status = response.data is Map ? response.data['status'] : null;
        isServerAvailable = (status == 'ok');
        isMockMode.value = !isServerAvailable;
        return isServerAvailable;
      }
    } catch (_) {
      isServerAvailable = false;
      isMockMode.value = true;
    }
    return false;
  }

  /// Manually toggle or update mock mode status
  void setMockMode(bool isMock) {
    if (isMockMode.value != isMock) {
      isMockMode.value = isMock;
    }
  }

  /// Save access token securely and set Authorization header
  Future<void> setAuthToken(String token, {String? refreshToken}) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
    _inMemoryCache[_tokenKey] = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // Safe fallback if native plugin channel fails
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {}

    if (refreshToken != null) {
      _inMemoryCache[_refreshTokenKey] = refreshToken;
      try {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      } catch (_) {
        // Safe fallback if native plugin channel fails
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_refreshTokenKey, refreshToken);
      } catch (_) {}
    }
  }

  /// Clear tokens securely and remove Authorization header
  Future<void> clearAuthToken() async {
    dio.options.headers.remove('Authorization');
    _inMemoryCache.remove(_tokenKey);
    _inMemoryCache.remove(_refreshTokenKey);
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {}
  }

  /// Read access token from FlutterSecureStorage, SharedPreferences, or fallback cache
  Future<String?> getStoredToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    if (_inMemoryCache[_tokenKey] != null && _inMemoryCache[_tokenKey]!.isNotEmpty) {
      return _inMemoryCache[_tokenKey];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    return null;
  }

  /// Read refresh token from FlutterSecureStorage, SharedPreferences, or fallback cache
  Future<String?> getStoredRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    if (_inMemoryCache[_refreshTokenKey] != null && _inMemoryCache[_refreshTokenKey]!.isNotEmpty) {
      return _inMemoryCache[_refreshTokenKey];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_refreshTokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    return null;
  }
}
