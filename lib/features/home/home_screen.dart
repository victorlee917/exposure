// lib/features/home/home.dart
import 'dart:async';
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:daily_exposures/features/create/new_roll_screen.dart';
import 'package:daily_exposures/features/home/widgets/capture_button.dart';
import 'package:daily_exposures/features/home/widgets/film_roll_view.dart';
import 'package:daily_exposures/features/my/my_screen.dart';
import 'package:daily_exposures/features/capture/capture_picture_screen.dart';
import 'package:daily_exposures/features/capture/capture_music_screen.dart';
import 'package:daily_exposures/features/capture/capture_movie_screen.dart';
import 'package:daily_exposures/features/detail/film_roll_detail_screen.dart';
import 'package:daily_exposures/database/provider.dart';
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class FilmRollDetail {
  final int id;
  final String title;
  final String? description;
  final int totalExposure;
  final String type; // vertical_picture / music / movie
  final int currentExposure;
  final bool developedYn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double imageRatio;

  FilmRollDetail({
    required this.id,
    required this.title,
    this.description,
    required this.totalExposure,
    required this.type,
    required this.currentExposure,
    required this.developedYn,
    required this.createdAt,
    required this.updatedAt,
    required this.imageRatio,
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

  List<FilmRollDetail> _filmRollDetails = [];
  bool _isLoading = true;
  int get filmRollCount => _filmRollDetails.length;

  @override
  void initState() {
    super.initState();

    // Initialize controllers first
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

    // Load data after controllers are initialized
    _loadFilmRolls();
  }

  Future<void> _loadFilmRolls() async {
    final userRolls = await database.select(database.userFilmRolls).get();

    // Load Roll templates to get imageRatio for each type
    final rolls = await database.select(database.rolls).get();
    final rollMap = {for (var roll in rolls) roll.type: roll};

    if (!mounted) return;

    // Initialize scroll controllers for each roll
    for (int i = 0; i < userRolls.length; i++) {
      _scrollOffsets[i] = 0.0;
      _scrollControllers[i] = ScrollController()
        ..addListener(() {
          if (mounted) {
            setState(() {
              _scrollOffsets[i] = _scrollControllers[i]!.offset;
            });
          }
        });
    }

    setState(() {
      _filmRollDetails = userRolls.map((roll) {
        final rollTemplate = rollMap[roll.type];
        final imageRatio = rollTemplate?.imageRatio ?? 1.5; // Default to 3/2 if not found

        return FilmRollDetail(
          id: roll.id,
          title: roll.title,
          description: roll.description,
          totalExposure: roll.totalExposure,
          type: roll.type,
          currentExposure: roll.currentExposure,
          developedYn: roll.developedYn,
          createdAt: roll.createdAt,
          updatedAt: roll.updatedAt,
          imageRatio: imageRatio,
        );
      }).toList();
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _updateButtonFade();

      for (int i = 0; i < _filmRollDetails.length; i++) {
        final detail = _filmRollDetails[i];
        if (!detail.developedYn && detail.currentExposure < detail.totalExposure) {
          if (_scrollControllers[i]?.hasClients ?? false) {
            final screenWidth = MediaQuery.of(context).size.width;
            const horizontalPadding = 16.0;
            final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);
            final cardHeight = cardWidth * detail.imageRatio;
            final initialOffset = detail.currentExposure * cardHeight;
            _scrollControllers[i]?.jumpTo(initialOffset);
          }
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
    if (_filmRollDetails.isEmpty || filmRollCount == 0) return;

    final active = _currentPage.round().clamp(0, filmRollCount - 1);
    final detail = _filmRollDetails[active];
    final shouldShow = (!detail.developedYn) && _isNavigatorIdle;

    if (shouldShow) {
      _btnFadeCtrl.forward();
    } else {
      _btnFadeCtrl.reverse();
    }
    setState(() {});
  }

  void _animateToDraftPage(int rollIndex) {
    if (rollIndex >= _filmRollDetails.length) return;

    final detail = _filmRollDetails[rollIndex];

    final screenWidth = MediaQuery.of(context).size.width;

    const horizontalPadding = 16.0;

    final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);

    final cardHeight = cardWidth * detail.imageRatio;

    final targetOffset = detail.currentExposure * cardHeight;

    _scrollControllers[rollIndex]?.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openCaptureForRoll(int activeRollIndex) {
    if (activeRollIndex >= _filmRollDetails.length) return;

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

  void _onCardTap(int rollIndex, int itemIndex, Object heroTag) {
    if (rollIndex >= _filmRollDetails.length) return;

    final detail = _filmRollDetails[rollIndex];
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: Duration.zero,
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FilmRollDetailScreen(
            rollTitle: detail.title,
            rollIndex: rollIndex,
            itemIndex: itemIndex,
            itemCount: detail.totalExposure,
            type: detail.type,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exposure'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 빈 상태일 때는 기본값 사용
    final activeRollIndex = filmRollCount > 0
        ? _currentPage.round().clamp(0, filmRollCount - 1)
        : 0;

    final detail = filmRollCount > 0 ? _filmRollDetails[activeRollIndex] : null;

    final scrollOffset = _scrollOffsets[activeRollIndex] ?? 0.0;

    final bool showRollTitleInAppBar = filmRollCount > 0 && scrollOffset > 100;

    final String rollTitle = detail?.title ?? 'Exposure';

    // 하단 버튼
    Widget? bottomButton;

    if (detail != null && !detail.developedYn) {
      final screenWidth = MediaQuery.of(context).size.width;

      final screenHeight = MediaQuery.of(context).size.height;

      const horizontalPadding = 16.0;

      final cardWidth = (screenWidth * 0.65) - (horizontalPadding * 2);

      final cardHeight = cardWidth * detail.imageRatio;

      final viewportHeight = screenHeight - kToolbarHeight; // Approximate

      final firstVisible = scrollOffset / cardHeight;

      final lastVisible = (scrollOffset + viewportHeight) / cardHeight;

      final isDraftVisible =
          detail.currentExposure >= firstVisible && detail.currentExposure <= lastVisible;

      final bool showDevelopLabel =
          (!detail.developedYn) && (detail.currentExposure >= detail.totalExposure);

      IconData icon;

      VoidCallback onPressed;

      if (detail.currentExposure >= detail.totalExposure) {
        icon = FontAwesomeIcons.check;

        onPressed = () => {};
      } else if (isDraftVisible) {
        icon = FontAwesomeIcons.camera;

        onPressed = () => _openCaptureForRoll(activeRollIndex);
      } else if (firstVisible > detail.currentExposure) {
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
              if (filmRollCount > 0)
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
                          isDeveloped: d.developedYn,
                          filmRollDetails: {
                            "started": d.createdAt.toString().split(' ')[0],
                            "ended": d.updatedAt.toString().split(' ')[0],
                            "developed": d.developedYn ? d.updatedAt.toString().split(' ')[0] : "Not yet",
                            "type": d.type,
                          },
                          itemCount: d.totalExposure,
                          shareIcon: null,
                          draftPage: d.currentExposure,
                          onCardTap: (itemIndex, heroTag) {
                            _onCardTap(rollIndex, itemIndex, heroTag);
                          },
                          type: d.type,
                          title: d.title,
                          description: d.description,
                          imageRatio: d.imageRatio,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 빈 상태 안내
              if (filmRollCount == 0 && !_isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_album_outlined,
                        size: 64,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Film Rolls Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first roll to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

              // 하단 버튼
              if (filmRollCount > 0)
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
                          d.developedYn ||
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
