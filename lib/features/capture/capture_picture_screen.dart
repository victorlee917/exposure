// lib/features/capture/capture_picture_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

// ⬇️ 변경: CaptionScreen + CaptureOrigin 불러오기
import 'caption_screen.dart';
import 'capture_origin.dart'; // PhotoOrigin 사용

class CapturePictureScreen extends StatefulWidget {
  const CapturePictureScreen({super.key});

  @override
  State<CapturePictureScreen> createState() => _CapturePictureScreenState();
}

class _CapturePictureScreenState extends State<CapturePictureScreen>
    with SingleTickerProviderStateMixin {
  // 사진 데이터
  List<AssetEntity> _assets = [];
  AssetEntity? _selected;

  // 로딩/에러
  bool _loading = true;
  String? _error;

  // 시트 진행도 컨트롤러 (0=기본, 1=확장)
  late final AnimationController _sheetCtrl;

  // ── 상단 드래그 띠 제스처 상태 ──────────────────────────────────────────
  static const double _kTopDragBand = 56.0; // 드래그 히트영역 높이
  double _dragStartVal = 0.0; // 드래그 시작 시 시트 값(0..1)
  double _dragStartDy = 0.0; // 드래그 시작 global Y
  bool _draggingTopBand = false;

  // 그리드 스크롤 기반 전환(맨 위에서만 토글)
  final ScrollController _gridCtrl = ScrollController();
  double _gridDragAccum = 0.0;
  bool _gridDragging = false;
  static const double _kToggleThreshold = 60.0; // 전환 임계 픽셀

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      value: 0.0, // 기본 상태(미확장)
      duration: const Duration(milliseconds: 220),
    );
    _load();
  }

  @override
  void dispose() {
    _gridCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final p = await PhotoManager.requestPermissionExtend();
    if (!p.hasAccess) {
      setState(() {
        _loading = false;
        _error = 'Photos permission is required.';
      });
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
      onlyAll: true,
    );
    if (paths.isEmpty) {
      setState(() {
        _assets = [];
        _selected = null;
        _loading = false;
      });
      return;
    }

    final recent = paths.first;
    final assets = await recent.getAssetListRange(start: 0, end: 400);

    setState(() {
      _assets = assets;
      _selected = assets.isNotEmpty ? assets.first : null;
      _loading = false;
    });
  }

  bool get _expanded => _sheetCtrl.value >= 0.5;

  // ── 상단 드래그 띠 제스처: 손가락 이동 = 시트 값 즉시 반영 ────────────────
  void _onTopDragStart(DragStartDetails d) {
    setState(() {
      _draggingTopBand = true;
      _dragStartVal = _sheetCtrl.value;
      _dragStartDy = d.globalPosition.dy;
    });
    _sheetCtrl.stop();
  }

  void _onTopDragUpdate(DragUpdateDetails d) {
    final mq = MediaQuery.of(context);
    final double previewH = mq.size.height * 0.40; // 기본↔확장 사이 유효 높이
    if (previewH <= 0) return;

    final double deltaY = _dragStartDy - d.globalPosition.dy; // 위로 양수
    final double nextVal = (_dragStartVal + (deltaY / previewH)).clamp(
      0.0,
      1.0,
    );

    // 즉시 반영 → 손가락과 1:1로 동기화
    _sheetCtrl.value = nextVal;
  }

  void _onTopDragEnd(DragEndDetails d) async {
    final mq = MediaQuery.of(context);
    final double previewH = mq.size.height * 0.40;
    if (previewH <= 0) {
      setState(() {
        _draggingTopBand = false;
      });
      return;
    }

    // 속도 기반 + 위치 기반 스냅
    final double vy = -d.velocity.pixelsPerSecond.dy; // 위로 양수
    final double vValue = vy / previewH;

    final bool goExpand = vValue > 2.0
        ? true
        : (vValue < -2.0 ? false : (_sheetCtrl.value >= 0.5));
    final target = goExpand ? 1.0 : 0.0;

    if ((goExpand && !_expanded) || (!goExpand && _expanded)) {
      HapticFeedback.selectionClick();
    }

    // 더 ‘쫀득’한 스냅
    final int ms = (200 - (vValue.abs() * 80)).clamp(120, 260).toInt();

    setState(() {
      _draggingTopBand = false; // 드래그 종료 즉시 UI 갱신
    });

    await _sheetCtrl.animateTo(
      target,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
    );
  }

  // ── 그리드 스크롤로 상태 전환(맨 위에서만) ───────────────────────────────
  void _onGridScrollStart() {
    if (_draggingTopBand) return; // 상단 드래그 중이면 무시
    _gridDragging = true;
    _gridDragAccum = 0.0;
  }

  void _onGridScrollUpdate(double? delta, ScrollMetrics metrics) {
    if (_draggingTopBand || !_gridDragging || delta == null) return;

    // 그리드가 맨 위일 때만 전환 허용
    final atTop = metrics.pixels <= metrics.minScrollExtent + 0.5;
    if (!atTop) {
      _gridDragAccum = 0.0;
      return;
    }

    _gridDragAccum += delta; // 위로 스와이프: delta가 +, 아래로: -

    if (!_expanded && _gridDragAccum >= _kToggleThreshold) {
      _gridDragging = false;
      _gridDragAccum = 0.0;
      HapticFeedback.selectionClick();
      _sheetCtrl.animateTo(1.0, curve: Curves.easeOutCubic);
    } else if (_expanded && _gridDragAccum <= -_kToggleThreshold) {
      _gridDragging = false;
      _gridDragAccum = 0.0;
      HapticFeedback.selectionClick();
      _sheetCtrl.animateTo(0.0, curve: Curves.easeOutCubic);
    }
  }

  void _onGridScrollEnd() {
    if (_draggingTopBand) return;
    _gridDragging = false;
    _gridDragAccum = 0.0;
  }

  // ⬇️ NEXT: CaptionScreen으로 자연스러운 전환(앱바/썸네일 이어짐)
  void _goToCaption() {
    if (_selected == null) return;
    Navigator.of(context).push(
      _CaptionRoute(
        // ⬇️ 변경: CaptionScreen에 PhotoOrigin 전달
        child: CaptionScreen(origin: PhotoOrigin(_selected!)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double screenW = mq.size.width;
    final double screenH = mq.size.height;
    final double appBarH = 0; // Positioned 기준으로 0부터 시작
    final double previewH = screenH * 0.40;

    // 시트 top: 기본(previewH) ↔ 확장(0) 보간
    final double sheetTopDefault = appBarH + previewH;
    final double sheetTopExpanded = appBarH;

    final heroAppBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Hero(
        tag: 'appbar-hero',
        // flight에서 AppBar 안의 텍스트 재레이아웃 방지를 위해 Material 감싸기
        child: Material(
          color: Colors.black,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('Capture'), // CaptionScreen과 동일
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _selected == null ? null : _goToCaption,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: heroAppBar,
      body: Stack(
        children: [
          // ── 썸네일( AppBar 아래 40% ) ────────────────────────────────────
          Positioned(
            top: appBarH,
            left: 0,
            right: 0,
            height: previewH,
            child: _Preview2by3(entity: _selected, containerWidth: screenW),
          ),

          // ── 사진 선택 시트 ────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _sheetCtrl,
            builder: (context, _) {
              final double sheetTop = _lerpDouble(
                sheetTopDefault,
                sheetTopExpanded,
                _sheetCtrl.value,
              );
              return Positioned(
                top: sheetTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: _PickerSheet(
                  controller: _gridCtrl,
                  assets: _assets,
                  selected: _selected,
                  onPick: (e) {
                    setState(() => _selected = e);
                    // 확장 상태에서 선택 시 기본 상태로 복귀
                    if (_expanded) {
                      HapticFeedback.selectionClick();
                      _sheetCtrl.animateTo(0.0, curve: Curves.easeOutCubic);
                    }
                  },
                  // 상단 드래그 띠(핸들 포함)
                  topBand: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: _onTopDragStart,
                    onVerticalDragUpdate: _onTopDragUpdate,
                    onVerticalDragEnd: _onTopDragEnd,
                    child: SizedBox(
                      height: _kTopDragBand,
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onScrollStart: _onGridScrollStart,
                  onScrollUpdate: _onGridScrollUpdate,
                  onScrollEnd: _onGridScrollEnd,
                  // 드래그 중 그리드 입력 차단
                  ignoringGrid: _draggingTopBand,
                ),
              );
            },
          ),

          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (!_loading && _error != null)
            Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}

/// 상단 프리뷰: 2:3(가로:세로), 위/아래 16 마진, 모서리 6
class _Preview2by3 extends StatelessWidget {
  const _Preview2by3({required this.entity, required this.containerWidth});

  final AssetEntity? entity;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    if (entity == null) return const ColoredBox(color: Colors.black);

    // ⬇️ 썸네일 Hero: CaptionScreen과 이어짐
    final heroTag = 'preview-${entity!.id}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, c) {
          final double h = c.maxHeight;
          final double frameW = h * (2 / 3);

          return Center(
            child: Hero(
              tag: heroTag,
              // Hero 내에 Material을 끼워 넣어 anti-aliasing 및 elevation 이슈 방지
              child: Material(
                type: MaterialType.transparency,
                child: SizedBox(
                  width: frameW,
                  height: h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: frameW,
                        height: h,
                        child: AssetEntityImage(
                          entity!,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize(1500, 1500),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 사진 선택 시트(상단 드래그 띠 + 그리드)
class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.controller,
    required this.assets,
    required this.selected,
    required this.onPick,
    required this.topBand,
    required this.onScrollStart,
    required this.onScrollUpdate,
    required this.onScrollEnd,
    required this.ignoringGrid,
  });

  final ScrollController controller;
  final List<AssetEntity> assets;
  final AssetEntity? selected;
  final ValueChanged<AssetEntity> onPick;

  final Widget topBand;

  final VoidCallback onScrollStart;
  final void Function(double? delta, ScrollMetrics metrics) onScrollUpdate;
  final VoidCallback onScrollEnd;

  final bool ignoringGrid;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          topBand,
          Expanded(
            child: IgnorePointer(
              ignoring: ignoringGrid, // 핸들 드래그 중 그리드 이벤트 차단
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollStartNotification) {
                    onScrollStart();
                  } else if (n is ScrollUpdateNotification) {
                    onScrollUpdate(n.scrollDelta, n.metrics);
                  } else if (n is ScrollEndNotification) {
                    onScrollEnd();
                  }
                  return false; // 그리드 기본 스크롤 유지
                },
                child: assets.isEmpty
                    ? const Center(
                        child: Text(
                          'No photos',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        controller: controller,
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                        itemCount: assets.length,
                        itemBuilder: (context, i) {
                          final a = assets[i];
                          final isSel = selected?.id == a.id;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onPick(a),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AssetEntityImage(
                                  a,
                                  isOriginal: false,
                                  thumbnailSize: const ThumbnailSize(600, 600),
                                  fit: BoxFit.cover,
                                ),
                                if (isSel)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFB388FF),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _lerpDouble(double a, double b, double t) =>
    a + (b - a) * t.clamp(0.0, 1.0);

// 커스텀 전환: Hero가 AppBar/썸네일을 이어주고, 나머지는 은은히 페이드+살짝 스케일
class _CaptionRoute<T> extends PageRouteBuilder<T> {
  _CaptionRoute({required Widget child})
    : super(
        pageBuilder: (_, __, ___) => child,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );

  @override
  bool get opaque => true;
}
