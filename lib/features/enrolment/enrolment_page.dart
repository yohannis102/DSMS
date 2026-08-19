import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import '../package/package_model.dart';
import '../schedule/schedule_model.dart';
import '../student/student_model.dart';
import 'enrolment_controller.dart';
import 'enrolment_model.dart';

class EnrolmentPage extends StatefulWidget {
  const EnrolmentPage({super.key});

  @override
  State<EnrolmentPage> createState() => _EnrolmentPageState();
}

class _EnrolmentPageState extends State<EnrolmentPage> {
  late final EnrolmentController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = EnrolmentController();
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

  void _openEnrollmentForm({EnrolmentModel? enrolment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _EnrollmentFormSheet(enrolment: enrolment, controller: _controller),
    );
  }

  void _openEnrollmentDetails(EnrolmentModel enrolment) {
    showDialog(
      context: context,
      builder: (ctx) => _EnrollmentDetailsDialog(
        enrolment: enrolment,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openEnrollmentForm(enrolment: enrolment);
        },
      ),
    );
  }

  void _confirmDelete(EnrolmentModel enrolment) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteEnrollmentDialog(
        enrolment: enrolment,
        controller: _controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            _buildTopBar(),
            const SizedBox(height: 18),

            // Metric Summary Cards
            _buildMetricCards(),
            const SizedBox(height: 18),

            // Search & Filter Toolbar
            _buildSearchAndFilters(),
            const SizedBox(height: 16),

            // Main Content Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header / Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enrolled Students (${_controller.filteredEnrolments.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openEnrollmentForm(),
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 15,
                        ),
                        label: const Text(
                          'New Enrollment',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Data View
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    )
                  else if (_controller.filteredEnrolments.isEmpty)
                    _buildEmptyState()
                  else if (isDesktop)
                    _buildDesktopTable()
                  else
                    _buildMobileCardsList(),

                  const SizedBox(height: 16),

                  // Pagination Footer
                  if (!_controller.isLoading &&
                      _controller.filteredEnrolments.isNotEmpty)
                    _buildPaginationFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Enrolments Management',
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
                  : () {
                      _controller.loadEnrolments();
                      _controller.loadDependencies();
                    },
              icon: const Icon(Icons.refresh, color: AppTheme.primaryDark),
              tooltip: 'Refresh Enrolments',
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int count = 4;
        double ratio = 2.4;

        if (screenWidth < 480) {
          count = 2;
          ratio = 1.95;
        } else if (screenWidth < 768) {
          count = 2;
          ratio = 2.3;
        } else if (screenWidth < 1100) {
          count = 4;
          ratio = 2.0;
        }

        final items = [
          _MetricCardData(
            title: 'Total Enrolled',
            value: '${_controller.totalCount}',
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF1B70A4),
            bgColor: const Color(0xFFEBF5FB),
          ),
          _MetricCardData(
            title: 'Active Courses',
            value: '${_controller.activeCount}',
            icon: Icons.play_circle_filled_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
          _MetricCardData(
            title: 'Completed',
            value: '${_controller.completedCount}',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF6366F1),
            bgColor: const Color(0xFFEEF2FF),
          ),
          _MetricCardData(
            title: 'Total Revenue',
            value: _controller.formattedTotalRevenue,
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: ratio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Input
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _controller.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search student, schedule, instructor...',
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppTheme.secondaryText,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),

          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.statusFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Status: All')),
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Status: Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Status: Completed'),
                  ),
                  DropdownMenuItem(
                    value: 'Cancelled',
                    child: Text('Status: Cancelled'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) _controller.setStatusFilter(val);
                },
                style: const TextStyle(fontSize: 13, color: AppTheme.darkText),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          ),

          if (_searchController.text.isNotEmpty ||
              _controller.statusFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _controller.setSearchQuery('');
                _controller.setStatusFilter('All');
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 48,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No enrollments found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search query or enroll a new student.',
              style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _openEnrollmentForm(),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('New Enrollment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    final list = _controller.paginatedEnrolments;

    return ScrollableTableWrapper(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        horizontalMargin: 16,
        columnSpacing: 20,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryText,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        columns: const [
          DataColumn(label: Text('STUDENT')),
          DataColumn(label: Text('SCHEDULE & DATE')),
          DataColumn(label: Text('INSTRUCTOR')),
          DataColumn(label: Text('PACKAGE & FEE')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('REMARKS')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: list.map((enrolment) {
          return DataRow(
            cells: [
              // Student
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        enrolment.student?.initials ?? 'ST',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          enrolment.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                            fontSize: 13,
                          ),
                        ),
                        if (enrolment.student?.email.isNotEmpty == true)
                          Text(
                            enrolment.student!.email,
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

              // Schedule
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        enrolment.scheduleCode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enrolment.enrolmentDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Instructor
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      enrolment.instructorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppTheme.darkText,
                      ),
                    ),
                    if (enrolment.instructor?.email.isNotEmpty == true)
                      Text(
                        enrolment.instructor!.email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),

              // Package & Amount
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      enrolment.packageName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      enrolment.formattedAmount,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Status
              DataCell(_buildStatusBadge(enrolment.status)),

              // Remarks
              DataCell(
                SizedBox(
                  width: 140,
                  child: Text(
                    enrolment.remarks,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.secondaryColor,
                      ),
                      tooltip: 'View Details',
                      onPressed: () => _openEnrollmentDetails(enrolment),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.primaryDark,
                      ),
                      tooltip: 'Edit Enrollment',
                      onPressed: () =>
                          _openEnrollmentForm(enrolment: enrolment),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      tooltip: 'Cancel / Delete',
                      onPressed: () => _confirmDelete(enrolment),
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

  Widget _buildMobileCardsList() {
    final list = _controller.paginatedEnrolments;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 20),
      itemBuilder: (context, index) {
        final enrolment = list[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Text(
                            enrolment.student?.initials ?? 'ST',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            enrolment.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(enrolment.status),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildInfoTag(Icons.event_note, enrolment.scheduleCode),
                  _buildInfoTag(Icons.calendar_today, enrolment.enrolmentDate),
                  _buildInfoTag(Icons.person, enrolment.instructorName),
                  _buildInfoTag(Icons.drive_eta, enrolment.packageName),
                  _buildInfoTag(Icons.attach_money, enrolment.formattedAmount),
                ],
              ),
              if (enrolment.remarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Remarks: ${enrolment.remarks}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _openEnrollmentDetails(enrolment),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    label: const Text(
                      'Details',
                      style: TextStyle(color: AppTheme.secondaryColor),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openEnrollmentForm(enrolment: enrolment),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: AppTheme.secondaryColor),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(enrolment),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.secondaryText),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppTheme.darkText),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFECFDF5);
    Color fg = const Color(0xFF047857);
    Color border = const Color(0xFFA7F3D0);

    if (status.toLowerCase() == 'completed') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      border = const Color(0xFFBFDBFE);
    } else if (status.toLowerCase() == 'cancelled') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFB91C1C);
      border = const Color(0xFFFECACA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    final filtered = _controller.filteredEnrolments;
    final total = filtered.length;
    final start = (_controller.currentPage - 1) * _controller.pageSize + 1;
    final end = (_controller.currentPage * _controller.pageSize).clamp(
      0,
      total,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $start to $end of $total entries',
          style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _controller.currentPage > 1
                  ? () => _controller.setPage(_controller.currentPage - 1)
                  : null,
            ),
            Text(
              '${_controller.currentPage} / ${_controller.totalPages}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _controller.currentPage < _controller.totalPages
                  ? () => _controller.setPage(_controller.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

// -------------------------------------------------------------
// Enrollment Creation / Edit Form Sheet
// -------------------------------------------------------------
class _EnrollmentFormSheet extends StatefulWidget {
  final EnrolmentModel? enrolment;
  final EnrolmentController controller;

  const _EnrollmentFormSheet({this.enrolment, required this.controller});

  @override
  State<_EnrollmentFormSheet> createState() => _EnrollmentFormSheetState();
}

class _EnrollmentFormSheetState extends State<_EnrollmentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  String? _selectedScheduleId;
  String? _selectedPackageId;
  String _selectedStatus = 'Active';
  late final TextEditingController _remarksController;

  bool _isSubmitting = false;
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    final e = widget.enrolment;
    _remarksController = TextEditingController(
      text: e?.remarks ?? 'Enrolled by admin',
    );

    if (e != null) {
      _selectedStudentId = e.student?.id.isNotEmpty == true
          ? e.student!.id
          : null;
      _selectedScheduleId = e.schedule?.id.isNotEmpty == true
          ? e.schedule!.id
          : null;
      _selectedPackageId = e.package?.id.isNotEmpty == true
          ? e.package!.id
          : null;
      _selectedStatus = e.status;
    }

    // Refresh dependencies if list is empty
    if (widget.controller.availableStudents.isEmpty ||
        widget.controller.availableSchedules.isEmpty ||
        widget.controller.availablePackages.isEmpty) {
      widget.controller.loadDependencies();
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  StudentModel? get _selectedStudent {
    if (_selectedStudentId == null) return null;
    try {
      return widget.controller.availableStudents.firstWhere(
        (s) => s.id == _selectedStudentId,
      );
    } catch (_) {
      return null;
    }
  }

  ScheduleModel? get _selectedSchedule {
    if (_selectedScheduleId == null) return null;
    try {
      return widget.controller.availableSchedules.firstWhere(
        (s) => s.id == _selectedScheduleId,
      );
    } catch (_) {
      return null;
    }
  }

  PackageModel? get _selectedPackage {
    if (_selectedPackageId == null) return null;
    try {
      return widget.controller.availablePackages.firstWhere(
        (p) => p.id == _selectedPackageId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudentId == null || _selectedStudentId!.isEmpty) {
      setState(() => _fieldError = 'Please select a student');
      return;
    }
    if (_selectedScheduleId == null || _selectedScheduleId!.isEmpty) {
      setState(() => _fieldError = 'Please select a schedule');
      return;
    }
    if (_selectedPackageId == null || _selectedPackageId!.isEmpty) {
      setState(() => _fieldError = 'Please select a training package');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _fieldError = null;
    });

    final extraContext = {
      if (_selectedStudent != null)
        'student': {
          '_id': _selectedStudent!.id,
          'firstName': _selectedStudent!.firstName,
          'lastName': _selectedStudent!.lastName,
          'email': _selectedStudent!.email,
          'username': _selectedStudent!.username,
        },
      if (_selectedSchedule != null)
        'schedule': {
          '_id': _selectedSchedule!.id,
          'scheduleCode': _selectedSchedule!.scheduleCode,
          'date': _selectedSchedule!.date,
          'slotsAvailable': _selectedSchedule!.slotsAvailable,
          'amount': _selectedSchedule!.amount,
        },
      if (_selectedPackage != null)
        'package': {
          '_id': _selectedPackage!.id,
          'name': _selectedPackage!.name,
          'price': _selectedPackage!.price,
          'description': _selectedPackage!.description,
        },
    };

    bool success = false;
    if (widget.enrolment == null) {
      // Create new enrollment
      success = await widget.controller.createEnrolment(
        scheduleId: _selectedScheduleId!,
        packageId: _selectedPackageId!,
        studentId: _selectedStudentId!,
        remarks: _remarksController.text.trim(),
        extraContext: extraContext,
      );
    } else {
      // Update existing enrollment
      success = await widget.controller.updateEnrolment(widget.enrolment!.id, {
        'remarks': _remarksController.text.trim(),
        'status': _selectedStatus,
        'scheduleId': _selectedScheduleId,
        'packageId': _selectedPackageId,
        'student': _selectedStudentId,
      });
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: widget.enrolment == null
              ? 'Enrollment Created'
              : 'Enrollment Updated',
          description: widget.enrolment == null
              ? 'Student successfully enrolled into training schedule.'
              : 'Enrollment details saved successfully.',
        );
      } else {
        final err = widget.controller.errorMessage ?? 'An error occurred';
        setState(() => _fieldError = err);
        AppToast.showError(
          context: context,
          title: 'Enrollment Failed',
          description: err,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.controller.availableStudents;
    final schedules = widget.controller.availableSchedules;
    final packages = widget.controller.availablePackages;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: AppTheme.secondaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.enrolment == null
                                ? 'New Student Enrollment'
                                : 'Edit Enrollment',
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
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              if (_fieldError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fieldError!,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Select Student
              const Text(
                'Student *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedStudentId,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select Student',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                items: students.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.id,
                    child: Text(
                      '${s.name} (${s.email})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStudentId = val;
                    _fieldError = null;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Student is required' : null,
              ),
              const SizedBox(height: 16),

              // 2. Select Training Package
              const Text(
                'Training Package *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedPackageId,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select Training Package',
                  prefixIcon: Icon(Icons.drive_eta_outlined, size: 20),
                ),
                items: packages.map((p) {
                  return DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(
                      '${p.name} - ETB ${p.price.toStringAsFixed(0)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPackageId = val;
                    _fieldError = null;
                  });
                },
                validator: (val) => val == null || val.isEmpty
                    ? 'A valid packageId is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. Select Schedule
              const Text(
                'Driving Schedule Slot *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedScheduleId,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select Schedule Slot',
                  prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                ),
                items: schedules.map((sch) {
                  return DropdownMenuItem<String>(
                    value: sch.id,
                    child: Text(
                      '${sch.scheduleCode} | ${sch.date} (${sch.time}) - Instructor: ${sch.instructor}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedScheduleId = val;
                    _fieldError = null;
                  });
                },
                validator: (val) => val == null || val.isEmpty
                    ? 'A valid scheduleId is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Status (if editing)
              if (widget.enrolment != null) ...[
                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.flag_outlined, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
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
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 4. Remarks
              const Text(
                'Remarks / Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Enrolled by admin',
                  prefixIcon: Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // Live Summary Calculation Card
              if (_selectedStudent != null ||
                  _selectedSchedule != null ||
                  _selectedPackage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enrollment Summary',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedStudent != null)
                        _buildSummaryRow('Student', _selectedStudent!.name),
                      if (_selectedPackage != null)
                        _buildSummaryRow(
                          'Course Package',
                          _selectedPackage!.name,
                        ),
                      if (_selectedSchedule != null) ...[
                        _buildSummaryRow(
                          'Schedule Code',
                          _selectedSchedule!.scheduleCode,
                        ),
                        _buildSummaryRow(
                          'Schedule Date',
                          '${_selectedSchedule!.date} (${_selectedSchedule!.time})',
                        ),
                        _buildSummaryRow(
                          'Instructor',
                          _selectedSchedule!.instructor,
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payable Fee:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _selectedPackage != null
                                ? 'ETB ${_selectedPackage!.price.toStringAsFixed(2)}'
                                : (_selectedSchedule != null
                                      ? 'ETB ${_selectedSchedule!.amount.toStringAsFixed(2)}'
                                      : 'ETB 0.00'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.secondaryColor,
                              ),
                            )
                          : Text(
                              widget.enrolment == null
                                  ? 'Confirm Enrollment'
                                  : 'Save Changes',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Enrollment Details / Official Certificate Dialog
// -------------------------------------------------------------
class _EnrollmentDetailsDialog extends StatelessWidget {
  final EnrolmentModel enrolment;
  final VoidCallback onEdit;

  const _EnrollmentDetailsDialog({
    required this.enrolment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF1D4ED8),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Enrollment Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'ID: ${enrolment.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.secondaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Student Section
              _buildSectionTitle('STUDENT PROFILE'),
              const SizedBox(height: 8),
              _buildInfoRow('Full Name', enrolment.studentName),
              if (enrolment.student?.email.isNotEmpty == true)
                _buildInfoRow('Email Address', enrolment.student!.email),
              if (enrolment.student?.username.isNotEmpty == true)
                _buildInfoRow('Username', enrolment.student!.username),

              const Divider(height: 20),

              // Schedule Section
              _buildSectionTitle('TRAINING SCHEDULE'),
              const SizedBox(height: 8),
              _buildInfoRow('Schedule Code', enrolment.scheduleCode),
              _buildInfoRow(
                'Date & Time',
                '${enrolment.enrolmentDate} (${enrolment.schedule?.formattedTime ?? "09:00 AM"})',
              ),
              if (enrolment.schedule != null &&
                  enrolment.schedule!.slotsAvailable > 0)
                _buildInfoRow(
                  'Slots Available',
                  '${enrolment.schedule!.slotsAvailable} slots',
                ),

              const Divider(height: 20),

              // Instructor Section
              _buildSectionTitle('ASSIGNED INSTRUCTOR'),
              const SizedBox(height: 8),
              _buildInfoRow('Instructor Name', enrolment.instructorName),
              if (enrolment.instructor?.email.isNotEmpty == true)
                _buildInfoRow('Instructor Email', enrolment.instructor!.email),

              const Divider(height: 20),

              // Package & Fee Section
              _buildSectionTitle('PACKAGE & FINANCIALS'),
              const SizedBox(height: 8),
              _buildInfoRow('Course Package', enrolment.packageName),
              _buildInfoRow('Total Amount', enrolment.formattedAmount),
              _buildInfoRow('Status', enrolment.status),
              _buildInfoRow('Payment Status', enrolment.paymentStatus),
              _buildInfoRow('Remarks', enrolment.remarks),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        AppToast.showInfo(
                          context: context,
                          title: 'Slip Generated',
                          description:
                              'Enrollment slip ready for printing/export.',
                        );
                      },
                      icon: const Icon(
                        Icons.print_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Print Slip',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Delete / Cancel Enrollment Dialog
// -------------------------------------------------------------
class _DeleteEnrollmentDialog extends StatefulWidget {
  final EnrolmentModel enrolment;
  final EnrolmentController controller;

  const _DeleteEnrollmentDialog({
    required this.enrolment,
    required this.controller,
  });

  @override
  State<_DeleteEnrollmentDialog> createState() =>
      _DeleteEnrollmentDialogState();
}

class _DeleteEnrollmentDialogState extends State<_DeleteEnrollmentDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    final success = await widget.controller.deleteEnrolment(
      widget.enrolment.id,
    );

    if (mounted) {
      setState(() => _isDeleting = false);
      Navigator.of(context).pop();
      if (success) {
        AppToast.showSuccess(
          context: context,
          title: 'Enrollment Cancelled',
          description: 'Enrollment has been successfully removed.',
        );
      } else {
        AppToast.showError(
          context: context,
          title: 'Cancellation Failed',
          description:
              widget.controller.errorMessage ?? 'Could not delete enrollment',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
          SizedBox(width: 10),
          Text(
            'Cancel Enrollment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to cancel the enrollment for "${widget.enrolment.studentName}" in schedule "${widget.enrolment.scheduleCode}"?',
        style: const TextStyle(fontSize: 14, color: AppTheme.darkText),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Keep', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _delete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.secondaryColor,
                  ),
                )
              : const Text('Cancel Enrollment'),
        ),
      ],
    );
  }
}
