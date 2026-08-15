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
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _updateScrollFlags(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Scroll Navigation Bar (On top of the table / columns)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Right: Interactive Top Scroll Buttons (Left & Right Arrows)
                  Container(
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Scroll Left Button
                        Tooltip(
                          message: 'Scroll left',
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(7),
                            ),
                            onTap: _canScrollLeft ? _scrollLeft : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 15,
                                    color: _canScrollLeft
                                        ? AppTheme.primaryDark
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Left',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _canScrollLeft
                                          ? AppTheme.primaryDark
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 18, color: AppTheme.border),
                        // Scroll Right Button
                        Tooltip(
                          message: 'Scroll right',
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(7),
                            ),
                            onTap: _canScrollRight ? _scrollRight : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Right',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _canScrollRight
                                          ? AppTheme.primaryDark
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: _canScrollRight
                                        ? AppTheme.primaryDark
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 4),

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
          ],
        );
      },
    );
  }
}
