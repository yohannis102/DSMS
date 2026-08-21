import 'package:flutter/material.dart';
import '../../core/widgets/student_layout.dart';
import '../payment/payment_page.dart';
import '../schedule/schedule_page.dart';
import 'pages/student_profile_page.dart';
import 'pages/student_report_page.dart';
import 'student_dashboard_content_view.dart';

class StudentDashboardPage extends StatefulWidget {
  final int initialIndex;

  const StudentDashboardPage({super.key, this.initialIndex = 0});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return StudentDashboardContentView(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1:
        return const StudentProfilePage();
      case 2:
        return const SchedulePage();
      case 3:
        return const PaymentPage();
      case 4:
        return const StudentReportPage();
      default:
        return StudentDashboardContentView(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentLayout(
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: _buildSelectedPage(),
    );
  }
}
