import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A standardized pull/drag-to-refresh wrapper supporting mobile touch,
/// mouse drag, trackpad, and stylus interactions across all platforms.
class AppPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  const AppPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? AppTheme.secondaryColor,
        child: child,
      ),
    );
  }
}
