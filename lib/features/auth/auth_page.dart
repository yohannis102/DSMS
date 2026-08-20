import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';
import '../admin_dashboard/admin_dashboard_page.dart';
import '../forgot_password/forgot_password_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    _controller.submitLogin(
      onSuccess: () {
        if (!mounted) return;
        AppToast.showSuccess(
          context: context,
          title: 'Welcome Back!',
          description:
              'Login successful as ${_controller.currentUser?.name ?? "User"}.',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      },
      onError: (message) {
        if (!mounted) return;
        AppToast.showError(
          context: context,
          title: 'Authentication Failed',
          description: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo & Branding
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          'assets/images/DSMS_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.directions_car_rounded,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to manage your driving lessons & schedules',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Field: Username or Email Address
                    CustomTextField(
                      controller: _controller.identifierController,
                      labelText: 'Username or Email Address',
                      hintText: 'username or student@dsms.com',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _controller.validateIdentifier,
                      enabled: !_controller.isLoading,
                    ),
                    const SizedBox(height: 18),

                    // Input Field: Password
                    CustomTextField(
                      controller: _controller.passwordController,
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_controller.isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      validator: _controller.validatePassword,
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

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _controller.rememberMe,
                                onChanged: _controller.isLoading
                                    ? null
                                    : _controller.toggleRememberMe,
                                activeColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.darkText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _controller.isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    CustomButton(
                      title: 'Sign In',
                      onPressed: _onLoginPressed,
                      isLoading: _controller.isLoading,
                      icon: Icons.login_rounded,
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppToast.showInfo(
                              context: context,
                              title: 'Registration',
                              description:
                                  'Please contact school admin to register.',
                            );
                          },
                          child: const Text(
                            'Contact Admin',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
