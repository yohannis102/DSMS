import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../instructors/instructors_model.dart';
import '../schedule/schedule_model.dart';
import 'student_dashboard_controller.dart';

class StudentDashboardContentView extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const StudentDashboardContentView({super.key, this.onNavigateToTab});

  @override
  State<StudentDashboardContentView> createState() =>
      _StudentDashboardContentViewState();
}

class _StudentDashboardContentViewState
    extends State<StudentDashboardContentView> {
  late final StudentDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentDashboardController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && !_controller.isRefreshing) {
      return const Scaffold(
        backgroundColor: AppTheme.lightBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (_controller.errorMessage != null &&
        _controller.data.instructors.isEmpty &&
        _controller.data.schedules.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  _controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _controller.loadDashboardData(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: AppPullToRefresh(
        onRefresh: () => _controller.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Two Primary Stat Cards: Instructors & Schedules
              _buildStatsGrid(context),
              const SizedBox(height: 24),

              // Schedules Preview Section
              _buildSchedulesSection(context),
              const SizedBox(height: 24),

              // Instructors Preview Section
              _buildInstructorsSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 700;

    final cards = [
      _buildStatCard(
        title: 'Instructors',
        subtitle: 'Certified Driving Trainers',
        value: '${_controller.data.totalInstructors}',
        badgeText: '${_controller.data.activeInstructorsCount} Active',
        icon: Icons.badge_outlined,
        color: AppTheme.primaryColor,
        bgTint: AppTheme.primaryLight,
        onTap: () {},
      ),
      _buildStatCard(
        title: 'Schedules',
        subtitle: 'Training Sessions',
        value: '${_controller.data.totalSchedules}',
        badgeText: '${_controller.data.availableSchedulesCount} Available',
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF0284C7),
        bgTint: const Color(0xFFE0F2FE),
        onTap: () {
          widget.onNavigateToTab?.call(2); // Navigate to Schedules tab
        },
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
        ],
      );
    } else {
      return Column(children: [cards[0], const SizedBox(height: 14), cards[1]]);
    }
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color color,
    required Color bgTint,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: bgTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesSection(BuildContext context) {
    final schedules = _controller.data.schedules;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Training Schedules',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  widget.onNavigateToTab?.call(2); // Go to Schedules tab
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 40,
                      color: AppTheme.secondaryText,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No schedules available at the moment.',
                      style: TextStyle(color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length > 4 ? 4 : schedules.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return _buildScheduleItem(schedule);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleModel schedule) {
    final isAvail = schedule.isAvailable;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isAvail ? const Color(0xFFE0F2FE) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.access_time_filled_rounded,
            color: isAvail ? const Color(0xFF0284C7) : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.scheduleCode.isNotEmpty
                    ? schedule.scheduleCode
                    : 'Driving Session',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${schedule.date}  •  ${schedule.time}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Instructor: ${schedule.instructor}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAvail
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isAvail ? '${schedule.slotsAvailable} Slots' : schedule.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAvail ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorsSection(BuildContext context) {
    final instructors = _controller.data.instructors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Driving Instructors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (instructors.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 40,
                      color: AppTheme.secondaryText,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No instructors registered yet.',
                      style: TextStyle(color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: instructors.length > 4 ? 4 : instructors.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final instructor = instructors[index];
                return _buildInstructorItem(instructor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInstructorItem(InstructorsModel instructor) {
    final name = instructor.name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
    final isActive = instructor.accountStatus.toLowerCase() == 'active';

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                instructor.email.isNotEmpty
                    ? instructor.email
                    : (instructor.contact.isNotEmpty
                          ? instructor.contact
                          : 'Instructor'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              if (instructor.vehicleType != null &&
                  instructor.vehicleType!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Vehicle: ${instructor.vehicleType}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isActive ? 'Active' : instructor.accountStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green[700] : Colors.orange[800],
            ),
          ),
        ),
      ],
    );
  }
}
