import 'package:flutter/material.dart';
import '../../features/auth/auth_model.dart';
import '../../features/auth/auth_page.dart';
import '../../features/auth/auth_service.dart';
import '../theme/app_theme.dart';
import 'app_toast.dart';

class StudentLayout extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onSignOut;
  final Widget child;
  final String? title;

  const StudentLayout({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.onSignOut,
    required this.child,
    this.title,
  });

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (AuthService.currentUserNotifier.value == null) {
      await _authService.getSavedUser();
    }
  }

  String _getDefaultTitle(int index) {
    switch (index) {
      case 0:
        return 'Student Dashboard';
      case 1:
        return 'My Profile';
      case 2:
        return 'Schedules';
      case 3:
        return 'Payments';
      case 4:
        return 'Reports';
      default:
        return 'DSMS Student';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final pageTitle = widget.title ?? _getDefaultTitle(widget.selectedIndex);

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
            Expanded(
              child: Text(
                pageTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
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
          Expanded(child: widget.child),
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
          // Student User Avatar & Info section (dynamically loaded from API/Auth session)
          ValueListenableBuilder<UserModel?>(
            valueListenable: AuthService.currentUserNotifier,
            builder: (context, user, _) {
              final displayName = user?.name.isNotEmpty == true
                  ? user!.name
                  : (user?.username.isNotEmpty == true ? user!.username : 'Student User');
              final displayEmail = user?.email?.isNotEmpty == true
                  ? user!.email!
                  : 'student@dsms.com';
              final initial = displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'S';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'STUDENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                                letterSpacing: 0.5,
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
                  Icons.person_outline_rounded,
                  'My Profile',
                  1,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.calendar_month_outlined,
                  'Schedules',
                  2,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.payments_outlined,
                  'Payment',
                  3,
                  isDesktop,
                ),
                _buildNavItem(
                  context,
                  Icons.assessment_outlined,
                  'Report',
                  4,
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
                onTap: () async {
                  if (!isDesktop) {
                    Navigator.of(context).pop();
                  }
                  if (widget.onSignOut != null) {
                    widget.onSignOut!();
                  } else {
                    await AuthService().logout();
                    if (!context.mounted) return;
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
    final isSelected = widget.selectedIndex == index;
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
        widget.onItemSelected?.call(index);
      },
    );
  }
}
