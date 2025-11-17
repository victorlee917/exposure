import 'dart:async';
import 'dart:math' as math;
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/common/widgets/text_roll_description.dart';
import 'package:daily_exposures/features/common/widgets/text_roll_title.dart';
import 'package:flutter/material.dart';

import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:daily_exposures/features/create/widgets/preview_film_roll.dart';
import 'package:daily_exposures/database/provider.dart';
import 'package:daily_exposures/database/database.dart';

import 'new_roll_create_screen.dart';

class NewRollScreen extends StatefulWidget {
  const NewRollScreen({super.key, this.initialSelectedIndex = 0});
  final int initialSelectedIndex;

  @override
  State<NewRollScreen> createState() => _NewRollScreenState();
}

class _NewRollScreenState extends State<NewRollScreen> {
  // 페이지/카드 세팅
  static const double _viewportFraction = 0.65;
  static const double _sideScale = 0.86;
  static const double _sideOpacityMin = 0.20;
  static const double _sideTranslateY = 20.0;

  static const int _loopBase = 100;
  static const double _paginationBottomMargin = 58.0;

  // 선택된 페이지의 리스트 자동 스크롤 (데모)
  static const double _autoSpeedPxPerTick = 0.7;
  static const Duration _tick = Duration(milliseconds: 16);

  late final PageController _horizontalPageController;
  final Map<int, ScrollController> _verticalCtrls = {};
  int _activeDataIndex = 0;

  Timer? _autoTimer;
  bool _userDraggingVertical = false;

  // 팝 시 잔상 방지용 플래그
  bool _isPopping = false;

  // Database에서 가져온 Roll 데이터
  List<Roll> _rolls = [];
  bool _isLoading = true;
  int get _pageCount => _rolls.length;

  // 하단 그라데이션 반지름 측정용
  final GlobalKey _markerKey = GlobalKey();
  double _radiusPx = 220.0;

  // For vertical infinite scroll
  static const double _itemHeight = 200.0;
  static const int _initialVerticalItems = 100;

  @override
  void initState() {
    super.initState();
    _loadRolls();
  }

