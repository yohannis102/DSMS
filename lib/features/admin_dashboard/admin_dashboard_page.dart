import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/admin_layout.dart';
import '../enrolment/enrolment_page.dart';
import '../instructors/instructors_page.dart';
import '../package/package_page.dart';
import '../payment/payment_page.dart';
import '../schedule/schedule_page.dart';
import '../student/student_page.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: _buildSelectedPage(),
    );
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardContentView(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1:
        return const StudentPage();
      case 2:
        return const InstructorsPage();
      case 3:
        return const EnrolmentPage();
      case 4:
        return const SchedulePage();
      case 5:
        return const PaymentPage();
      case 6:
        return const PackagePage();
      default:
        return DashboardContentView(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
    }
  }
}

class DashboardContentView extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardContentView({super.key, this.onNavigateToTab});

  @override
  State<DashboardContentView> createState() => _DashboardContentViewState();
}

class _DashboardContentViewState extends State<DashboardContentView> {
  late final AdminDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminDashboardController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Metric Cards Grid
            _buildMetricCardsGrid(context),
            const SizedBox(height: 24),

            // Monthly Income Chart Container
            _buildMonthlyIncomeCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCardsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const int crossAxisCount = 2;

    final cards = [
      _MetricCardConfig(
        value: '${_controller.instructorCount}',
        title: 'Instructor',
        bgColor: const Color(0xFF17A2B8),
        darkerColor: const Color(0xFF138496),
        icon: Icons.person,
        onTap: () => widget.onNavigateToTab?.call(2), // Instructors
      ),
      _MetricCardConfig(
        value: '${_controller.studentCount}',
        title: 'Students',
        bgColor: const Color(0xFF28A745),
        darkerColor: const Color(0xFF218838),
        icon: Icons.person,
        onTap: () => widget.onNavigateToTab?.call(1), // Student
      ),
      _MetricCardConfig(
        value: '${_controller.enrolmentCount}',
        title: 'Enrolment',
        bgColor: const Color(0xFFDC3545),
        darkerColor: const Color(0xFFC82333),
        icon: Icons.person_add_alt_1,
        onTap: () => widget.onNavigateToTab?.call(3), // Enrolment
      ),
      _MetricCardConfig(
        value: _formatCurrency(_controller.totalIncome),
        title: 'Income',
        bgColor: const Color(0xFFFFC107),
        darkerColor: const Color(0xFFE0A800),
        textColor: Colors.black87,
        icon: Icons.attach_money_rounded,
        onTap: () => widget.onNavigateToTab?.call(5), // Payment
      ),
    ];

    double childAspectRatio = 2.2;
    if (screenWidth >= 1200) {
      childAspectRatio = 2.8;
    } else if (screenWidth >= 800) {
      childAspectRatio = 2.2;
    } else if (screenWidth >= 500) {
      childAspectRatio = 1.7;
    } else {
      childAspectRatio = 1.25;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => _buildMetricCard(cards[index]),
    );
  }

  Widget _buildMetricCard(_MetricCardConfig config) {
    return Container(
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            config.value,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: config.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            config.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: config.textColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    config.icon,
                    size: 38,
                    color: config.textColor.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: config.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: config.darkerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'More info',
                    style: TextStyle(
                      color: config.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_circle_right_outlined,
                    size: 16,
                    color: config.textColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyIncomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Income',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          // Chart Legends
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem(
                  color: const Color(0xFF4299E1),
                  label: 'Beginner Driving Training',
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  color: const Color(0xFFCBD5E1),
                  label: 'Refresher Courses',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bar Chart Visualization
          SizedBox(
            height: 320,
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 12, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final dataList = _controller.monthlyIncomeData;
    if (dataList.isEmpty) {
      return const Center(child: Text('No monthly data available'));
    }

    final barGroups = dataList.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.beginnerTraining,
            color: const Color(0xFF4299E1),
            width: 14,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: data.refresherCourses,
            color: const Color(0xFFCBD5E1),
            width: 14,
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 4,
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1),
            left: BorderSide(color: Color(0xFFCBD5E1), width: 1),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 10,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < dataList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dataList[index].month,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      final formatted = amount.toStringAsFixed(0);
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return formatted.replaceAllMapped(reg, (Match m) => '${m[1]},');
    }
    return amount.toStringAsFixed(0);
  }
}

class _MetricCardConfig {
  final String value;
  final String title;
  final Color bgColor;
  final Color darkerColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onTap;

  _MetricCardConfig({
    required this.value,
    required this.title,
    required this.bgColor,
    required this.darkerColor,
    this.textColor = Colors.white,
    required this.icon,
    required this.onTap,
  });
}
