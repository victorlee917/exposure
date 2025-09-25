import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ItemNavigator extends StatefulWidget {
  const ItemNavigator({
    super.key,
    required this.itemCount,
    this.verticalPageController,
    required this.currentVerticalPage,
    this.onDragPage, // 드래그 중 실시간 double (부모 표시용)
    this.onSnapPage, // 드래그 종료 시 최종 int (부모 고정용)
  });

  final int itemCount;
  final PageController? verticalPageController;
  final double currentVerticalPage;
  final ValueChanged<double>? onDragPage;
  final ValueChanged<int>? onSnapPage;

  @override
  State<ItemNavigator> createState() => _ItemNavigatorState();
}

class _ItemNavigatorState extends State<ItemNavigator>
    with SingleTickerProviderStateMixin {
  // UI/상태
  bool _isPressed = false;
  final GlobalKey _navKey = GlobalKey();

  // 드래그 동안 인디케이터와 스무싱 타겟
  double? _dragPage; // 현재 표시용(연속값)
  double? _targetPage; // 스무딩 목표 페이지

  // 스무딩용 틱커 (프레임 루프)
  Ticker? _ticker;
  static const double _lerpAlpha = 0.25; // 0~1 (클수록 빠르게 목표로)
  static const double _stopEps = 0.003; // 충분히 가까우면 정지

  // ---------- 유틸 ----------

  void _whenReady(void Function(PageController c) cb) {
    final c = widget.verticalPageController;
    if (c == null) return;

    if (c.hasClients && c.position.haveDimensions) {
      cb(c);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cc = widget.verticalPageController;
      if (cc != null && cc.hasClients && cc.position.haveDimensions) {
        cb(cc);
      }
    });
  }

  double _currentPageFallback() {
    final c = widget.verticalPageController;
    if (c != null && c.hasClients && c.position.haveDimensions) {
      return c.page ?? widget.currentVerticalPage;
    }
    return widget.currentVerticalPage;
  }

  // 페이지 → 픽셀 변환: viewportFraction에 의존하지 않고 실제 스크롤 길이로 계산
  double _pixelsForPage(PageController c, double page) {
    final minPx = c.position.minScrollExtent;
    final maxPx = c.position.maxScrollExtent;
    final steps = math.max(1, widget.itemCount - 1);
    final perPage = (maxPx - minPx) / steps;
    final clamped = page.clamp(0.0, steps.toDouble()).toDouble(); // <- 캐스팅
    return (clamped * perPage) + minPx;
  }

  // 스무딩 시작/진행
  void _startSmoothingToward(double target) {
    _targetPage = target
        .clamp(0.0, math.max(0, widget.itemCount - 1).toDouble())
        .toDouble(); // <- 캐스팅
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
      final cur = c.page ?? widget.currentVerticalPage;
      final target = _targetPage!;
      double next = cur + (target - cur) * _lerpAlpha;

      // 충분히 가까우면 종결
      if ((target - cur).abs() <= _stopEps) {
        next = target;
        _stopSmoothing();
      }

      // 인디케이터/부모 즉시 반영
      setState(() => _dragPage = next);
      widget.onDragPage?.call(next);

      // 실제 페이지도 픽셀 단위로 부드럽게 이동
      final px = _pixelsForPage(c, next);
      c.position.jumpTo(px);
    });
  }

  // ---------- 빌드 ----------

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.verticalPageController;

    double effectiveCurrentPage() {
      // 드래그 중에는 우리가 보간한 값 우선, 아니면 컨트롤러/초기값
      return _dragPage ?? _currentPageFallback();
    }

    Widget content() {
      final current = effectiveCurrentPage();

      const maxVisibleDots = 5;
      const itemExtent = 14.0;

      final int currentIndex = current.round();

      // ← 모두 명시 캐스팅
      final int startDotIndex = widget.itemCount > maxVisibleDots
          ? (currentIndex - 2)
                .clamp(0, math.max(0, widget.itemCount - maxVisibleDots))
                .toInt()
          : 0;

      final int visibleCount = widget.itemCount
          .clamp(0, maxVisibleDots)
          .toInt(); // <- 캐스팅 (int)

      final double listHeight = visibleCount * itemExtent;

      final double maxScrollPages = math.max(
        0.0,
        (widget.itemCount - maxVisibleDots).toDouble(),
      );
      final double clampedPage = (current - 2)
          .clamp(0.0, maxScrollPages)
          .toDouble();
      final double scrollOffset = clampedPage * itemExtent;

      return GestureDetector(
        key: _navKey,
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragDown: (_) => _isPressed = true,
        onVerticalDragStart: (_) {
          setState(() {
            _isPressed = true;
            _dragPage = controller?.page ?? widget.currentVerticalPage;
          });
        },
        onVerticalDragUpdate: (details) {
          if (widget.itemCount <= 0) return;

          final box = _navKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;

          final local = box.globalToLocal(details.globalPosition);
          final h = box.size.height;
          final currentListHeight = (visibleCount * itemExtent).clamp(1.0, 1e9);
          final topPadding = (h - currentListHeight) / 2;

          // 네비게이터 안에서의 상대 위치 → 목표 페이지(연속값)
          final targetPageRaw =
              ((local.dy - topPadding) / currentListHeight * widget.itemCount);
          final targetPage = targetPageRaw
              .clamp(0.0, math.max(0.0, (widget.itemCount - 1).toDouble()))
              .toDouble(); // <- 캐스팅

          _startSmoothingToward(targetPage);
        },
        onVerticalDragEnd: (_) {
          final finalPage = (_dragPage ?? effectiveCurrentPage())
              .clamp(0.0, math.max(0.0, (widget.itemCount - 1).toDouble()))
              .toDouble(); // <- 캐스팅
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
        },
        onVerticalDragCancel: () {
          _stopSmoothing();
          setState(() {
            _isPressed = false;
            _dragPage = null;
          });
        },
        child: Container(
          height: 90,
          width: 30,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
            border: _isPressed
                ? Border.all(color: Colors.white, width: 1.0)
                : null,
          ),
          child: Center(
            child: SizedBox(
              width: 10,
              height: listHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 점 목록 (스크롤 표현)
                  Positioned.fill(
                    top: -scrollOffset,
                    child: ListView.builder(
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
                              color: Colors.white.withAlpha(128),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 현재 위치 점
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 60),
                    curve: Curves.linear,
                    top: (current * itemExtent) - scrollOffset + 3.0,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
