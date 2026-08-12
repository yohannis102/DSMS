import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'forgot_password_model.dart';

class ForgotPasswordService {
  final ApiClient _apiClient = ApiClient();

  /// Send password reset request (OTP code sent to email)
  Future<ForgotPasswordResponseModel> requestPasswordReset(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to request password reset.',
        );
      }
    } on DioException catch (_) {
      // Mock Fallback while backend API is not yet available
      await Future.delayed(const Duration(milliseconds: 1200));

      return ForgotPasswordResponseModel(
        success: true,
        message: 'A 6-digit verification code has been sent to ${request.email}.',
      );
    }
  }

  /// Verify the 6-digit OTP code entered by the user
  Future<ForgotPasswordResponseModel> verifyOtp(
    VerifyOtpRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Invalid verification code.',
        );
      }
    } on DioException catch (_) {
      // Mock Fallback: simulate OTP validation
      await Future.delayed(const Duration(milliseconds: 1000));

      if (request.otpCode == '123456' || request.otpCode.length == 6) {
        return ForgotPasswordResponseModel(
          success: true,
          message: 'OTP verified successfully.',
          resetToken: 'mock_reset_token_6digit_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        throw Exception('Invalid OTP code. Please try entering "123456" for demo.');
      }
    }
  }

  /// Reset the user's password with the new password
  Future<ForgotPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to reset password.',
        );
      }
    } on DioException catch (_) {
      // Mock Fallback
      await Future.delayed(const Duration(milliseconds: 1200));

      return ForgotPasswordResponseModel(
        success: true,
        message: 'Your password has been successfully reset. You can now sign in with your new password.',
      );
    }
  }
}
