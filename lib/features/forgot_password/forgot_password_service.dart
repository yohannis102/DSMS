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
        '/api/auth/forgot-password',
        data: request.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ForgotPasswordResponseModel.fromJson(response.data);
        }
        return ForgotPasswordResponseModel(
          success: true,
          message:
              'A 6-digit verification code has been sent to ${request.email}.',
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to request password reset.',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(e, 'Failed to request password reset.'),
      );
    }
  }

  /// Verify the 6-digit OTP code entered by the user
  Future<ForgotPasswordResponseModel> verifyOtp(
    VerifyOtpRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/verify-otp',
        data: request.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ForgotPasswordResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return ForgotPasswordResponseModel(
            success: true,
            message: 'OTP verified successfully.',
            resetToken: response.data as String,
          );
        }
        return ForgotPasswordResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Invalid verification code.',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(e, 'Invalid verification code.'),
      );
    }
  }

  /// Reset the user's password with the new password
  Future<ForgotPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/reset-password',
        data: request.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ForgotPasswordResponseModel.fromJson(response.data);
        }
        return ForgotPasswordResponseModel(
          success: true,
          message:
              'Your password has been successfully reset. You can now sign in with your new password.',
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to reset password.',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to reset password.'));
    }
  }

  /// Helper to extract error message from backend Dio response
  String _extractErrorMessage(DioException e, String fallbackMessage) {
    if (e.response != null && e.response?.data != null) {
      final dynamic data = ApiClient.parseResponseData(e.response!.data);
      if (data is Map<String, dynamic>) {
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
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['msg'] != null) return data['msg'].toString();
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return e.message ?? fallbackMessage;
  }
}
