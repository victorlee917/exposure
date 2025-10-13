// lib/features/home/home.dart
import 'dart:async';
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:daily_exposures/features/create/new_roll_screen.dart';
import 'package:daily_exposures/features/home/widgets/capture_button.dart';
import 'package:daily_exposures/features/home/widgets/film_roll_view.dart';
import 'package:daily_exposures/features/home/widgets/item_navigator.dart';
import 'package:daily_exposures/features/my/my_screen.dart';
import 'package:daily_exposures/features/capture/capture_picture_screen.dart';
import 'package:daily_exposures/features/capture/capture_music_screen.dart';
import 'package:daily_exposures/features/capture/capture_movie_screen.dart';
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class FilmRollDetail {
  final String started;
  final String ended;
  final String developedAt;
  final String type; // picture_vertical / music / movie
  bool isDeveloped;
  int draftPage; // undeveloped 롤의 다음 컷(0-based)

  FilmRollDetail({
    required this.started,
    required this.ended,
    required this.developedAt,
    required this.type,
    required this.isDeveloped,
    this.draftPage = 6,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Home
// ─────────────────────────────────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  // ---------- 공통 애니메이션 파라미터 ----------
  static const _durFwd = Duration(milliseconds: 320);
  static const _durRev = Duration(milliseconds: 300);
  static final _curve = Curves.easeOutCubic;
  static final _revCurve = Curves.easeInCubic;

  // ← 왼쪽에서 들어오기
  Route<T> _pushFromLeft<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: _durFwd,
      reverseTransitionDuration: _durRev,
      opaque: true,
      barrierColor: Colors.transparent,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: _curve,
          reverseCurve: _revCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // → 오른쪽에서 들어오기
  Route<T> _pushFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: _durFwd,
      reverseTransitionDuration: _durRev,
      opaque: true,
      barrierColor: Colors.transparent,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: _curve,
          reverseCurve: _revCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // 아래→위 모달(캡처 화면)
  Route<T> _presentFromBottomModal<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: _durFwd,
      reverseTransitionDuration: _durRev,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: _curve,
          reverseCurve: _revCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  // ---------- 상태/컨트롤러 ----------
  late PageController _horizontalPageController;
  double _currentPage = 0.0;

  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, double> _scrollOffsets = {};

  Timer? _navigatorIdleDebounce;
  bool _isNavigatorIdle = true;

  late final AnimationController _btnFadeCtrl;
  late final Animation<double> _btnFade;

  AnimationController? _scrollAnimCtrl;

  final int _itemCount = 12;
  final int filmRollCount = 3;

  final List<FilmRollDetail> _filmRollDetails = [
    FilmRollDetail(
      started: "2023-01-01",
      ended: "2023-01-15",
      developedAt: "2023-01-20",
      type: "picture_vertical",
      isDeveloped: true,
      draftPage: 12,
    ),
    FilmRollDetail(
      started: "2023-02-01",
      ended: "In progress",
      developedAt: "Not yet",
      type: "picture_vertical",
      isDeveloped: false,
      draftPage: 6,
    ),
    FilmRollDetail(
      started: "2023-03-01",
      ended: "2023-03-10",
      developedAt: "2023-03-12",
      type: "movie",
      isDeveloped: true,
      draftPage: 12,
    ),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _filmRollDetails.length; i++) {
      _scrollOffsets[i] = 0.0;
      _scrollControllers[i] = ScrollController()
        ..addListener(() {
          setState(() {
            _scrollOffsets[i] = _scrollControllers[i]!.offset;
          });
        });
    }

    _horizontalPageController = PageController(viewportFraction: 0.65)
      ..addListener(() {
        if (_horizontalPageController.hasClients) {
          setState(() => _currentPage = _horizontalPageController.page ?? 0.0);
        }
        _updateButtonFade();
      });

    _btnFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _btnFade = CurvedAnimation(
      parent: _btnFadeCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonFade();
      for (int i = 0; i < _filmRollDetails.length; i++) {
        final detail = _filmRollDetails[i];
        if (!detail.isDeveloped && detail.draftPage < _itemCount) {
          final screenWidth = MediaQuery.of(context).size.width;
          const horizontalPadding = 16.0;
          final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);
          final cardHeight = cardWidth * 3 / 2;
          final initialOffset = detail.draftPage * cardHeight;
          _scrollControllers[i]?.jumpTo(initialOffset);
        }
      }
    });
  }

  @override
  void dispose() {
    _navigatorIdleDebounce?.cancel();
    _btnFadeCtrl.dispose();
    _scrollAnimCtrl?.dispose();
    _horizontalPageController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    _scrollControllers.clear();
    super.dispose();
  }

  // 버튼 표시 조건 업데이트
  void _updateButtonFade() {
    final active = _currentPage.round().clamp(0, filmRollCount - 1);
    if (_filmRollDetails.isEmpty) return;
    final detail = _filmRollDetails[active];
    final shouldShow = (!detail.isDeveloped) && _isNavigatorIdle;

    if (shouldShow) {
      _btnFadeCtrl.forward();
    } else {
      _btnFadeCtrl.reverse();
    }
    setState(() {});
  }

  void _animateToDraftPage(int rollIndex) {
    final detail = _filmRollDetails[rollIndex];

    final screenWidth = MediaQuery.of(context).size.width;

    const horizontalPadding = 16.0;

    final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);

    final cardHeight = cardWidth * 3 / 2;

    final targetOffset = detail.draftPage * cardHeight;

    _scrollControllers[rollIndex]?.animateTo(
      targetOffset,

      duration: const Duration(milliseconds: 500),

      curve: Curves.easeInOut,
    );
  }

  void _openCaptureForRoll(int activeRollIndex) {
    final type = _filmRollDetails[activeRollIndex].type;

    Widget page;

    switch (type) {
      case 'picture_vertical':
        page = const CapturePictureScreen();

        break;

      case 'music':
        page = const CaptureMusicScreen();

        break;

      case 'movie':
        page = const CaptureMovieScreen();

        break;

      default:
        page = const CapturePictureScreen();
    }

    Navigator.of(context).push(_presentFromBottomModal(page));
  }

  @override
  Widget build(BuildContext context) {
    final activeRollIndex = _currentPage.round().clamp(0, filmRollCount - 1);

    final detail = _filmRollDetails[activeRollIndex];

    final scrollOffset = _scrollOffsets[activeRollIndex] ?? 0.0;

    final bool showRollTitleInAppBar = scrollOffset > 100;

    final String rollTitle = 'Film Roll ${activeRollIndex + 1}';

    final horizontalScrollProgress = (_currentPage - _currentPage.round())
        .abs();

    final bottomNavOpacity = (1 - horizontalScrollProgress * 5).clamp(0.0, 1.0);

    // 하단 버튼

    Widget? bottomButton;

    if (!detail.isDeveloped) {
      final screenWidth = MediaQuery.of(context).size.width;

      final screenHeight = MediaQuery.of(context).size.height;

      const horizontalPadding = 16.0;

      final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);

      final cardHeight = cardWidth * 3 / 2;

      final viewportHeight = screenHeight - kToolbarHeight; // Approximate

      final firstVisible = scrollOffset / cardHeight;

      final lastVisible = (scrollOffset + viewportHeight) / cardHeight;

      final isDraftVisible =
          detail.draftPage >= firstVisible && detail.draftPage <= lastVisible;

      final bool showDevelopLabel =
          (!detail.isDeveloped) && (detail.draftPage >= _itemCount);

      IconData icon;

      VoidCallback onPressed;

      if (detail.draftPage >= _itemCount) {
        icon = FontAwesomeIcons.check;

        onPressed = () => {};
      } else if (isDraftVisible) {
        icon = FontAwesomeIcons.camera;

        onPressed = () => _openCaptureForRoll(activeRollIndex);
      } else if (firstVisible > detail.draftPage) {
        icon = FontAwesomeIcons.arrowUp;

        onPressed = () => _animateToDraftPage(activeRollIndex);
      } else {
        icon = FontAwesomeIcons.arrowDown;

        onPressed = () => _animateToDraftPage(activeRollIndex);
      }

      bottomButton = CaptureButton(
        icon: icon,

        label: showDevelopLabel ? 'Develop' : 'Capture Moment',

        onPressed: onPressed,
      );
    }

    return ValueListenableBuilder(
      valueListenable: isLeftHandedMode,
      builder: (context, isLeft, child) {
        return Scaffold(
          extendBodyBehindAppBar: false, // AppBar는 항상 보이도록
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.film,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(_pushFromLeft(const NewRollScreen()));
                },
              ),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: showRollTitleInAppBar
                    ? Text(
                        rollTitle,
                        key: ValueKey(rollTitle),
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      )
                    : Text(
                        'Exposure',
                        key: const ValueKey('Exposure'),
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.bars,
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                  ),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(_pushFromRight(const MyScreen()));
                  },
                ),
              ],
            ),
          ),
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              // 컨텐츠
              PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _horizontalPageController,
                itemCount: filmRollCount,
                clipBehavior: Clip.none,
                itemBuilder: (context, rollIndex) {
                  final scrollController = _scrollControllers[rollIndex]!;
                  final d = _filmRollDetails[rollIndex];

                  return GestureDetector(
                    onTap: () {
                      if (rollIndex != _currentPage.round()) {
                        _horizontalPageController.animateToPage(
                          rollIndex,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: IgnorePointer(
                      ignoring: rollIndex != _currentPage.round(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: FilmRollView(
                          rollIndex: rollIndex,
                          currentPage: _currentPage,
                          horizontalPageController: _horizontalPageController,
                          scrollController: scrollController,
                          isDeveloped: d.isDeveloped,
                          filmRollDetails: {
                            "started": d.started,
                            "ended": d.ended,
                            "developed": d.developedAt,
                          },
                          itemCount: _itemCount,
                          shareIcon: null,
                          draftPage: d.draftPage,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 하단 버튼
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: AnimatedBuilder(
                  animation: _btnFadeCtrl,
                  builder: (_, __) {
                    final active = _currentPage.round().clamp(
                      0,
                      filmRollCount - 1,
                    );
                    final d = _filmRollDetails[active];
                    final ignoring =
                        d.isDeveloped ||
                        _btnFadeCtrl.value <= 0.001 ||
                        !_isNavigatorIdle;

                    return IgnorePointer(
                      ignoring: ignoring,
                      child: FadeTransition(
                        opacity: _btnFade,
                        child: Center(child: bottomButton ?? const SizedBox()),
                      ),
                    );
                  },
                ),
              ),

              // AppBar 아래 그라데이션 (항상 표시)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppbarGradation(
                  height: 40,
                  useThemeBg: true, // 검정 → 투명
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
