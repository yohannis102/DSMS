enum ForgotPasswordStep {
  requestEmail,
  verifyOtp,
  resetPassword,
  success,
}

class ForgotPasswordRequestModel {
  final String email;

  ForgotPasswordRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class VerifyOtpRequestModel {
  final String email;
  final String otpCode;

  VerifyOtpRequestModel({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
    };
  }
}

class ResetPasswordRequestModel {
  final String email;
  final String resetToken;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'reset_token': resetToken,
      'new_password': newPassword,
    };
  }
}

class ForgotPasswordResponseModel {
  final bool success;
  final String message;
  final String? resetToken;

  ForgotPasswordResponseModel({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Operation successful.',
      resetToken: json['reset_token'] as String?,
    );
  }
}
