import 'dart:math' as math;
import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/common/widgets/primary_text_field.dart';
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

  int _selectedExposure = 12;

  // EXP 툴팁용
  final GlobalKey _expBadgeKey = GlobalKey();
  final GlobalKey _exposureInfoKey = GlobalKey();
  OverlayEntry? _tooltipEntry;

  // 간격
  static const double _kGapNoKeyboard = 32.0; // 키보드 없을 때
  static const double _kGapKeyboard = Paddings.screentHorizontal; // 키보드 있을 때
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
          title: Text(widget.rollTitle),
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
  void _showTooltip(GlobalKey anchorKey, String text) {
    _removeTooltip();

    final overlay = Overlay.of(context);

    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
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
              child: _TooltipBubble(text: text, onClose: _removeTooltip),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                        // Exposure selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Exposure',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                InkResponse(
                                  key: _exposureInfoKey,
                                  radius: 14,
                                  onTap: () => _showTooltip(
                                    _exposureInfoKey,
                                    'Developing requires ${widget.exp} Moments.',
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Paddings.buttonHorizontal,
                                vertical: Paddings.buttonVertical,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Rvalues.button,
                                ),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Borders.lineColorDark
                                      : Borders.lineColorLight,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedExposure,
                                items: [12, 24, 36].map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedExposure = newValue!;
                                  });
                                },
                                underline: Container(), // Remove underline
                                icon: const Icon(Icons.arrow_drop_down),
                                style: Theme.of(context).textTheme.bodyMedium,
                                dropdownColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Title
                        PrimaryTextField(
                          controller: _titleCtl,
                          focusNode: _titleFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _subtitleFocus.requestFocus(),
                          labelText: 'Title',
                          hintText: "Enter the Title",
                          border: const OutlineInputBorder(),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        PrimaryTextField(
                          controller: _subtitleCtl,
                          focusNode: _subtitleFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleCreate(),
                          labelText: 'Subtitle',
                          hintText: "Enter the SubTitle",
                          border: const OutlineInputBorder(),
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
                left: Paddings.screentHorizontal,
                right: Paddings.screentHorizontal,
                bottom: buttonBottom,
                child: Hero(
                  tag: 'hero-cta',
                  flightShuttleBuilder: _materialShuttle,
                  child: SizedBox(
                    height: Sizes.sizeButtonHeight,
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        foregroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Rvalues.button),
                        ),
                      ),
                      onPressed: _handleCreate,
                      child: Text(
                        widget.ctaLabel,
                        style: const TextStyle(
                          fontSize: Sizes.sizeButtonFont,
                          fontWeight: Fonts.weightExtraHeavy,
                        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // 오버레이 안에서도 자체 탭은 바깥으로 전파되지 않도록 처리
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {}, // 내부 탭 흡수
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode
                  ? Borders.lineColorDark
                  : Borders.lineColorLight,
            ),
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
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 닫기(X)
                InkResponse(
                  onTap: onClose,
                  radius: 16,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
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
