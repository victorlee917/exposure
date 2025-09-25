import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'new_roll_create_screen.dart';

class NewRollScreen extends StatefulWidget {
  const NewRollScreen({super.key, this.initialSelectedIndex = 0});
  final int initialSelectedIndex;

  @override
  State<NewRollScreen> createState() => _NewRollScreenState();
}

class _NewRollScreenState extends State<NewRollScreen> {
  // 페이지/카드 세팅
  static const double _viewportFraction = 0.60;
  static const double _sideScale = 0.86;
  static const double _sideOpacityMin = 0.55;
  static const double _sideTranslateY = 14.0;

  static const int _pageCount = 4;
  static const int _loopBase = 10000;
  static const double _paginationBottomMargin = 112.0;

  // 선택된 페이지의 리스트 자동 스크롤 (데모)
  static const int _loopItems = 100000;
  static const double _autoSpeedPxPerTick = 0.7;
  static const Duration _tick = Duration(milliseconds: 16);

  late final PageController _horizontalPageController;
  final Map<int, ScrollController> _verticalCtrls = {};
  int _activeDataIndex = 0;

  Timer? _autoTimer;
  bool _userDraggingVertical = false;

  // 팝 시 잔상 방지용 플래그
  bool _isPopping = false;

  // 페이지별 텍스트
  final List<String> _pageTitles = const [
    'Color Film Roll',
    'Black & White Roll',
    'Vintage Roll',
    'Cinematic Roll',
  ];

  final List<String> _pageDescriptions = const [
    'Capture your moments in vibrant colors.',
    'For timeless, classic black & white shots.',
    'Add nostalgic tones and old-school vibes.',
    'Soft contrast and film-like motion feel.',
  ];

  final List<bool> _isPurchased = [true, false, true, false];
  final Map<int, int> _expSelection = {};

  // 하단 그라데이션 반지름 측정용
  final GlobalKey _markerKey = GlobalKey();
  double _radiusPx = 220.0;

