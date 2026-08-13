import 'package:flutter/material.dart';
import 'auth_model.dart';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  // Validation Logic
  String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username or email address';
    }

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Username or email address must be at least 3 characters';
    }

    if (trimmed.contains('@')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> submitLogin({
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AuthRequestModel(
        identifier: identifierController.text.trim(),
        password: passwordController.text,
        // rememberMe: _rememberMe,
      );

      final response = await _service.login(request);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceAll('Exception: ', '').trim();
      _errorMessage = msg.isNotEmpty
          ? msg
          : 'Invalid credentials or server unavailable. Please try again.';
      notifyListeners();

      onError(_errorMessage!);
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
