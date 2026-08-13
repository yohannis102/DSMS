import 'package:flutter/material.dart';
import '../../features/auth/auth_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/onboarding/onboarding_service.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  final OnboardingService _onboardingService = OnboardingService();

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    // Ping backend API to determine whether we are in Live or Demo mode
    ApiClient().checkBackendHealth().catchError((_) => false);

    // Small artificial delay so splash logo renders smoothly
    await Future.delayed(const Duration(milliseconds: 400));
    final bool isCompleted = await _onboardingService.isOnboardingCompleted();

    if (!mounted) return;

    if (!isCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else {
      // If onboarding is completed, navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/DSMS_logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