  @override
  void initState() {
    super.initState();

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
      _verticalCtrls[i] = ScrollController(initialScrollOffset: 0.0);
      _expSelection[i] = 24;
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
      final maxExtent = ctrl.position.hasPixels
          ? ctrl.position.maxScrollExtent
          : double.infinity;

      if (next >= maxExtent - 2) {
        ctrl.jumpTo(0.0);
      } else {
        ctrl.jumpTo(next);
      }
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

  // 목업 카드 데이터
  List<Map<String, dynamic>> _mockItems(int page) {
    final palettes = <List<Color>>[
      [
        Colors.pinkAccent.shade100,
        Colors.pink.shade300,
        Colors.pink.shade100,
        Colors.pink.shade400,
        Colors.pink.shade50,
      ],
      [
        Colors.lightBlueAccent.shade100,
        Colors.blue.shade300,
        Colors.blue.shade100,
        Colors.blue.shade400,
        Colors.blue.shade50,
      ],
      [
        Colors.lightGreenAccent.shade100,
        Colors.green.shade300,
        Colors.green.shade100,
        Colors.green.shade400,
        Colors.green.shade50,
      ],
      [
        Colors.amberAccent.shade100,
        Colors.amber.shade300,
        Colors.amber.shade100,
        Colors.amber.shade400,
        Colors.amber.shade50,
      ],
    ];
    final titles = [
      ['Color Film', 'B&W Classic', 'Vintage Mood', 'Cinematic', 'Daily Lite'],
      ['Portra Style', 'Mono High', 'Retro Soft', 'Movie Grain', 'Quick Shot'],
      ['Emerald', 'Forest', 'Mint', 'Olive', 'Lime'],
      ['Sunrise', 'Noon', 'Sunset', 'Golden', 'Dawn'],
    ];
    final colors = palettes[page % palettes.length];
    final names = titles[page % titles.length];
    return List.generate(5, (i) {
      return {
        "title": names[i % names.length],
        "color": colors[i % colors.length],
      };
    });
  }

  Widget _buildVerticalList(BuildContext context, int pageIndex) {
    final items = _mockItems(pageIndex);
    final size = MediaQuery.of(context).size;
    final cardH = size.height * (2 / 3);
    final cardW = size.width * _viewportFraction;

    final ctrl = _verticalCtrls[pageIndex]!;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) => _onScrollNotification(n, pageIndex),
      child: ListView.builder(
        controller: ctrl,
        key: PageStorageKey('list-$pageIndex'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 12, bottom: 12 + _paginationBottomMargin),
        itemCount: _loopItems,
        itemBuilder: (context, index) {
          final data = items[index % items.length];
          return Center(
            child: Container(
              height: cardH,
              width: cardW,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: data["color"] as Color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                data["title"] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
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
          automaticallyImplyLeading: false,
          title: const Text('New Roll'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _popWithFreeze, // ← 팝 시 즉시 동결
            ),
          ],
          backgroundColor: Colors.transparent,
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
    const double kStateRowHeight = 36;
    final theme = Theme.of(context);

    final title = _pageTitles[_activeDataIndex % _pageTitles.length];
    final desc = _pageDescriptions[_activeDataIndex % _pageDescriptions.length];
    final purchased = _isPurchased[_activeDataIndex];
    final exp = _expSelection[_activeDataIndex] ?? 24;

    Widget stateArea;
    if (purchased) {
      stateArea = SizedBox(
        height: kStateRowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('EXP', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: SizedBox(
                  height: kStateRowHeight - 8,
                  child: DropdownButton<int>(
                    isDense: true,
                    value: exp,
                    dropdownColor: Colors.black87,
                    iconEnabledColor: Colors.white,
                    iconSize: 18,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.1,
                    ),
                    items: const [
                      DropdownMenuItem(value: 12, child: Text('12')),
                      DropdownMenuItem(value: 24, child: Text('24')),
                      DropdownMenuItem(value: 36, child: Text('36')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _expSelection[_activeDataIndex] = v);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      stateArea = SizedBox(
        height: kStateRowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: const Text(
                'Already purchased?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            const Text('|', style: TextStyle(color: Colors.white54)),
            const SizedBox(width: 6),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: const Text(
                'Legal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final ctaLabel = purchased ? 'Create' : 'Purchase';

    Widget fadeSwitcher(Text child, String keyId) {
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
          key: ValueKey('$keyId-${child.data}'),
          child: child,
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(key: _markerKey, height: 0),
            fadeSwitcher(
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              'title',
            ),
            const SizedBox(height: 8),
            fadeSwitcher(
              Text(
                desc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              'desc',
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: KeyedSubtree(
                key: ValueKey('state-$purchased-$_activeDataIndex'),
                child: stateArea,
              ),
            ),
            const SizedBox(height: 18),
            // CTA 버튼 (Hero 유지)
            Hero(
              tag: 'hero-cta',
              flightShuttleBuilder: _materialShuttle,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (!purchased) {
                      _pushSeamless(
                        context,
                        NewRollCreateScreen(
                          rollTitle: title,
                          exp: 24,
                          ctaLabel: 'Purchase',
                        ),
                      );
                      return;
                    }
                    _pushSeamless(
                      context,
                      NewRollCreateScreen(
                        rollTitle: title,
                        exp: exp,
                        ctaLabel: 'Create',
                      ),
                    );
                  },
                  child: Text(
                    ctaLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
  Widget _bottomCircularGradient() {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: _BottomCircleGradientPainter(
          radiusPx: _radiusPx,
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 0.75, 1.0],
        ),
        size: Size.infinite,
      ),
    );
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
            return _decorateForIndex(
              index: realIndex,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: page,
              ),
            );
          },
        );
      },
    );

    // ✨ 잔상 방지 레이어: 팝 시 즉시 동결 + 그리기 경계 분리
    final Widget frozenLayer = ClipRect(
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
      resizeToAvoidBottomInset: true,
      appBar: _buildHeroAppBar(), // Hero 유지
      body: Stack(
        children: [
          frozenLayer, // 동결 가능한 메인 컨텐츠
          Positioned.fill(child: _bottomCircularGradient()),
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
