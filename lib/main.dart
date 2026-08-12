import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/onboarding/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isCompleted = await OnboardingService().isOnboardingCompleted();
  runApp(MyApp(showOnboarding: !isCompleted));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({
    super.key,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'DSMS - Driving School Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: showOnboarding ? const OnboardingPage() : const AuthPage(),
      ),
    );
  }
}
