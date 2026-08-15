import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A wrapper widget that provides horizontal scrolling with interactive
/// left and right navigation arrow buttons, gradient indicators, and a scrollbar.
class ScrollableTableWrapper extends StatefulWidget {
  final Widget child;
  final double scrollStep;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry padding;

  const ScrollableTableWrapper({
    super.key,
    required this.child,
    this.scrollStep = 280.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ScrollableTableWrapper> createState() => _ScrollableTableWrapperState();
}

class _ScrollableTableWrapperState extends State<ScrollableTableWrapper> {
  late final ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollFlags);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollFlags());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollFlags);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollFlags() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canLeft = position.pixels > 2.0;
    final canRight = position.pixels < (position.maxScrollExtent - 2.0);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset - widget.scrollStep).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + widget.scrollStep).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Schedule scroll flag check on layout change / resize
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollFlags());

        return Stack(
          alignment: Alignment.center,
          children: [
            // Scrollable Content
            ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),

            // Left Scroll Arrow Overlay
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !_canScrollLeft,
                child: AnimatedOpacity(
                  opacity: _canScrollLeft ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.only(left: 4, right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Center(
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black26,
                        child: Tooltip(
                          message: 'Scroll left',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _canScrollLeft ? _scrollLeft : null,
                            hoverColor: AppTheme.primaryDark.withValues(alpha: 0.1),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.border,
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: AppTheme.primaryDark,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right Scroll Arrow Overlay
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !_canScrollRight,
                child: AnimatedOpacity(
                  opacity: _canScrollRight ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.only(right: 4, left: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Center(
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black26,
                        child: Tooltip(
                          message: 'Scroll right',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _canScrollRight ? _scrollRight : null,
                            hoverColor: AppTheme.primaryDark.withValues(alpha: 0.1),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.border,
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppTheme.primaryDark,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
