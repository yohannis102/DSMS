import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';
import 'app_toast.dart';

/// A modern widget that listens to ApiClient's isMockMode status.
/// Displays a stylish "DEMO MODE" badge when mock data is active.
class DemoModeBadge extends StatelessWidget {
  final bool showWhenLive;

  const DemoModeBadge({super.key, this.showWhenLive = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ApiClient().isMockMode,
      builder: (context, isMock, _) {
        if (!isMock && !showWhenLive) {
          return const SizedBox.shrink();
        }

        final isDemo = isMock;
        final backgroundColor = isDemo
            ? const Color(0xFFFFF3E0) // Light Amber
            : const Color(0xE8E8F5E9); // Light Green

        final borderColor = isDemo
            ? const Color(0xFFFFB74D) // Amber Accent
            : const Color(0xFF81C784); // Green Accent

        final textColor = isDemo
            ? const Color(0xFFE65100) // Deep Orange/Amber
            : const Color(0xFF2E7D32); // Dark Green

        final iconData = isDemo
            ? Icons.science_rounded
            : Icons.cloud_done_rounded;

        final labelText = isDemo ? 'DEMO MODE' : 'LIVE API';

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showStatusDialog(context, isDemo),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: isDemo
                      ? Colors.orange.withValues(alpha: 0.12)
                      : Colors.green.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                Icon(iconData, size: 14, color: textColor),
                const SizedBox(width: 5),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, bool isDemo) {
    showDialog(
      context: context,
      builder: (ctx) => _DemoModeDialog(isDemo: isDemo),
    );
  }
}

class _DemoModeDialog extends StatefulWidget {
  final bool isDemo;

  const _DemoModeDialog({required this.isDemo});

  @override
  State<_DemoModeDialog> createState() => _DemoModeDialogState();
}

class _DemoModeDialogState extends State<_DemoModeDialog> {
  bool _isChecking = false;

  Future<void> _checkHealth() async {
    setState(() {
      _isChecking = true;
    });

    final isLive = await ApiClient().checkBackendHealth();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (isLive) {
      AppToast.showSuccess(
        context: context,
        title: 'Backend Online!',
        description: 'Connected to live backend server successfully.',
      );
      Navigator.of(context).pop();
    } else {
      AppToast.showInfo(
        context: context,
        title: 'Server Unreachable',
        description:
            'Backend server at ${ApiClient().dio.options.baseUrl} is still offline. Continuing in Demo Mode.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = widget.isDemo;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isDemo ? Icons.science_rounded : Icons.cloud_done_rounded,
            color: isDemo ? Colors.orange.shade800 : Colors.green.shade700,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(
            isDemo ? 'Demo Mode Active' : 'Live API Connected',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDemo ? Colors.amber.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDemo ? Colors.amber.shade200 : Colors.green.shade200,
              ),
            ),
            child: Text(
              isDemo
                  ? 'The application is currently displaying stubbed mock data because the backend API is offline or unreachable.'
                  : 'The application is connected directly to the live backend server.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDemo ? Colors.amber.shade900 : Colors.green.shade900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.dns_outlined,
                size: 16,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 6),
              const Text(
                'Target Base URL:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            ApiClient().dio.options.baseUrl,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isChecking ? null : _checkHealth,
          icon: _isChecking
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh_rounded, size: 16),
          label: Text(_isChecking ? 'Checking...' : 'Check Connection'),
        ),
      ],
    );
  }
}
