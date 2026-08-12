import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'forgot_password_controller.dart';
import 'forgot_password_model.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: _buildCurrentStepView(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_controller.currentStep) {
      case ForgotPasswordStep.requestEmail:
        return _buildEmailStep();
      case ForgotPasswordStep.verifyOtp:
        return _buildOtpStep();
      case ForgotPasswordStep.resetPassword:
        return _buildResetPasswordStep();
      case ForgotPasswordStep.success:
        return _buildSuccessStep();
    }
  }

  /// Step 1 UI: Email Input
  Widget _buildEmailStep() {
    return Form(
      key: _controller.emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildStepHeader(
            icon: Icons.mark_email_unread_outlined,
            title: 'Reset Password',
            subtitle: 'Enter your registered email address and we will send you a 6-digit verification code.',
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _controller.emailController,
            labelText: 'Email Address',
            hintText: 'student@dsms.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _controller.validateEmail,
            enabled: !_controller.isLoading,
          ),
          const SizedBox(height: 28),
          CustomButton(
            title: 'Send Verification Code',
            isLoading: _controller.isLoading,
            onPressed: () {
              _controller.submitEmailRequest(
                onSuccess: () {
                  AppToast.showSuccess(
                    context: context,
                    title: 'Code Sent',
                    description: 'A 6-digit code has been sent to ${_controller.emailController.text}.',
                  );
                },
                onError: (message) {
                  AppToast.showError(
                    context: context,
                    title: 'Error',
                    description: message,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 2 UI: 6-Digit OTP Verification
  Widget _buildOtpStep() {
    return Form(
      key: _controller.otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildStepHeader(
            icon: Icons.shield_outlined,
            title: 'Verify 6-Digit Code',
            subtitle: 'Enter the 6-digit verification code sent to:\n${_controller.emailController.text}',
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _controller.otpController,
            labelText: 'Verification Code',
            hintText: '123456',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: _controller.validateOtp,
            enabled: !_controller.isLoading,
          ),
          const SizedBox(height: 16),

          // Resend Code Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _controller.canResend
                    ? "Didn't receive the code?"
                    : 'Resend code in ${_controller.resendCountdown}s',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              TextButton(
                onPressed: (_controller.canResend && !_controller.isLoading)
                    ? () {
                        _controller.resendOtp(
                          onSuccess: () {
                            AppToast.showInfo(
                              context: context,
                              title: 'Code Resent',
                              description: 'A new 6-digit verification code has been sent.',
                            );
                          },
                          onError: (message) {
                            AppToast.showError(
                              context: context,
                              title: 'Failed to Resend',
                              description: message,
                            );
                          },
                        );
                      }
                    : null,
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _controller.canResend ? AppTheme.primaryDark : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            title: 'Verify Code',
            isLoading: _controller.isLoading,
            onPressed: () {
              _controller.submitOtpVerification(
                onSuccess: () {
                  AppToast.showSuccess(
                    context: context,
                    title: 'Code Verified',
                    description: 'Set your new password.',
                  );
                },
                onError: (message) {
                  AppToast.showError(
                    context: context,
                    title: 'Verification Failed',
                    description: message,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 3 UI: Reset Password Input
  Widget _buildResetPasswordStep() {
    return Form(
      key: _controller.resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildStepHeader(
            icon: Icons.lock_reset_outlined,
            title: 'Create New Password',
            subtitle: 'Your new password must be strong (at least 8 characters with upper, lower, numbers, and symbols).',
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _controller.newPasswordController,
            labelText: 'New Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !_controller.isPasswordVisible,
            onChanged: _controller.onPasswordChanged,
            validator: _controller.validateNewPassword,
            enabled: !_controller.isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _controller.isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.secondaryText,
                size: 20,
              ),
              onPressed: _controller.togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 12),
          // Password Requirements Checklist Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Requirements:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPasswordRequirement('At least 8 characters long', _controller.hasMinLength),
                _buildPasswordRequirement('At least 1 uppercase letter (A-Z)', _controller.hasUppercase),
                _buildPasswordRequirement('At least 1 lowercase letter (a-z)', _controller.hasLowercase),
                _buildPasswordRequirement('At least 1 number (0-9)', _controller.hasDigit),
                _buildPasswordRequirement('At least 1 special character (!@#\$%^&*)', _controller.hasSpecialChar),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: _controller.confirmPasswordController,
            labelText: 'Confirm New Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !_controller.isConfirmPasswordVisible,
            validator: _controller.validateConfirmPassword,
            enabled: !_controller.isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _controller.isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.secondaryText,
                size: 20,
              ),
              onPressed: _controller.toggleConfirmPasswordVisibility,
            ),
          ),
          const SizedBox(height: 28),
          CustomButton(
            title: 'Reset Password',
            isLoading: _controller.isLoading,
            onPressed: () {
              _controller.submitNewPassword(
                onSuccess: () {
                  AppToast.showSuccess(
                    context: context,
                    title: 'Password Reset',
                    description: 'Your password has been updated successfully!',
                  );
                },
                onError: (message) {
                  AppToast.showError(
                    context: context,
                    title: 'Error',
                    description: message,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 4 UI: Success Confirmation
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Reset Successful!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your password has been updated. You can now use your new password to sign in to your account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),
        CustomButton(
          title: 'Back to Sign In',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: AppTheme.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isSatisfied ? AppTheme.successColor : AppTheme.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
              color: isSatisfied ? AppTheme.darkText : AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
