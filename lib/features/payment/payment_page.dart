import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import '../enrolment/enrolment_model.dart';
import 'payment_controller.dart';
import 'payment_model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final PaymentController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PaymentController();
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

  void _openPaymentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaymentFormSheet(controller: _controller),
    );
  }

  void _openPaymentDetails(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => _PaymentDetailsDialog(
        payment: payment,
        controller: _controller,
        onVerifyStatus: () {
          Navigator.of(ctx).pop();
          _openUpdateStatusDialog(payment);
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          _confirmDelete(payment);
        },
      ),
    );
  }

  void _openUpdateStatusDialog(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _UpdatePaymentDialog(payment: payment, controller: _controller),
    );
  }

  void _confirmDelete(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _DeletePaymentDialog(payment: payment, controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: AppPullToRefresh(
        onRefresh: () async => _controller.loadPayments(forceRefresh: true),
        color: AppTheme.primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Bar
              _buildHeaderBar(),
              const SizedBox(height: 16),

              // KPI Metrics Cards
              _buildMetricCards(),
              const SizedBox(height: 16),

              // Search, Filters & Action Toolbar
              _buildToolbar(),
              const SizedBox(height: 16),

              // Main Data Table Container
              _buildPaymentsTable(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. Header Bar ---
  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Payments & Invoices',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Track revenue, fee collections, and verify student payments',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final hasDecimals = amount % 1 != 0;
    final formattedNum = hasDecimals ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0);
    final parts = formattedNum.split('.');
    final integerPart = parts[0];
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    if (parts.length > 1) {
      return '$formattedInt.${parts[1]} ETB';
    }
    return '$formattedInt ETB';
  }

  // --- 2. Metric KPI Cards (2x2 Grid) ---
  Widget _buildMetricCards() {
    final currency = _formatCurrency(_controller.totalRevenue);
    final total = _controller.totalCount.toString();
    final paid = _controller.paidCount.toString();
    final unpaid = _controller.unpaidCount.toString();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Revenue',
                value: currency,
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Payments',
                value: total,
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Paid / Verified',
                value: paid,
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Pending / Unpaid',
                value: unpaid,
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 3. Filter & Search Toolbar ---
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          return isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: _buildStatusFilter())]),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: _buildSearchBar()),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildStatusFilter()),
                    const SizedBox(width: 8),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => _controller.setSearchQuery(val),
      decoration: InputDecoration(
        hintText: 'Search by reference, student name, email...',
        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
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
        fillColor: AppTheme.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _controller.statusFilter,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppTheme.secondaryText,
          ),
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.darkText,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All Statuses')),
            DropdownMenuItem(value: 'paid', child: Text('Paid Receipts')),
            DropdownMenuItem(value: 'unpaid', child: Text('Unpaid / Pending')),
          ],
          onChanged: (val) {
            if (val != null) _controller.setStatusFilter(val);
          },
        ),
      ),
    );
  }

  // --- 4. Payments Data Table ---
  Widget _buildPaymentsTable() {
    if (_controller.isLoading) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDark),
              ),
              SizedBox(height: 12),
              Text(
                'Loading payments...',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final payments = _controller.paginatedPayments;

    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.lightBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Payment Records Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try adjusting your search filter or record a new payment.',
                style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openPaymentForm(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Record First Payment'),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrollableTableWrapper(
            headerLeading: ElevatedButton.icon(
              onPressed: () => _openPaymentForm(),
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'Record Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF475569),
              ),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('REFERENCE NO')),
                DataColumn(label: Text('STUDENT')),
                DataColumn(label: Text('SCHEDULE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: payments
                  .map((payment) => _buildPaymentRow(payment))
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          _buildPaginationFooter(),
        ],
      ),
    );
  }

  DataRow _buildPaymentRow(PaymentModel payment) {
    return DataRow(
      cells: [
        // Reference No
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              payment.referenceNo.isNotEmpty ? payment.referenceNo : 'REF-N/A',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),

        // Student Info
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.15),
                child: Text(
                  payment.student.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.student.fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  if (payment.student.email.isNotEmpty)
                    Text(
                      payment.student.email,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.enrollment.schedule.scheduleCode.isNotEmpty
                    ? payment.enrollment.schedule.scheduleCode
                    : 'SCHD-AUTO',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkText,
                ),
              ),
              if (payment.enrollment.schedule.formattedDate.isNotEmpty &&
                  payment.enrollment.schedule.formattedDate != 'N/A')
                Text(
                  payment.enrollment.schedule.formattedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
            ],
          ),
        ),

        // Amount
        DataCell(
          Text(
            payment.formattedAmount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
        ),

        // Date
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.formattedDate,
                style: const TextStyle(fontSize: 12, color: AppTheme.darkText),
              ),
              if (payment.formattedTime.isNotEmpty)
                Text(
                  payment.formattedTime,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.secondaryText,
                  ),
                ),
            ],
          ),
        ),

        // Status Badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: payment.statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  payment.isPaid
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  size: 13,
                  color: payment.statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  payment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: payment.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Details button
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
                tooltip: 'View Payment Details',
                onPressed: () => _openPaymentDetails(payment),
              ),
              // Status verify button (if admin)
              if (_controller.isAdmin)
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  tooltip: 'Update Status & Notes',
                  onPressed: () => _openUpdateStatusDialog(payment),
                ),
              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                tooltip: 'Delete Record',
                onPressed: () => _confirmDelete(payment),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationFooter() {
    final filtered = _controller.filteredPayments;
    final total = filtered.length;
    final start = total == 0
        ? 0
        : (_controller.currentPage - 1) * _controller.pageSize + 1;
    final end = (_controller.currentPage * _controller.pageSize).clamp(
      0,
      total,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $start to $end of $total entries',
            style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: _controller.currentPage > 1
                    ? () => _controller.previousPage()
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${_controller.currentPage} / ${_controller.totalPages}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: _controller.currentPage < _controller.totalPages
                    ? () => _controller.nextPage()
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// METRIC CARD WIDGET
// -----------------------------------------------------------------------------
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
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
  }
}

