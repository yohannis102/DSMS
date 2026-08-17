import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import '../instructors/instructors_service.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final ScheduleController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ScheduleController();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _openScheduleForm({ScheduleModel? schedule}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _ScheduleFormSheet(schedule: schedule, controller: _controller),
    );
  }

  void _openScheduleDetails(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (ctx) => _ScheduleDetailsDialog(
        schedule: schedule,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openScheduleForm(schedule: schedule);
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          _confirmDelete(schedule);
        },
      ),
    );
  }

  void _confirmDelete(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _DeleteScheduleDialog(schedule: schedule, controller: _controller),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppToast.showInfo(
      context: context,
      title: 'Copied to Clipboard',
      description: '$label "$text" copied to clipboard.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            _buildTopBar(),
            const SizedBox(height: 16),

            // Summary Metric Cards
            _buildMetricCards(),
            const SizedBox(height: 16),

            // Search & Filters Toolbar
            _buildSearchAndFilters(),
            const SizedBox(height: 16),

            // Table / Content Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Training Schedules',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadSchedules(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.primaryDark,
                ),
                tooltip: 'Refresh Schedules',
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int count = 4;
        double ratio = 2.4;

        if (screenWidth < 520) {
          count = 2;
          ratio = 1.6;
        } else if (screenWidth < 850) {
          count = 2;
          ratio = 2.2;
        } else if (screenWidth < 1200) {
          count = 4;
          ratio = 1.9;
        }

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
          children: [
            _buildStatCard(
              title: 'Total Schedules',
              value: '${_controller.totalCount}',
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF1B70A4),
            ),
            _buildStatCard(
              title: 'Available Slots',
              value: '${_controller.availableSlotsCount}',
              icon: Icons.event_available_rounded,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              title: 'Fully Booked',
              value: '${_controller.fullyBookedCount}',
              icon: Icons.event_busy_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              title: 'Est. Revenue',
              value: _formatCurrency(_controller.totalExpectedValue),
              icon: Icons.monetization_on_outlined,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Box
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 360),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search code, instructor, remarks...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppTheme.secondaryText,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
              onChanged: (val) => _controller.setSearchQuery(val),
            ),
          ),

          // Status Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: AppTheme.secondaryText,
                ),
                const SizedBox(width: 6),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _controller.statusFilter,
                    isDense: true,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('Status: All'),
                      ),
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Full',
                        child: Text('Fully Booked'),
                      ),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _controller.setStatusFilter(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Instructor Filter Dropdown
          if (_controller.availableInstructors.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _controller.instructorFilter,
                      isDense: true,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text('Instructor: All'),
                        ),
                        ..._controller.availableInstructors.map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) _controller.setInstructorFilter(val);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Reset button if filtering active
          if (_searchController.text.isNotEmpty ||
              _controller.statusFilter != 'All' ||
              _controller.instructorFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _controller.setSearchQuery('');
                _controller.setStatusFilter('All');
                _controller.setInstructorFilter('All');
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryDark),
        ),
      );
    }

    if (_controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load training schedules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _controller.loadSchedules(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final schedules = _controller.filteredSchedules;

    if (schedules.isEmpty) {
      final isFiltered =
          _controller.searchQuery.isNotEmpty ||
          _controller.statusFilter != 'All' ||
          _controller.instructorFilter != 'All';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.event_note_rounded,
                size: 54,
                color: AppTheme.secondaryText.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                isFiltered
                    ? 'No schedules match your filters'
                    : 'No training schedules found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFiltered
                    ? 'Try adjusting your search keywords or resetting filters.'
                    : 'Create your first training schedule session to get started.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              if (isFiltered)
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                    _controller.setStatusFilter('All');
                    _controller.setInstructorFilter('All');
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear All Filters'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _openScheduleForm(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add First Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ScrollableTableWrapper(
      headerLeading: ElevatedButton.icon(
        onPressed: () => _openScheduleForm(),
        icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
        label: const Text(
          'Add Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        dataRowMinHeight: 56,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(
            label: Text(
              'Schedule Code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Date & Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Instructor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Slots Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Remarks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
        rows: schedules.map((schedule) {
          return DataRow(
            cells: [
              // Schedule Code with system generated badge & copy action
              DataCell(
                InkWell(
                  onTap: () => _openScheduleDetails(schedule),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B70A4).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF1B70A4).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 14,
                          color: AppTheme.primaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule.scheduleCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Copy Code',
                          onPressed: () => _copyToClipboard(
                            schedule.scheduleCode,
                            'Schedule Code',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Date & Time
              DataCell(
                InkWell(
                  onTap: () => _openScheduleDetails(schedule),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            schedule.date.isNotEmpty ? schedule.date : 'TBD',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule.time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Instructor
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppTheme.secondaryColor.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        schedule.instructor.isNotEmpty
                            ? schedule.instructor[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      schedule.instructor,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Slots Available
              DataCell(_buildSlotsBadge(schedule)),

              // Amount
              DataCell(
                Text(
                  schedule.formattedAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E),
                    fontSize: 13,
                  ),
                ),
              ),

              // Remarks
              DataCell(
                Tooltip(
                  message: schedule.remarks.isNotEmpty
                      ? schedule.remarks
                      : 'No remarks',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      schedule.remarks.isNotEmpty ? schedule.remarks : '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ),
                ),
              ),

              // Status
              DataCell(_buildStatusBadge(schedule)),

              // Actions (View, Edit, Delete)
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      tooltip: 'View Details',
                      onPressed: () => _openScheduleDetails(schedule),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.secondaryColor,
                      ),
                      tooltip: 'Edit Schedule',
                      onPressed: () => _openScheduleForm(schedule: schedule),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      tooltip: 'Delete Schedule',
                      onPressed: () => _confirmDelete(schedule),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlotsBadge(ScheduleModel schedule) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (schedule.slotsAvailable <= 0) {
      bgColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red.shade700;
      icon = Icons.block_rounded;
    } else if (schedule.slotsAvailable <= 2) {
      bgColor = Colors.amber.withValues(alpha: 0.12);
      textColor = Colors.amber.shade900;
      icon = Icons.warning_amber_rounded;
    } else {
      bgColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            '${schedule.slotsAvailable} / ${schedule.totalSlots} Slots',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ScheduleModel schedule) {
    final statusLower = schedule.status.toLowerCase();
    Color bgColor = Colors.green.withValues(alpha: 0.1);
    Color textColor = Colors.green.shade700;

    if (statusLower == 'full') {
      bgColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red.shade700;
    } else if (statusLower == 'completed') {
      bgColor = Colors.blue.withValues(alpha: 0.1);
      textColor = Colors.blue.shade700;
    } else if (statusLower == 'cancelled') {
      bgColor = Colors.grey.withValues(alpha: 0.15);
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        schedule.status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      final formatted = amount.toStringAsFixed(0);
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return '${formatted.replaceAllMapped(reg, (Match m) => '${m[1]},')}';
    }
    return '${amount.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// ADD / EDIT SCHEDULE MODAL BOTTOM SHEET
// ---------------------------------------------------------------------------
class _ScheduleFormSheet extends StatefulWidget {
  final ScheduleModel? schedule;
  final ScheduleController controller;

  const _ScheduleFormSheet({this.schedule, required this.controller});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _instructorController;
  late final TextEditingController _slotsController;
  late final TextEditingController _totalSlotsController;
  late final TextEditingController _amountController;
  late final TextEditingController _remarksController;

  String _selectedStatus = 'Available';
  bool _isSaving = false;
  List<String> _instructorSuggestions = [];

  bool get isEdit => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;

    final initialCode = s?.scheduleCode ?? widget.controller.generateNextCode();
    _codeController = TextEditingController(text: initialCode);
    _dateController = TextEditingController(
      text: s?.date ?? _formatDate(DateTime.now().add(const Duration(days: 1))),
    );
    _timeController = TextEditingController(
      text: s?.time ?? '08:00 AM - 10:00 AM',
    );
    _instructorController = TextEditingController(text: s?.instructor ?? '');
    _slotsController = TextEditingController(
      text: (s?.slotsAvailable ?? 4).toString(),
    );
    _totalSlotsController = TextEditingController(
      text: (s?.totalSlots ?? 4).toString(),
    );
    _amountController = TextEditingController(
      text: s != null ? s.amount.toStringAsFixed(0) : '1500',
    );
    _remarksController = TextEditingController(text: s?.remarks ?? '');
    _selectedStatus = s?.status ?? 'Available';

    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    try {
      final list = await InstructorsService().fetchInstructors();
      if (mounted) {
        setState(() {
          _instructorSuggestions = list
              .map((i) => i.name)
              .where((n) => n.isNotEmpty)
              .toSet()
              .toList();
          if (_instructorController.text.isEmpty &&
              _instructorSuggestions.isNotEmpty) {
            _instructorController.text = _instructorSuggestions.first;
          }
        });
      }
    } catch (_) {
      // Fallback
      if (mounted && _instructorController.text.isEmpty) {
        setState(() {
          _instructorSuggestions = [
            'Michael Scott',
            'Pam Beesly',
            'Jim Halpert',
            'Dwight Schrute',
          ];
          _instructorController.text = _instructorSuggestions.first;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _codeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _instructorController.dispose();
    _slotsController.dispose();
    _totalSlotsController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dateController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _regenerateCode() {
    setState(() {
      _codeController.text = widget.controller.generateNextCode();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final slots = int.tryParse(_slotsController.text.trim()) ?? 1;
    final totalSlots = int.tryParse(_totalSlotsController.text.trim()) ?? slots;
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ??
        0.0;

    final payload = <String, dynamic>{
      'scheduleCode': _codeController.text.trim(),
      'date': _dateController.text.trim(),
      'time': _timeController.text.trim(),
      'instructor': _instructorController.text.trim(),
      'slotsAvailable': slots,
      'totalSlots': totalSlots,
      'amount': amount,
      'remarks': _remarksController.text.trim(),
      'status': _selectedStatus,
    };

    try {
      if (isEdit) {
        await widget.controller.updateSchedule(widget.schedule!.id, payload);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Schedule Updated',
            description:
                'Schedule "${_codeController.text}" was updated successfully.',
          );
        }
      } else {
        await widget.controller.createSchedule(payload);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Schedule Created',
            description:
                'New schedule "${_codeController.text}" was added successfully.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(
          context: context,
          title: isEdit ? 'Update Failed' : 'Creation Failed',
          description: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: screenWidth > 700 ? 650 : double.infinity,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: keyboardSpace + (bottomSafeArea > 0 ? bottomSafeArea : 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEdit
                                ? Icons.edit_calendar_rounded
                                : Icons.add_alarm_rounded,
                            color: AppTheme.primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Schedule' : 'Create New Schedule',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.secondaryText,
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Schedule Code (System Generated)
                      _buildLabel(
                        'Schedule Code',
                        isRequired: true,
                        badgeText: 'SYSTEM GENERATED',
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _codeController,
                        readOnly: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                          letterSpacing: 0.5,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.vpn_key_rounded,
                            size: 18,
                            color: AppTheme.primaryDark,
                          ),
                          suffixIcon: !isEdit
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: AppTheme.primaryDark,
                                  ),
                                  tooltip: 'Generate New Code',
                                  onPressed: _regenerateCode,
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          helperText:
                              'Auto-generated unique code for tracking this session',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Code cannot be empty'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 2. Date & Time Selection
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 460;
                          final dateField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Schedule Date', isRequired: true),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: _pickDate,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.edit_calendar_rounded,
                                      size: 18,
                                    ),
                                    onPressed: _pickDate,
                                  ),
                                  hintText: 'YYYY-MM-DD',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Date is required'
                                    : null,
                              ),
                            ],
                          );

                          final timeField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time Slot', isRequired: true),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    [
                                      '08:00 AM - 10:00 AM',
                                      '10:30 AM - 12:30 PM',
                                      '01:00 PM - 03:00 PM',
                                      '03:30 PM - 05:30 PM',
                                      '06:00 PM - 08:00 PM',
                                    ].contains(_timeController.text)
                                    ? _timeController.text
                                    : '08:00 AM - 10:00 AM',
                                items: const [
                                  DropdownMenuItem(
                                    value: '08:00 AM - 10:00 AM',
                                    child: Text(
                                      '08:00 AM - 10:00 AM (Morning)',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '10:30 AM - 12:30 PM',
                                    child: Text(
                                      '10:30 AM - 12:30 PM (Midday)',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '01:00 PM - 03:00 PM',
                                    child: Text(
                                      '01:00 PM - 03:00 PM (Afternoon)',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '03:30 PM - 05:30 PM',
                                    child: Text(
                                      '03:30 PM - 05:30 PM (Late)',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '06:00 PM - 08:00 PM',
                                    child: Text(
                                      '06:00 PM - 08:00 PM (Night)',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _timeController.text = val);
                                  }
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                dateField,
                                const SizedBox(height: 16),
                                timeField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: dateField),
                              const SizedBox(width: 12),
                              Expanded(flex: 4, child: timeField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Instructor
                      _buildLabel('Assigned Instructor', isRequired: true),
                      const SizedBox(height: 6),
                      if (_instructorSuggestions.isNotEmpty)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue:
                              _instructorSuggestions.contains(
                                _instructorController.text,
                              )
                              ? _instructorController.text
                              : (_instructorSuggestions.isNotEmpty
                                    ? _instructorSuggestions.first
                                    : null),
                          items: _instructorSuggestions
                              .map(
                                (name) => DropdownMenuItem(
                                  value: name,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_pin_rounded,
                                        size: 16,
                                        color: AppTheme.primaryDark,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _instructorController.text = val);
                            }
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined, size: 18),
                            hintText: 'Select instructor',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Instructor is required'
                              : null,
                        )
                      else
                        TextFormField(
                          controller: _instructorController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                            ),
                            hintText: 'Enter instructor full name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Instructor name is required'
                              : null,
                        ),
                      const SizedBox(height: 16),

                      // 4. Slots & Total Capacity
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 460;
                          final availableSlotsField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Available Slots', isRequired: true),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      int cur =
                                          int.tryParse(_slotsController.text) ??
                                          1;
                                      if (cur > 0) {
                                        setState(
                                          () => _slotsController.text =
                                              (cur - 1).toString(),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _slotsController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = int.tryParse(v);
                                        if (n == null || n < 0)
                                          return 'Invalid';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.outlined(
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      int cur =
                                          int.tryParse(_slotsController.text) ??
                                          0;
                                      setState(
                                        () => _slotsController.text = (cur + 1)
                                            .toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );

                          final totalSlotsField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Total Slots Capacity',
                                isRequired: true,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      int cur =
                                          int.tryParse(
                                            _totalSlotsController.text,
                                          ) ??
                                          1;
                                      if (cur > 1) {
                                        setState(
                                          () => _totalSlotsController.text =
                                              (cur - 1).toString(),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _totalSlotsController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        final n = int.tryParse(v);
                                        if (n == null || n <= 0) return '> 0';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.outlined(
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      int cur =
                                          int.tryParse(
                                            _totalSlotsController.text,
                                          ) ??
                                          1;
                                      setState(
                                        () => _totalSlotsController.text =
                                            (cur + 1).toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                availableSlotsField,
                                const SizedBox(height: 16),
                                totalSlotsField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: availableSlotsField),
                              const SizedBox(width: 16),
                              Expanded(child: totalSlotsField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. Amount & Status
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 460;
                          final amountField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Amount / Fee (ETB)',
                                isRequired: true,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  prefixText: 'ETB ',
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkText,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.payments_outlined,
                                    size: 18,
                                  ),
                                  hintText: '1500.00',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Amount required';
                                  final d = double.tryParse(
                                    v.replaceAll(',', ''),
                                  );
                                  if (d == null || d < 0)
                                    return 'Invalid amount';
                                  return null;
                                },
                              ),
                            ],
                          );

                          final statusField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Session Status', isRequired: true),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _selectedStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Available',
                                    child: Text(
                                      'Available / Open',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Full',
                                    child: Text(
                                      'Full / Booked',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Completed',
                                    child: Text(
                                      'Completed',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cancelled',
                                    child: Text(
                                      'Cancelled',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedStatus = val);
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.flag_outlined,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                amountField,
                                const SizedBox(height: 16),
                                statusField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: amountField),
                              const SizedBox(width: 16),
                              Expanded(child: statusField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 6. Remarks
                      _buildLabel('Remarks & Instructions'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'e.g. Beginner driving practicals, clutch control, manual vehicle',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.notes_rounded, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _submit,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isEdit
                                        ? Icons.save_rounded
                                        : Icons.check_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              isEdit ? 'Save Changes' : 'Create Schedule',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    String label, {
    bool isRequired = false,
    String? badgeText,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW SCHEDULE DETAILS DIALOG
// ---------------------------------------------------------------------------
class _ScheduleDetailsDialog extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleDetailsDialog({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: AppTheme.primaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    schedule.scheduleCode,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'SYSTEM CODE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                schedule.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: schedule.isAvailable
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.secondaryText,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 16),

              // Info Grid
              _buildDetailRow(
                Icons.calendar_month_rounded,
                'Date & Time',
                '${schedule.date.isNotEmpty ? schedule.date : 'TBD'} • ${schedule.time}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.badge_outlined,
                'Instructor',
                schedule.instructor,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.event_seat_rounded,
                'Slot Availability',
                '${schedule.slotsAvailable} slots available of ${schedule.totalSlots} total capacity',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.payments_outlined,
                'Fee / Amount',
                schedule.formattedAmount,
                valueColor: const Color(0xFF0F766E),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.comment_outlined,
                'Remarks',
                schedule.remarks.isNotEmpty
                    ? schedule.remarks
                    : 'No special remarks entered.',
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: AppTheme.secondaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DELETE CONFIRMATION DIALOG
// ---------------------------------------------------------------------------
class _DeleteScheduleDialog extends StatefulWidget {
  final ScheduleModel schedule;
  final ScheduleController controller;

  const _DeleteScheduleDialog({
    required this.schedule,
    required this.controller,
  });

  @override
  State<_DeleteScheduleDialog> createState() => _DeleteScheduleDialogState();
}

class _DeleteScheduleDialogState extends State<_DeleteScheduleDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.controller.deleteSchedule(widget.schedule.id);
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: 'Schedule Deleted',
          description:
              'Schedule "${widget.schedule.scheduleCode}" was deleted successfully.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        AppToast.showError(
          context: context,
          title: 'Delete Failed',
          description: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppTheme.errorColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Training Schedule?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete schedule session "${widget.schedule.scheduleCode}" (${widget.schedule.date} with ${widget.schedule.instructor})? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _delete,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_rounded, size: 16),
                    label: const Text('Delete Permanently'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