  Future<void> _loadRolls() async {
    final rolls = await database.select(database.rolls).get();

    if (!mounted) return;

    setState(() {
      _rolls = rolls;
      _isLoading = false;
    });

    final initialDataIndex = widget.initialSelectedIndex % _pageCount;
    _activeDataIndex = initialDataIndex;
    final initialRealPage =
        (_loopBase - (_loopBase % _pageCount)) + initialDataIndex;

    _horizontalPageController = PageController(
      initialPage: initialRealPage,
      viewportFraction: _viewportFraction,
      keepPage: true,
    );

    for (var i = 0; i < _pageCount; i++) {
      _verticalCtrls[i] = ScrollController(
        initialScrollOffset: (_initialVerticalItems / 2) * _itemHeight,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndUpdateRadius();
      _startAutoFor(_activeDataIndex);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 시스템 뒤로가기(스와이프/키)로 팝될 때도 감지하여 동결
    final route = ModalRoute.of(context);
    route?.animation?.addStatusListener(_onRouteAnimationStatus);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measureAndUpdateRadius(),
    );
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    final isReversing = status == AnimationStatus.reverse;
    if (isReversing != _isPopping) {
      setState(() => _isPopping = isReversing);
      if (_isPopping) {
        _autoTimer?.cancel(); // 자동 스크롤 즉시 중지
      }
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _horizontalPageController.dispose();
    for (final c in _verticalCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // 그라데이션 반지름 측정
  void _measureAndUpdateRadius() {
    final ctx = _markerKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final topLeft = box.localToGlobal(Offset.zero);
    final markerTop = topLeft.dy;
    final screenH = MediaQuery.of(context).size.height;
    final r = (screenH - markerTop) - 20;

    if (r > 0 && (r - _radiusPx).abs() > 0.5) {
      setState(() => _radiusPx = r);
    }
  }

  // 자동 스크롤(데모)
  void _startAutoFor(int dataIndex) {
    _autoTimer?.cancel();
    _activeDataIndex = dataIndex;

    final ctrl = _verticalCtrls[dataIndex]!;
    _autoTimer = Timer.periodic(_tick, (_) {
      if (!ctrl.hasClients) return;
      if (_userDraggingVertical || _isPopping) return;

      final next = ctrl.offset + _autoSpeedPxPerTick;
      ctrl.jumpTo(next);
    });
  }

  bool _onScrollNotification(ScrollNotification n, int dataIndex) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (dataIndex != _activeDataIndex) return false;

    if (n is ScrollStartNotification) {
      _userDraggingVertical = true;
    } else if (n is ScrollEndNotification) {
      _userDraggingVertical = false;
    }
    return false;
  }

  Widget _buildVerticalList(BuildContext context, int pageIndex) {
    final ctrl = _verticalCtrls[pageIndex]!;
    final currentRoll = _rolls[pageIndex % _rolls.length];
    final aspectRatio = currentRoll.imageRatio;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) => _onScrollNotification(n, pageIndex),
      child: PreviewFilmRoll(
        scrollController: ctrl,
        aspectRatio: aspectRatio,
      ),
    );
  }

  // 가운데/양옆 스타일
  Widget _decorateForIndex({required int index, required Widget child}) {
    final has = _horizontalPageController.hasClients;
    final rawPage = has
        ? (_horizontalPageController.page ??
              _horizontalPageController.initialPage.toDouble())
        : _horizontalPageController.initialPage.toDouble();

    final delta = index - rawPage;
    final t = delta.abs().clamp(0.0, 1.0);
    final ease = 1 - math.pow(1 - t, 3).toDouble();

    final scale = _lerp(1.0, _sideScale, ease);
    final moveY = _lerp(0.0, _sideTranslateY, ease);
    final targetOpacity = _lerp(1.0, _sideOpacityMin, ease);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      opacity: targetOpacity,
      child: Transform.translate(
        offset: Offset(0, moveY),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ====== AppBar (Hero 유지) ======
  PreferredSizeWidget _buildHeroAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Hero(
        tag: 'hero-appbar',
        flightShuttleBuilder: _materialShuttle,
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text('New Roll'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _popWithFreeze, // ← 팝 시 즉시 동결
            ),
          ],
        ),
      ),
    );
  }

  void _popWithFreeze() {
    if (_isPopping) return;
    setState(() => _isPopping = true);
    _autoTimer?.cancel();
    // 다음 프레임에 pop (동결이 한 프레임이라도 먼저 적용되게)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // ====== 하단 오버레이 ======
  Widget _bottomOverlay(BuildContext context) {
    if (_isLoading || _rolls.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 테마 기반 색상 정의
    final ctaButtonBgColor = isDarkMode ? Colors.white : Colors.black;
    final ctaButtonFgColor = isDarkMode ? Colors.black : Colors.white;

    final currentRoll = _rolls[_activeDataIndex % _rolls.length];
    final title = currentRoll.title;
    final desc = currentRoll.description ?? 'No description available';
    final purchased = currentRoll.freeYn;

    final ctaLabel = purchased ? 'Create' : 'Purchase';

    Widget fadeSwitcher(Widget child, String keyId) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeOut,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey('$keyId-${child.hashCode}'),
          child: child,
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Paddings.screentHorizontal,
          0,
          Paddings.screentHorizontal,
          32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(key: _markerKey, height: 0),
            fadeSwitcher(TextRollTitle(text: title), 'title'),
            const SizedBox(height: 8),
            fadeSwitcher(TextRollDescription(text: desc), 'desc'),
            const SizedBox(height: 14),
            // AnimatedSwitcher(
            //   duration: const Duration(milliseconds: 220),
            //   switchInCurve: Curves.easeOutCubic,
            //   switchOutCurve: Curves.easeOutCubic,
            //   child: KeyedSubtree(
            //     key: ValueKey('state-$purchased-$_activeDataIndex'),
            //     child: stateArea,
            //   ),
            // ),
            const SizedBox(height: 18),
            // CTA 버튼 (Hero 유지)
            Hero(
              tag: 'hero-cta',
              flightShuttleBuilder: _materialShuttle,
              child: SizedBox(
                width: double.infinity,
                height: Sizes.sizeButtonHeight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ctaButtonBgColor,
                    foregroundColor: ctaButtonFgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Rvalues.button),
                    ),
                  ),
                  onPressed: () {
                    if (!purchased) {
                      _pushSeamless(
                        context,
                        NewRollCreateScreen(
                          rollTitle: title,
                          rollType: currentRoll.type,
                          ctaLabel: 'Purchase',
                        ),
                      );
                      return;
                    }
                    _pushSeamless(
                      context,
                      NewRollCreateScreen(
                        rollTitle: title,
                        rollType: currentRoll.type,
                        ctaLabel: 'Create',
                      ),
                    );
                  },
                  child: Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontWeight: Fonts.weightExtraHeavy,
                      fontSize: Sizes.sizeButtonFont,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 하단 원형 그라데이션

  Widget _bottomCircularGradient(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Color> gradientColors = isDarkMode
        ? [
            Colors.black.withOpacity(0.95),

            Colors.black.withOpacity(0.55),

            Colors.black.withOpacity(0.18),

            Colors.transparent,
          ]
        : [
            Colors.white.withOpacity(0.1),

            Colors.white.withOpacity(0.55),

            Colors.white.withOpacity(0.20),

            Colors.white.withOpacity(0.0),
          ];

    return IgnorePointer(
      ignoring: true,

      child: CustomPaint(
        painter: _BottomCircleGradientPainter(
          radiusPx: _radiusPx,

          colors: gradientColors,

          stops: const [0.0, 0.45, 0.75, 1.0],
        ),

        size: Size.infinite,
      ),
    );
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildHeroAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_rolls.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildHeroAppBar(),
        body: const Center(
          child: Text('No rolls available'),
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // 라우트 애니메이션이 reverse이거나 _isPopping이면 동결
    final bool freeze =
        _isPopping ||
        (ModalRoute.of(context)?.animation?.status == AnimationStatus.reverse);

    final Widget pages = AnimatedBuilder(
      animation: _horizontalPageController,
      builder: (context, _) {
        return PageView.builder(
          controller: _horizontalPageController,
          scrollDirection: Axis.horizontal,
          padEnds: true,
          clipBehavior: Clip.none,
          onPageChanged: (realIndex) {
            final dataIndex = realIndex % _pageCount;
            setState(() => _activeDataIndex = dataIndex);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _measureAndUpdateRadius();
            });
            _startAutoFor(dataIndex);
          },
          itemBuilder: (context, realIndex) {
            final dataIndex = realIndex % _pageCount;
            final page = _buildVerticalList(context, dataIndex);
            return _decorateForIndex(index: realIndex, child: page);
          },
        );
      },
    );

    // ✨ 잔상 방지 레이어: 팝 시 즉시 동결 + 그리기 경계 분리
    final Widget frozenLayer = ClipRect(
      clipBehavior: Clip.none,
      child: RepaintBoundary(
        child: TickerMode(
          enabled: !freeze, // 애니메이션(오토스크롤/빌더) 정지
          child: IgnorePointer(
            ignoring: freeze, // 입력 차단
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _paginationBottomMargin + bottomInset,
              ),
              child: pages,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: _buildHeroAppBar(), // Hero 유지
      body: Stack(
        children: [
          frozenLayer, // 동결 가능한 메인 컨텐츠
          Positioned.fill(child: _bottomCircularGradient(context)),
          Positioned(
            top: kToolbarHeight + statusBarHeight,
            left: 0,
            right: 0,
            child: const AppbarGradation(height: 40, useThemeBg: true),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _bottomOverlay(context),
          ),
        ],
      ),
    );
  }

  // ===== 유틸 =====
  static Widget _materialShuttle(
    BuildContext _,
    Animation<double> __,
    HeroFlightDirection ___,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final toHero = toContext.widget as Hero;
    return Material(type: MaterialType.transparency, child: toHero.child);
  }

  void _pushSeamless(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero, // 내부 서브화면 전환은 그대로
        reverseTransitionDuration: Duration.zero,
        opaque: true,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, __, ___, child) => child, // Hero만 동작
      ),
    );
  }
}

class _BottomCircleGradientPainter extends CustomPainter {
  final double radiusPx;
  final List<Color> colors;
  final List<double> stops;

  _BottomCircleGradientPainter({
    required this.radiusPx,
    required this.colors,
    required this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final shader = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: colors,
      stops: stops,
    ).createShader(Rect.fromCircle(center: center, radius: radiusPx));

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomCircleGradientPainter oldDelegate) {
    return radiusPx != oldDelegate.radiusPx ||
        colors != oldDelegate.colors ||
        stops != oldDelegate.stops;
  }
}