// -----------------------------------------------------------------------------
// PAYMENT FORM MODAL SHEET (Create Payment)
// -----------------------------------------------------------------------------
class _PaymentFormSheet extends StatefulWidget {
  final PaymentController controller;

  const _PaymentFormSheet({required this.controller});

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedEnrollmentId;
  String _status = 'paid';
  XFile? _pickedProofImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Default admin to paid, non-admin to unpaid
    _status = widget.controller.isAdmin ? 'paid' : 'unpaid';

    // Auto-select first enrollment if available
    if (widget.controller.availableEnrolments.isNotEmpty) {
      final first = widget.controller.availableEnrolments.first;
      _selectedEnrollmentId = first.id;
      if (first.amount > 0) {
        _amountController.text = first.amount.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (xFile != null) {
        setState(() {
          _pickedProofImage = xFile;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context: context,
          title: 'Image Error',
          description: 'Failed to select image: $e',
        );
      }
    }
  }

  void _onEnrollmentSelected(String? enrollmentId) {
    setState(() {
      _selectedEnrollmentId = enrollmentId;
      if (enrollmentId != null) {
        final match = widget.controller.availableEnrolments.firstWhere(
          (e) => e.id == enrollmentId,
          orElse: () => const EnrolmentModel(id: ''),
        );
        if (match.amount > 0) {
          _amountController.text = match.amount.toStringAsFixed(0);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEnrollmentId == null || _selectedEnrollmentId!.isEmpty) {
      AppToast.showWarning(
        context: context,
        title: 'Enrollment Required',
        description: 'Please select an enrollment record.',
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      AppToast.showWarning(
        context: context,
        title: 'Invalid Amount',
        description: 'Amount must be a positive number.',
      );
      return;
    }

    try {
      await widget.controller.createPayment(
        enrollmentId: _selectedEnrollmentId!,
        amount: amount,
        remarks: _remarksController.text.trim(),
        status: _status,
        proofImage: _pickedProofImage,
      );

      if (mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: 'Payment Recorded',
          description: 'Payment was successfully recorded in the system.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context: context,
          title: 'Submission Failed',
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      margin: EdgeInsets.only(
        top: 40,
        bottom: isKeyboardOpen ? MediaQuery.of(context).viewInsets.bottom : 0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Record Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Enrollment Picker
                    const Text(
                      'Select Enrollment *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildEnrollmentDropdown(),
                    const SizedBox(height: 16),

                    // 2. Amount Input
                    const Text(
                      'Payment Amount (ETB) *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 3500',
                        prefixIcon: Icon(
                          Icons.monetization_on_outlined,
                          size: 20,
                          color: AppTheme.secondaryText,
                        ),
                        suffixText: 'ETB',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Payment amount is required';
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return 'Please enter a valid numeric amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Status Picker (for Admin)
                    if (widget.controller.isAdmin) ...[
                      const Text(
                        'Payment Status *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _status = 'paid'),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _status == 'paid'
                                      ? const Color(0xFFDCFCE7)
                                      : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _status == 'paid'
                                        ? const Color(0xFF16A34A)
                                        : AppTheme.border,
                                    width: _status == 'paid' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: _status == 'paid'
                                          ? const Color(0xFF16A34A)
                                          : AppTheme.secondaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mark as Paid',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _status == 'paid'
                                            ? const Color(0xFF16A34A)
                                            : AppTheme.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _status = 'unpaid'),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _status == 'unpaid'
                                      ? const Color(0xFFFEF3C7)
                                      : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _status == 'unpaid'
                                        ? const Color(0xFFD97706)
                                        : AppTheme.border,
                                    width: _status == 'unpaid' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 18,
                                      color: _status == 'unpaid'
                                          ? const Color(0xFFD97706)
                                          : AppTheme.secondaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mark as Unpaid',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _status == 'unpaid'
                                            ? const Color(0xFFD97706)
                                            : AppTheme.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Proof of Payment (Image Upload)
                    const Text(
                      'Proof of Payment (Slip / Screenshot)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildProofPicker(),
                    const SizedBox(height: 16),

                    // 5. Remarks Field
                    const Text(
                      'Remarks / Notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText:
                            'e.g. Cash received at counter, CBE Birr ref #TXN...',
                        prefixIcon: Icon(
                          Icons.notes_rounded,
                          size: 20,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.secondaryText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.controller.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: widget.controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Record Payment',
                            style: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildEnrollmentDropdown() {
    final list = widget.controller.availableEnrolments;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Text(
          'No active enrollments available. You can still input manual ID if needed.',
          style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEnrollmentId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.secondaryText,
          ),
          hint: const Text(
            'Select an enrollment',
            style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
          ),
          items: list.map((enrollment) {
            final studentName = enrollment.studentName;
            final schedCode = enrollment.scheduleCode;
            final courseName = enrollment.packageName;
            final label =
                '$studentName (${schedCode.isNotEmpty ? schedCode : courseName})';

            return DropdownMenuItem<String>(
              value: enrollment.id,
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppTheme.darkText),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _onEnrollmentSelected,
        ),
      ),
    );
  }

  Widget _buildProofPicker() {
    if (_pickedProofImage != null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 50,
                height: 50,
                child: kIsWeb
                    ? Image.network(_pickedProofImage!.path, fit: BoxFit.cover)
                    : Image.file(
                        File(_pickedProofImage!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickedProofImage!.name.isNotEmpty
                        ? _pickedProofImage!.name
                        : 'proof_image.jpg',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Image attached',
                    style: TextStyle(fontSize: 11, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              tooltip: 'Remove Image',
              onPressed: () => setState(() => _pickedProofImage = null),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PAYMENT DETAILS DIALOG
// -----------------------------------------------------------------------------
class _PaymentDetailsDialog extends StatelessWidget {
  final PaymentModel payment;
  final PaymentController controller;
  final VoidCallback onVerifyStatus;
  final VoidCallback onDelete;

  const _PaymentDetailsDialog({
    required this.payment,
    required this.controller,
    required this.onVerifyStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: payment.statusBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          payment.isPaid
                              ? Icons.check_circle_rounded
                              : Icons.pending_actions_rounded,
                          color: payment.statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.referenceNo.isNotEmpty
                                ? payment.referenceNo
                                : 'Payment Details',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          Text(
                            'Status: ${payment.status.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: payment.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Amount Paid / Invoiced',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.formattedAmount,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Student Information
                    _buildSectionHeader('Student Information'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Student Name', payment.student.fullName),
                    if (payment.student.email.isNotEmpty)
                      _buildInfoRow('Email Address', payment.student.email),
                    if (payment.student.username.isNotEmpty)
                      _buildInfoRow('Username', payment.student.username),
                    const SizedBox(height: 16),

                    // Enrollment & Schedule
                    _buildSectionHeader('Enrollment & Schedule'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Schedule Code',
                      payment.enrollment.schedule.scheduleCode.isNotEmpty
                          ? payment.enrollment.schedule.scheduleCode
                          : 'SCHD-AUTO',
                    ),
                    _buildInfoRow('Payment Date', payment.formattedDate),
                    if (payment.formattedTime.isNotEmpty)
                      _buildInfoRow('Time', payment.formattedTime),
                    const SizedBox(height: 16),

                    // Remarks
                    if (payment.remarks.isNotEmpty) ...[
                      _buildSectionHeader('Remarks / Notes'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          payment.remarks,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Proof of Payment
                    if (payment.proofOfPayment.isNotEmpty) ...[
                      _buildSectionHeader('Proof of Payment Attachment'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          child: Image.network(
                            payment.proofOfPayment,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      'Receipt image file attached',
                                      style: TextStyle(
                                        color: AppTheme.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                  const Spacer(),
                  if (!payment.isPaid && controller.isAdmin) ...[
                    ElevatedButton.icon(
                      onPressed: onVerifyStatus,
                      icon: const Icon(Icons.verified_rounded, size: 16),
                      label: const Text('Mark as Paid & Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ] else ...[
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

// -----------------------------------------------------------------------------
// UPDATE STATUS / VERIFY DIALOG
// -----------------------------------------------------------------------------
class _UpdatePaymentDialog extends StatefulWidget {
  final PaymentModel payment;
  final PaymentController controller;

  const _UpdatePaymentDialog({required this.payment, required this.controller});

  @override
  State<_UpdatePaymentDialog> createState() => _UpdatePaymentDialogState();
}

class _UpdatePaymentDialogState extends State<_UpdatePaymentDialog> {
  late String _status;
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _status = widget.payment.status;
    _remarksController = TextEditingController(
      text: widget.payment.remarks.isNotEmpty
          ? widget.payment.remarks
          : 'Verified and marked paid',
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await widget.controller.updatePayment(
        id: widget.payment.id,
        status: _status,
        remarks: _remarksController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: 'Status Updated',
          description: 'Payment status was updated to $_status.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context: context,
          title: 'Update Failed',
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Payment Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 16, color: AppTheme.border),
            const SizedBox(height: 8),

            const Text(
              'Select Status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _status = 'paid'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _status == 'paid'
                            ? const Color(0xFFDCFCE7)
                            : AppTheme.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _status == 'paid'
                              ? const Color(0xFF16A34A)
                              : AppTheme.border,
                          width: _status == 'paid' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: _status == 'paid'
                                ? const Color(0xFF16A34A)
                                : AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Paid',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _status == 'paid'
                                  ? const Color(0xFF16A34A)
                                  : AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _status = 'unpaid'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _status == 'unpaid'
                            ? const Color(0xFFFEF3C7)
                            : AppTheme.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _status == 'unpaid'
                              ? const Color(0xFFD97706)
                              : AppTheme.border,
                          width: _status == 'unpaid' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: _status == 'unpaid'
                                ? const Color(0xFFD97706)
                                : AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unpaid',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _status == 'unpaid'
                                  ? const Color(0xFFD97706)
                                  : AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Verification Remarks',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Verified by cashier, transaction reference matched',
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.secondaryText),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.controller.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: widget.controller.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DELETE PAYMENT CONFIRMATION DIALOG
// -----------------------------------------------------------------------------
class _DeletePaymentDialog extends StatelessWidget {
  final PaymentModel payment;
  final PaymentController controller;

  const _DeletePaymentDialog({required this.payment, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Payment Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete payment ${payment.referenceNo} for ${payment.student.fullName}? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.darkText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting
                        ? null
                        : () async {
                            try {
                              await controller.deletePayment(payment.id);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                AppToast.showSuccess(
                                  context: context,
                                  title: 'Payment Deleted',
                                  description:
                                      'The payment record was deleted.',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppToast.showError(
                                  context: context,
                                  title: 'Delete Failed',
                                  description: e.toString(),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
