import 'dart:math' as math;
import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/rolls.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ItemNavigatorAxis { vertical, horizontal }

class ItemNavigator extends StatefulWidget {
  const ItemNavigator({
    super.key,
    required this.itemCount,
    this.pageController,
    required this.currentPage,
    this.onDragPage,
    this.onSnapPage,
    this.axis = ItemNavigatorAxis.vertical,
  });

  final int itemCount;
  final PageController? pageController;
  final double currentPage;
  final ValueChanged<double>? onDragPage;
  final ValueChanged<int>? onSnapPage;
  final ItemNavigatorAxis axis;

  @override
  State<ItemNavigator> createState() => _ItemNavigatorState();
}

class _ItemNavigatorState extends State<ItemNavigator>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  final GlobalKey _navKey = GlobalKey();
  double? _dragPage;
  double? _targetPage;
  Ticker? _ticker;
  static const double _lerpAlpha = 0.25;
  static const double _stopEps = 0.003;

  void _whenReady(void Function(PageController c) cb) {
    final c = widget.pageController;
    if (c == null) return;
    if (c.hasClients && c.position.haveDimensions) {
      cb(c);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cc = widget.pageController;
      if (cc != null && cc.hasClients && cc.position.haveDimensions) {
        cb(cc);
      }
    });
  }

  double _currentPageFallback() {
    final c = widget.pageController;
    if (c != null && c.hasClients && c.position.haveDimensions) {
      return c.page ?? widget.currentPage;
    }
    return widget.currentPage;
  }

  double _pixelsForPage(PageController c, double page) {
    final minPx = c.position.minScrollExtent;
    final maxPx = c.position.maxScrollExtent;
    final steps = math.max(1, widget.itemCount - 1);
    final perPage = (maxPx - minPx) / steps;
    final clamped = page.clamp(0.0, steps.toDouble()).toDouble();
    return (clamped * perPage) + minPx;
  }

  void _startSmoothingToward(double target) {
    _targetPage = target
        .clamp(0.0, math.max(0, widget.itemCount - 1).toDouble())
        .toDouble();
    _ticker ??= createTicker(_onTick);
    if (!(_ticker!.isActive)) _ticker!.start();
  }

  void _stopSmoothing() {
    _ticker?.stop();
    _targetPage = null;
  }

  void _onTick(Duration _) {
    if (!mounted || _targetPage == null) return;
    _whenReady((c) {
      final cur = c.page ?? widget.currentPage;
      final target = _targetPage!;
      double next = cur + (target - cur) * _lerpAlpha;
      if ((target - cur).abs() <= _stopEps) {
        next = target;
        _stopSmoothing();
      }
      setState(() => _dragPage = next);
      widget.onDragPage?.call(next);
      final px = _pixelsForPage(c, next);
      c.position.jumpTo(px);
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.pageController;
    final isHorizontal = widget.axis == ItemNavigatorAxis.horizontal;

    double effectiveCurrentPage() {
      return _dragPage ?? _currentPageFallback();
    }

    void handleDragStart() {
      setState(() {
        _isPressed = true;
        _dragPage = controller?.page ?? widget.currentPage;
      });
    }

    void handleDragUpdate(Offset localPosition, Size size) {
      if (widget.itemCount <= 0) return;

      const itemExtent = 14.0;
      const maxVisibleDots = 5;
      final visibleCount = widget.itemCount.clamp(0, maxVisibleDots).toInt();
      final currentListDimension = (visibleCount * itemExtent).clamp(1.0, 1e9);

      final double positionOnAxis =
          isHorizontal ? localPosition.dx : localPosition.dy;
      final double containerDimension =
          isHorizontal ? size.width : size.height;
      final double startPadding =
          (containerDimension - currentListDimension) / 2;

      final current = effectiveCurrentPage();
      final currentIndex = current.round();
      final int startDotIndex = widget.itemCount > maxVisibleDots
          ? (currentIndex - 2)
              .clamp(0, math.max(0, widget.itemCount - maxVisibleDots))
              .toInt()
          : 0;

      final double ratio =
          (positionOnAxis - startPadding) / currentListDimension;
      final double pageInVisibleRange = ratio * visibleCount;
      final double targetPageRaw = pageInVisibleRange + startDotIndex;

      final targetPage = targetPageRaw
          .clamp(0.0, math.max(0.0, (widget.itemCount - 1).toDouble()))
          .toDouble();

      _startSmoothingToward(targetPage);
    }

    void handleDragEnd() {
      final finalPage = (_dragPage ?? effectiveCurrentPage())
          .clamp(0.0, math.max(0.0, (widget.itemCount - 1).toDouble()))
          .toDouble();
      final snap = finalPage.round();

      _stopSmoothing();
      widget.onSnapPage?.call(snap);
      _whenReady((c) {
        c.animateToPage(
          snap,
          duration: const Duration(milliseconds: 220),
          curve: Curves.decelerate,
        );
      });

      setState(() {
        _isPressed = false;
        _dragPage = null;
      });
    }

    void handleDragCancel() {
      _stopSmoothing();
      setState(() {
        _isPressed = false;
        _dragPage = null;
      });
    }

    Widget content() {
      final current = effectiveCurrentPage();
      const maxVisibleDots = 5;
      const itemExtent = 14.0;
      final int currentIndex = current.round();
      final int startDotIndex = widget.itemCount > maxVisibleDots
          ? (currentIndex - 2)
              .clamp(0, math.max(0, widget.itemCount - maxVisibleDots))
              .toInt()
          : 0;
      final int visibleCount =
          widget.itemCount.clamp(0, maxVisibleDots).toInt();
      final double listDimension = visibleCount * itemExtent;
      final double maxScrollPages =
          math.max(0.0, (widget.itemCount - maxVisibleDots).toDouble());
      final double clampedPage =
          (current - 2).clamp(0.0, maxScrollPages).toDouble();
      final double scrollOffset = clampedPage * itemExtent;

      return GestureDetector(
        key: _navKey,
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTapUp: (details) {
          final box = _navKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;

          final localPosition = box.globalToLocal(details.globalPosition);
          final size = box.size;

          if (widget.itemCount <= 0) return;

          const itemExtent = 14.0;
          const maxVisibleDots = 5;
          final visibleCount = widget.itemCount.clamp(0, maxVisibleDots).toInt();
          final currentListDimension = (visibleCount * itemExtent).clamp(1.0, 1e9);

          final double positionOnAxis =
              isHorizontal ? localPosition.dx : localPosition.dy;
          final double containerDimension =
              isHorizontal ? size.width : size.height;
          final double startPadding =
              (containerDimension - currentListDimension) / 2;

          final current = effectiveCurrentPage();
          final currentIndex = current.round();
          final int startDotIndex = widget.itemCount > maxVisibleDots
              ? (currentIndex - 2)
                  .clamp(0, math.max(0, widget.itemCount - maxVisibleDots))
                  .toInt()
              : 0;

          final double ratio =
              (positionOnAxis - startPadding) / currentListDimension;
          final double pageInVisibleRange = ratio * visibleCount;
          final double targetPageRaw = pageInVisibleRange + startDotIndex;

          final int snapPage = targetPageRaw.round().clamp(0, widget.itemCount - 1);

          widget.onSnapPage?.call(snapPage);
          _whenReady((c) {
            c.animateToPage(
              snapPage,
              duration: const Duration(milliseconds: 220),
              curve: Curves.decelerate,
            );
          });
        },
        onVerticalDragDown:
            isHorizontal ? null : (_) => setState(() => _isPressed = true),
        onHorizontalDragDown:
            isHorizontal ? (_) => setState(() => _isPressed = true) : null,
        onVerticalDragStart: isHorizontal ? null : (_) => handleDragStart(),
        onHorizontalDragStart: isHorizontal ? (_) => handleDragStart() : null,
        onVerticalDragUpdate: isHorizontal
            ? null
            : (details) {
                final box =
                    _navKey.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;
                handleDragUpdate(
                    box.globalToLocal(details.globalPosition), box.size);
              },
        onHorizontalDragUpdate: isHorizontal
            ? (details) {
                final box =
                    _navKey.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;
                handleDragUpdate(
                    box.globalToLocal(details.globalPosition), box.size);
              }
            : null,
        onVerticalDragEnd: isHorizontal ? null : (_) => handleDragEnd(),
        onHorizontalDragEnd: isHorizontal ? (_) => handleDragEnd() : null,
        onVerticalDragCancel: isHorizontal ? null : () => handleDragCancel(),
        onHorizontalDragCancel:
            isHorizontal ? () => handleDragCancel() : null,
        child: Container(
          height: isHorizontal ? 30 : 90,
          width: isHorizontal ? 90 : 30,
          padding: isHorizontal
              ? const EdgeInsets.symmetric(horizontal: 8.0)
              : const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Rolls.backgroundColorDark
                : Rolls.backgroundColorLight,
            borderRadius: BorderRadius.circular(Rvalues.roll),
            border: _isPressed
                ? Border.all(
                    color: isDarkMode
                        ? Borders.lineColorDark
                        : Borders.lineColorLight,
                    width: 1.0,
                  )
                : null,
          ),
          child: Center(
            child: SizedBox(
              width: isHorizontal ? listDimension : 10,
              height: isHorizontal ? 10 : listDimension,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    left: isHorizontal ? -scrollOffset : null,
                    top: isHorizontal ? null : -scrollOffset,
                    child: ListView.builder(
                      scrollDirection:
                          isHorizontal ? Axis.horizontal : Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.itemCount,
                      itemExtent: itemExtent,
                      itemBuilder: (context, index) {
                        double size = 6.0;
                        if (widget.itemCount > maxVisibleDots) {
                          if (index == startDotIndex && startDotIndex > 0) {
                            size = 4.0;
                          } else if (index ==
                                  startDotIndex + visibleCount - 1 &&
                              startDotIndex <
                                  widget.itemCount - maxVisibleDots) {
                            size = 4.0;
                          }
                        }
                        return Center(
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withAlpha(128)
                                  : Colors.black.withAlpha(128),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 60),
                    curve: Curves.linear,
                    left: isHorizontal
                        ? (current * itemExtent) - scrollOffset + 3.0
                        : null,
                    top: isHorizontal
                        ? null
                        : (current * itemExtent) - scrollOffset + 3.0,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (_, __) => content(),
      );
    }
    return content();
  }
}
