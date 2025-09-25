import 'dart:math' as math;
import 'package:flutter/material.dart';

class NewRollCreateScreen extends StatefulWidget {
  const NewRollCreateScreen({
    super.key,
    required this.rollTitle,
    required this.exp,
    required this.ctaLabel,
  });

  final String rollTitle;
  final int exp;
  final String ctaLabel;

  @override
  State<NewRollCreateScreen> createState() => _NewRollCreateScreenState();
}

class _NewRollCreateScreenState extends State<NewRollCreateScreen> {
  final _titleCtl = TextEditingController();
  final _subtitleCtl = TextEditingController();
  final _titleFocus = FocusNode();
  final _subtitleFocus = FocusNode();

  // EXP 툴팁용
  final GlobalKey _expBadgeKey = GlobalKey();
  OverlayEntry? _tooltipEntry;

  // 간격
  static const double _kGapNoKeyboard = 32.0; // 키보드 없을 때
  static const double _kGapKeyboard = 16.0; // 키보드 있을 때
  static const Duration _kAnim = Duration(milliseconds: 140);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _removeTooltip();
    _titleCtl.dispose();
    _subtitleCtl.dispose();
    _titleFocus.dispose();
    _subtitleFocus.dispose();
    super.dispose();
  }

  void _handleCreate() {
    Navigator.of(context).maybePop();
  }

  // ── AppBar (Hero) ───────────────────────────────
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
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  // ── Tooltip Overlay (플로팅, 자동 dismiss 없음, X/바깥탭으로 닫힘) ──
  void _showTooltip() {
    _removeTooltip();

    final overlay = Overlay.of(context);

    final renderBox =
        _expBadgeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final mq = MediaQuery.of(context);
    final screenSize = mq.size;

    // 앵커
    final anchorTopLeft = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;

    // 화면 패딩(노치/인디케이터) 고려한 마진
    final double marginLeft = math.max(16, mq.padding.left + 8);
    final double marginRight = math.max(16, mq.padding.right + 8);
    final double maxWidth = screenSize.width - marginLeft - marginRight;

    // 툴팁 좌표 (칩 아래 6px)
    final double tipTop = anchorTopLeft.dy + anchorSize.height + 6;
    final double tipCenterX = anchorTopLeft.dx + anchorSize.width / 2;

    // 가운데 정렬을 기본으로 좌우 클램프
    double tipLeft = tipCenterX - (maxWidth / 2);
    tipLeft = tipLeft.clamp(
      marginLeft,
      screenSize.width - marginRight - maxWidth,
    );

    _tooltipEntry = OverlayEntry(
      builder: (ctx) {
        // 바깥 탭 닫힘을 위해 전체 스택
        return Stack(
          children: [
            // 바깥 영역 탭 → 닫기
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeTooltip,
              ),
            ),
            // 툴팁 (플로팅, 패딩 내 클램프)
            Positioned(
              top: tipTop,
              left: tipLeft,
              width: maxWidth,
              child: _TooltipBubble(
                text: 'Developing requires ${widget.exp} Moments.',
                onClose: _removeTooltip,
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_tooltipEntry!);
    // ⛔️ 자동 dismiss 없음 (요청사항)
  }

  void _removeTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 버튼을 직접 배치
      appBar: _buildHeroAppBar(),
      body: Builder(
        builder: (rootCtx) {
          final mq = MediaQuery.of(rootCtx);
          final double kb = mq.viewInsets.bottom;
          final double safe = mq.viewPadding.bottom;

          final double buttonBottom = (kb > 0)
              ? (kb + _kGapKeyboard)
              : (safe + _kGapNoKeyboard);

          return Stack(
            children: [
              // ===== 본문 =====
              Positioned.fill(
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더: Roll 제목 + EXP 배지(안에 인포 아이콘)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.rollTitle,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              key: _expBadgeKey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${widget.exp} EXP',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 6),
                                  // 칩 안쪽 info 아이콘
                                  InkResponse(
                                    radius: 14,
                                    onTap: _showTooltip,
                                    child: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        // Title
                        TextField(
                          autocorrect: false,
                          controller: _titleCtl,
                          focusNode: _titleFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _subtitleFocus.requestFocus(),
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        TextField(
                          autocorrect: false,
                          controller: _subtitleCtl,
                          focusNode: _subtitleFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleCreate(),
                          decoration: const InputDecoration(
                            labelText: 'Subtitle',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 400),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== CTA 버튼 =====
              AnimatedPositioned(
                duration: _kAnim,
                curve: Curves.easeOutCubic,
                left: 20,
                right: 20,
                bottom: buttonBottom,
                child: Hero(
                  tag: 'hero-cta',
                  flightShuttleBuilder: _materialShuttle,
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _handleCreate,
                      child: Text(
                        widget.ctaLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
}

// ── 플로팅 툴팁 버블(오버레이용) ─────────────────────────
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // 오버레이 안에서도 자체 탭은 바깥으로 전파되지 않도록 처리
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {}, // 내부 탭 흡수
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xEE222222),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 안내 텍스트 (길면 줄바꿈)
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, height: 1.25),
                  ),
                ),
                const SizedBox(width: 8),
                // 닫기(X)
                InkResponse(
                  onTap: onClose,
                  radius: 16,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
