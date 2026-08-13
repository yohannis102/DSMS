import 'package:flutter/material.dart';
import '../../features/auth/auth_page.dart';
import '../theme/app_theme.dart';
import 'app_toast.dart';

class AdminLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onSignOut;
  final Widget child;
  final String? title;

  const AdminLayout({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.onSignOut,
    required this.child,
    this.title,
  });

  String _getDefaultTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Students';
      case 2:
        return 'Instructors';
      case 3:
        return 'Enrolments';
      case 4:
        return 'Schedules';
      case 5:
        return 'Payments';
      case 6:
        return 'Packages';
      default:
        return 'DSMS Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final pageTitle = title ?? _getDefaultTitle(selectedIndex);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (isDesktop)
              Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/DSMS_logo.png',
                  height: 36,
                  fit: BoxFit.contain,
                ),
              )
            else
              const SizedBox(width: 16),
            Text(
              pageTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(child: _buildSidebar(context, isDesktop: false)),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 240,
              child: _buildSidebar(context, isDesktop: true),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isDesktop}) {
    final topPadding = isDesktop ? 0.0 : MediaQuery.of(context).padding.top;

    return Material(
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          if (!isDesktop) ...[
            SizedBox(height: topPadding),
            Container(
              height: 60,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'assets/images/DSMS_logo.png',
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
            const Divider(height: 15),
          ],
          // User Avatar & Info section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.secondaryColor,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin@dsms.com',
                        style: TextStyle(
                          fontSize: 12,
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
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  0,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.people_outline_rounded,
                  'Students',
                  1,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.badge_outlined,
                  'Instructors',
                  2,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.assignment_outlined,
                  'Enrolments',
                  3,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.calendar_month_outlined,
                  'Schedules',
                  4,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.payments_outlined,
                  'Payments',
                  5,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.inventory_2_outlined,
                  'Packages',
                  6,
                  isDesktop,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  if (!isDesktop) {
                    Navigator.of(context).pop();
                  }
                  if (onSignOut != null) {
                    onSignOut!();
                  } else {
                    AppToast.showInfo(
                      context: context,
                      title: 'Signed Out',
                      description: 'You have been signed out successfully.',
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool isDesktop,
  ) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.secondaryColor : AppTheme.secondaryText,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.secondaryColor : AppTheme.darkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryLight,
      onTap: () {
        if (!isDesktop) {
          Navigator.of(context).pop();
        }
        onItemSelected?.call(index);
      },
    );
  }
}
