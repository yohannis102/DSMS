import 'dart:async';
import 'package:flutter/material.dart';
import 'forgot_password_model.dart';
import 'forgot_password_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  final ForgotPasswordService _service = ForgotPasswordService();

  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.requestEmail;
  ForgotPasswordStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String? _resetToken;
  String? get resetToken => _resetToken;

  int _resendCountdown = 60;
  int get resendCountdown => _resendCountdown;
  Timer? _timer;
  bool get canResend => _resendCountdown == 0;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // --- Validation Logic ---
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit verification code';
    }
    final trimmed = value.trim();
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(trimmed)) {
      return 'Verification code must be exactly 6 digits';
    }
    return null;
  }

  void onPasswordChanged(String value) {
    notifyListeners();
  }

  // --- Password Strength Criteria ---
  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(newPasswordController.text);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(newPasswordController.text);
  bool get hasDigit => RegExp(r'[0-9]').hasMatch(newPasswordController.text);
  bool get hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPasswordController.text);

  int get passwordStrengthScore {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasDigit) score++;
    if (hasSpecialChar) score++;
    return score;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }
    if (!hasLowercase) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }
    if (!hasDigit) {
      return 'Password must contain at least one number (0-9)';
    }
    if (!hasSpecialChar) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // --- Actions ---

  /// Step 1: Submit email to request password reset OTP
  Future<void> submitEmailRequest({
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    if (!emailFormKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final request = ForgotPasswordRequestModel(
        email: emailController.text.trim(),
      );

      await _service.requestPasswordReset(request);
      _isLoading = false;
      _currentStep = ForgotPasswordStep.verifyOtp;
      _startResendTimer();
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Step 2: Submit 6-digit OTP code for verification
  Future<void> submitOtpVerification({
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    if (!otpFormKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final request = VerifyOtpRequestModel(
        email: emailController.text.trim(),
        otpCode: otpController.text.trim(),
      );

      final response = await _service.verifyOtp(request);
      _resetToken = response.resetToken;
      _isLoading = false;
      _currentStep = ForgotPasswordStep.resetPassword;
      _stopResendTimer();
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Resend OTP Code
  Future<void> resendOtp({
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    if (!canResend) return;

    _isLoading = true;
    notifyListeners();

    try {
      final request = ForgotPasswordRequestModel(
        email: emailController.text.trim(),
      );

      await _service.requestPasswordReset(request);
      _isLoading = false;
      _startResendTimer();
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError('Failed to resend code. Please try again.');
    }
  }

  /// Step 3: Submit new password
  Future<void> submitNewPassword({
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    if (!resetFormKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final request = ResetPasswordRequestModel(
        email: emailController.text.trim(),
        resetToken: _resetToken ?? 'mock_reset_token',
        newPassword: newPasswordController.text,
      );

      await _service.resetPassword(request);
      _isLoading = false;
      _currentStep = ForgotPasswordStep.success;
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _startResendTimer() {
    _stopResendTimer();
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _stopResendTimer();
      }
    });
  }

  void _stopResendTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopResendTimer();
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
