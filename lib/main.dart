import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'core/theme/app_theme.dart';
import 'features/admin_dashboard/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'DSMS - Driving School Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AdminDashboardPage(),
      ),
    );
  }
}

