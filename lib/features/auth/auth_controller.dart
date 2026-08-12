import 'package:flutter/material.dart';
import 'auth_model.dart';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginType _loginType = LoginType.email;
  LoginType get loginType => _loginType;

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

  void setLoginType(LoginType type) {
    if (_loginType != type) {
      _loginType = type;
      identifierController.clear();
      _errorMessage = null;
      notifyListeners();
    }
  }

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
      return _loginType == LoginType.email
          ? 'Please enter your email address'
          : 'Please enter your phone number';
    }

    final trimmed = value.trim();
    if (_loginType == LoginType.email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Please enter a valid email address';
      }
    } else {
      final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
      if (!phoneRegex.hasMatch(trimmed.replaceAll(' ', ''))) {
        return 'Please enter a valid phone number (e.g. +251911223344)';
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
        loginType: _loginType,
        rememberMe: _rememberMe,
      );

      final response = await _service.login(request);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Invalid credentials or server unavailable. Please try again.';
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
