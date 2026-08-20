import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/profile_image_picker.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import 'student_controller.dart';
import 'student_model.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  late final StudentController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = StudentController();
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

  void _openStudentForm({StudentModel? student}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _StudentFormSheet(student: student, controller: _controller),
    );
  }

  void _openStudentDetails(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => _StudentDetailsDialog(
        student: student,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openStudentForm(student: student);
        },
      ),
    );
  }

  void _confirmDelete(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _DeleteStudentDialog(student: student, controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: AppPullToRefresh(
        onRefresh: () async => _controller.loadStudents(forceRefresh: true),
        color: AppTheme.primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Students Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Metric Summary Cards
              _buildMetricCards(),
              const SizedBox(height: 12),

              // Search & Filter Toolbar
              _buildSearchAndFilters(),
              const SizedBox(height: 12),

              // Main Content Card
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
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
          ratio = 1.9;
        } else if (screenWidth < 768) {
          count = 2;
          ratio = 2.3;
        } else if (screenWidth < 1100) {
          count = 4;
          ratio = 2.0;
        }

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: ratio,
          children: [
            _buildStatCard(
              title: 'Total',
              value: '${_controller.totalCount}',
              icon: Icons.people_alt_outlined,
              color: const Color(0xFF1B70A4),
            ),
            _buildStatCard(
              title: 'Active',
              value: '${_controller.activeCount}',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              title: 'Pending',
              value: '${_controller.pendingCount}',
              icon: Icons.pending_actions_outlined,
              color: const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              title: 'Inactive',
              value: '${_controller.inactiveCount}',
              icon: Icons.pause_circle_outline,
              color: const Color(0xFF64748B),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (val) => _controller.setSearchQuery(val),
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _controller.statusFilter,
              icon: const Icon(Icons.filter_list, size: 18),
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (val) {
                if (val != null) _controller.setStatusFilter(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryDark),
        ),
      );
    }

    if (_controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load students',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _controller.loadStudents(forceRefresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry Request'),
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

    final students = _controller.filteredStudents;

    if (students.isEmpty) {
      final isFiltered =
          _controller.searchQuery.isNotEmpty ||
          _controller.statusFilter != 'All';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFiltered ? Icons.search_off_outlined : Icons.people_outline,
                size: 48,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(height: 12),
              Text(
                isFiltered
                    ? 'No students matching search/filter'
                    : 'No students found in backend database',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              if (isFiltered)
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                    _controller.setStatusFilter('All');
                  },
                  child: const Text('Clear Filters'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _openStudentForm(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add First Student'),
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
        onPressed: () => _openStudentForm(),
        icon: const Icon(Icons.add, size: 16, color: Colors.white),
        label: const Text(
          'Add Student',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 58,
        columns: const [
          DataColumn(
            label: Text(
              'Student',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Gender',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: students.map((s) {
          final statusLower = s.status.toLowerCase();
          Color statusBgColor = Colors.green.withValues(alpha: 0.1);
          Color statusTextColor = Colors.green;

          if (statusLower == 'pending') {
            statusBgColor = Colors.orange.withValues(alpha: 0.1);
            statusTextColor = Colors.orange.shade800;
          } else if (statusLower == 'inactive') {
            statusBgColor = Colors.red.withValues(alpha: 0.1);
            statusTextColor = Colors.red.shade700;
          }

          return DataRow(
            cells: [
              DataCell(
                InkWell(
                  onTap: () => _openStudentDetails(s),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatar(
                        imageString: s.profilePicture,
                        name: s.name,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.name.isNotEmpty ? s.name : 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(Text(s.email.isNotEmpty ? s.email : '-')),
              DataCell(Text(s.phone.isNotEmpty ? s.phone : '-')),
              DataCell(Text(s.gender.isNotEmpty ? s.gender : '-')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
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
                      tooltip: 'View Profile',
                      onPressed: () => _openStudentDetails(s),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.primaryDark,
                      ),
                      tooltip: 'Edit Student',
                      onPressed: () => _openStudentForm(student: s),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Delete Student',
                      onPressed: () => _confirmDelete(s),
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
}

class _StudentDetailsDialog extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onEdit;

  const _StudentDetailsDialog({required this.student, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final statusLower = student.status.toLowerCase();
    Color statusBgColor = Colors.green.withValues(alpha: 0.1);
    Color statusTextColor = Colors.green;

    if (statusLower == 'pending') {
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
      statusTextColor = Colors.orange.shade800;
    } else if (statusLower == 'inactive') {
      statusBgColor = Colors.red.withValues(alpha: 0.1);
      statusTextColor = Colors.red.shade700;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar & Status
            Row(
              children: [
                ProfileAvatar(
                  imageString: student.profilePicture,
                  name: student.name,
                  radius: 28,
                  fontSize: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name.isNotEmpty ? student.name : 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${student.username.isNotEmpty ? student.username : 'student'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    student.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.border),
            const SizedBox(height: 12),

            // Profile Info Grid
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: student.email.isNotEmpty ? student.email : '-',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: student.phone.isNotEmpty ? student.phone : '-',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Gender',
              value: student.gender.isNotEmpty ? student.gender : '-',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.cake_outlined,
              label: 'Birthdate',
              value: student.birthdate != null && student.birthdate!.isNotEmpty
                  ? student.birthdate!
                  : '-',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: student.address.isNotEmpty ? student.address : '-',
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryText),
        const SizedBox(width: 10),
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentFormSheet extends StatefulWidget {
  final StudentModel? student;
  final StudentController controller;

  const _StudentFormSheet({this.student, required this.controller});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthdateController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactController;
  late final TextEditingController _addressController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _profilePictureController;

  String _gender = 'Female';
  String _accountStatus = 'active';
  bool _isSaving = false;
  bool _obscurePassword = true;

  bool get isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _firstNameController = TextEditingController(text: s?.firstName ?? '');
    _middleNameController = TextEditingController(text: s?.middleName ?? '');
    _lastNameController = TextEditingController(text: s?.lastName ?? '');
    _birthdateController = TextEditingController(text: s?.birthdate ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _contactController = TextEditingController(
      text: s?.contact ?? s?.phone ?? '',
    );
    _addressController = TextEditingController(text: s?.address ?? '');
    _usernameController = TextEditingController(text: s?.username ?? '');
    _passwordController = TextEditingController();
    _profilePictureController = TextEditingController(
      text: s?.profilePicture ?? '',
    );

    if (s != null && s.gender.isNotEmpty) {
      if (s.gender.toLowerCase() == 'male') {
        _gender = 'Male';
      } else {
        _gender = 'Female';
      }
    }

    if (s != null && s.accountStatus.isNotEmpty) {
      _accountStatus = s.accountStatus.toLowerCase();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    DateTime initial = DateTime(2000, 1, 1);
    if (_birthdateController.text.isNotEmpty) {
      try {
        final parsed = DateTime.parse(_birthdateController.text.trim());
        if (parsed.isAfter(DateTime(1900)) && parsed.isBefore(DateTime.now())) {
          initial = parsed;
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryDark,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'gender': _gender,
      'birthdate': _birthdateController.text.trim(),
      'address': _addressController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'profilePicture': _profilePictureController.text.trim(),
      'accountStatus': _accountStatus,
      'role': 'student',
    };

    if (_passwordController.text.isNotEmpty) {
      payload['password'] = _passwordController.text;
    }

    try {
      if (isEdit) {
        await widget.controller.updateStudent(widget.student!.id, payload);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Student Updated',
            description:
                '${_firstNameController.text} has been updated successfully.',
          );
        }
      } else {
        await widget.controller.createStudent(payload);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Student Created',
            description:
                '${_firstNameController.text} has been added successfully.',
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Student' : 'Add New Student',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
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
          // Scrollable Form Body
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: keyboardSpace + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image Picker (Camera / Gallery Upload)
                    ProfileImagePicker(
                      initialImage: _profilePictureController.text,
                      name:
                          '${_firstNameController.text} ${_lastNameController.text}',
                      onImageChanged: (val) {
                        setState(() {
                          _profilePictureController.text = val ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name *',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _middleNameController,
                            decoration: const InputDecoration(
                              labelText: 'Middle Name',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name *',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _gender = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _birthdateController,
                            readOnly: true,
                            onTap: _selectBirthdate,
                            decoration: InputDecoration(
                              labelText: 'Birthdate',
                              hintText: 'YYYY-MM-DD',
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                onPressed: _selectBirthdate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Contact / Phone *',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username *',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: isEdit
                                  ? 'Password (Leave blank to keep)'
                                  : 'Password *',
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: AppTheme.secondaryText,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (!isEdit && (v == null || v.trim().isEmpty)) {
                                return 'Password required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _accountStatus,
                      decoration: const InputDecoration(
                        labelText: 'Account Status',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _accountStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondaryText,
                            side: const BorderSide(color: AppTheme.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Update Student' : 'Create Student',
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
    );
  }
}

class _DeleteStudentDialog extends StatefulWidget {
  final StudentModel student;
  final StudentController controller;

  const _DeleteStudentDialog({required this.student, required this.controller});

  @override
  State<_DeleteStudentDialog> createState() => _DeleteStudentDialogState();
}

class _DeleteStudentDialogState extends State<_DeleteStudentDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.controller.deleteStudent(widget.student.id);
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: 'Student Deleted',
          description: '${widget.student.name} has been deleted successfully.',
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
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
          SizedBox(width: 8),
          Text(
            'Delete Student',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete ${widget.student.name.isNotEmpty ? widget.student.name : widget.student.id}? This action cannot be undone.',
        style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
