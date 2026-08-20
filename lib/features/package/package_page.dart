import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import 'package_controller.dart';
import 'package_model.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  late final PackageController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PackageController();
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

  void _openPackageForm({PackageModel? package}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _PackageFormSheet(package: package, controller: _controller),
    );
  }

  void _openPackageDetails(PackageModel package) {
    showDialog(
      context: context,
      builder: (ctx) => _PackageDetailsDialog(
        package: package,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openPackageForm(package: package);
        },
      ),
    );
  }

  void _confirmDelete(PackageModel package) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _DeletePackageDialog(package: package, controller: _controller),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    // Add comma separation
    final parts = formatted.split('.');
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAll(regex, ',');
    return '${parts.join('.')} ETB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: AppPullToRefresh(
        onRefresh: () async => _controller.loadPackages(),
        color: AppTheme.primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Training Packages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),

              // Metric Summary Cards
              _buildMetricCards(),
              const SizedBox(height: 16),

              // Search & Filter Toolbar
              _buildSearchAndFilters(),
              const SizedBox(height: 14),

              // Main Content Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
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
          ratio = 1.85;
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
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: ratio,
          children: [
            _buildStatCard(
              title: 'Total Packages',
              value: '${_controller.totalCount}',
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF1B70A4),
            ),
            _buildStatCard(
              title: 'Average Price',
              value: _formatCurrency(_controller.averagePrice),
              icon: Icons.analytics_outlined,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              title: 'Highest Price',
              value: _formatCurrency(_controller.highestPrice),
              icon: Icons.trending_up_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            _buildStatCard(
              title: 'Lowest Price',
              value: _formatCurrency(_controller.lowestPrice),
              icon: Icons.sell_outlined,
              color: const Color(0xFFF59E0B),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search packages by name or description...',
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
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => _controller.setSearchQuery(val),
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 24, width: 1, color: AppTheme.border),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _controller.sortFilter,
              icon: const Icon(
                Icons.sort,
                size: 18,
                color: AppTheme.primaryDark,
              ),
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Packages')),
                DropdownMenuItem(
                  value: 'price_asc',
                  child: Text('Price: Low to High'),
                ),
                DropdownMenuItem(
                  value: 'price_desc',
                  child: Text('Price: High to Low'),
                ),
                DropdownMenuItem(
                  value: 'under_10k',
                  child: Text('Under 10,000 ETB'),
                ),
                DropdownMenuItem(
                  value: '10k_to_20k',
                  child: Text('10,000 - 20,000 ETB'),
                ),
                DropdownMenuItem(
                  value: 'over_20k',
                  child: Text('Over 20,000 ETB'),
                ),
              ],
              onChanged: (val) {
                if (val != null) _controller.setSortFilter(val);
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
                'Failed to load packages',
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
                onPressed: () => _controller.loadPackages(),
                icon: const Icon(Icons.refresh, size: 18),
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

    final packages = _controller.filteredPackages;

    if (packages.isEmpty) {
      final isFiltered =
          _controller.searchQuery.isNotEmpty || _controller.sortFilter != 'all';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFiltered
                    ? Icons.search_off_outlined
                    : Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.secondaryText.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                isFiltered
                    ? 'No training packages match your criteria'
                    : 'No packages created yet',
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
                    _controller.setSortFilter('all');
                  },
                  child: const Text('Reset Filters'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _openPackageForm(),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    'Create First Package',
                    style: TextStyle(color: Colors.white),
                  ),
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
        onPressed: () => _openPackageForm(),
        icon: const Icon(Icons.add, size: 16, color: Colors.white),
        label: const Text(
          'Add Package',
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
        dataRowMinHeight: 56,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(
            label: Text(
              'Package Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Description',
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
        rows: packages.map((pkg) {
          return DataRow(
            cells: [
              // Package Name
              DataCell(
                InkWell(
                  onTap: () => _openPackageDetails(pkg),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.drive_eta_outlined,
                          size: 18,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        pkg.name.isNotEmpty ? pkg.name : 'Unnamed Package',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Price
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatCurrency(pkg.price),
                    style: const TextStyle(
                      color: Color(0xFF047857),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Description
              DataCell(
                Tooltip(
                  message: pkg.description,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      pkg.description.isNotEmpty ? pkg.description : '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
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
                        color: Color(0xFF64748B),
                      ),
                      tooltip: 'View Details',
                      onPressed: () => _openPackageDetails(pkg),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.primaryDark,
                      ),
                      tooltip: 'Edit Package',
                      onPressed: () => _openPackageForm(package: pkg),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Delete Package',
                      onPressed: () => _confirmDelete(pkg),
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

class _PackageDetailsDialog extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onEdit;

  const _PackageDetailsDialog({required this.package, required this.onEdit});

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final parts = formatted.split('.');
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAll(regex, ',');
    return '${parts.join('.')} ETB';
  }

  @override
  Widget build(BuildContext context) {
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.card_membership_outlined,
                    size: 28,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (package.id.isNotEmpty)
                        Text(
                          'ID: ${package.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatCurrency(package.price),
                    style: const TextStyle(
                      color: Color(0xFF047857),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.border),
            const SizedBox(height: 14),

            // Details rows
            _buildDetailRow(
              icon: Icons.drive_file_rename_outline,
              label: 'Package Name',
              value: package.name,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.payments_outlined,
              label: 'Price',
              value: _formatCurrency(package.price),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.description_outlined,
              label: 'Description',
              value: package.description.isNotEmpty ? package.description : '-',
            ),
            if (package.createdAt != null && package.createdAt!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Created At',
                value: package.createdAt!,
              ),
            ],
            const SizedBox(height: 24),

            // Actions
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
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text(
                    'Edit Package',
                    style: TextStyle(color: Colors.white),
                  ),
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

  Widget _buildDetailRow({
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
          width: 120,
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

class _PackageFormSheet extends StatefulWidget {
  final PackageModel? package;
  final PackageController controller;

  const _PackageFormSheet({this.package, required this.controller});

  @override
  State<_PackageFormSheet> createState() => _PackageFormSheetState();
}

class _PackageFormSheetState extends State<_PackageFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null
          ? (p.price.truncateToDouble() == p.price
                ? p.price.toInt().toString()
                : p.price.toString())
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = _nameController.text.trim();
    final trimmedDesc = _descriptionController.text.trim();
    final priceVal = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final data = {
      'name': trimmedName,
      'description': trimmedDesc,
      'price': priceVal,
    };

    setState(() => _isSaving = true);

    try {
      if (widget.package == null) {
        await widget.controller.createPackage(data);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Package Created',
            description:
                'Training package "$trimmedName" has been added successfully.',
          );
        }
      } else {
        await widget.controller.updatePackage(widget.package!.id, data);
        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(
            context: context,
            title: 'Package Updated',
            description:
                'Training package "$trimmedName" has been updated successfully.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final rawMsg = e.toString().replaceAll('Exception: ', '');
        AppToast.showError(
          context: context,
          title: widget.package == null
              ? 'Failed to Create Package'
              : 'Failed to Update Package',
          description: rawMsg,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.package != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_note : Icons.add_circle_outline,
                        color: AppTheme.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit
                          ? 'Edit Training Package'
                          : 'Create Training Package',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // Form fields
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package Name field
                    const Text(
                      'Package Name *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Full Driving License Course',
                        prefixIcon: Icon(Icons.drive_eta_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter package name';
                        }
                        if (val.trim().length < 2) {
                          return 'Package name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price field
                    const Text(
                      'Price (ETB) *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'e.g. 15000',
                        prefixIcon: Icon(Icons.payments_outlined, size: 20),
                        suffixText: 'ETB',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null) {
                          return 'Please enter a valid numeric price';
                        }
                        if (numVal < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    const Text(
                      'Description *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe curriculum, sessions, practical driving hours, requirements...',
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter package description';
                        }
                        if (val.trim().length < 5) {
                          return 'Description must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                                  isEdit ? 'Save Changes' : 'Create Package',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
    );
  }
}

class _DeletePackageDialog extends StatefulWidget {
  final PackageModel package;
  final PackageController controller;

  const _DeletePackageDialog({required this.package, required this.controller});

  @override
  State<_DeletePackageDialog> createState() => _DeletePackageDialogState();
}

class _DeletePackageDialogState extends State<_DeletePackageDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);

    try {
      await widget.controller.deletePackage(widget.package.id);
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context: context,
          title: 'Package Deleted',
          description:
              'Package "${widget.package.name}" has been permanently removed.',
        );
      }
    } catch (e) {
      if (mounted) {
        final rawMsg = e.toString().replaceAll('Exception: ', '');
        AppToast.showError(
          context: context,
          title: 'Failed to Delete Package',
          description: rawMsg,
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
          SizedBox(width: 10),
          Text(
            'Delete Package',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Text.rich(
        TextSpan(
          text: 'Are you sure you want to delete the package ',
          children: [
            TextSpan(
              text: '"${widget.package.name}"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const TextSpan(text: '? This action cannot be undone.'),
          ],
        ),
        style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _delete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
