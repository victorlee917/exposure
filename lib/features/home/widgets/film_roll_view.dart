import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/rolls.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/common/widgets/text_chip.dart';
import 'package:daily_exposures/features/common/widgets/text_roll_description.dart';
import 'package:daily_exposures/features/common/widgets/text_roll_title.dart';
import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilmRollView extends StatefulWidget {
  const FilmRollView({
    super.key,
    required this.rollIndex,
    required this.currentPage,
    required this.horizontalPageController,
    required this.verticalPageController,
    required this.verticalPage,
    required this.isDeveloped,
    required this.filmRollDetails,
    required this.itemCount,
    required this.itemEdgeInsets,
    this.shareIcon,
    this.draftPage, // 0-based, undeveloped 롤의 “다음에 쓸 인덱스”
  });

  final int rollIndex;
  final double currentPage;
  final PageController horizontalPageController;
  final PageController verticalPageController;
  final double verticalPage;
  final bool isDeveloped;
  final Map<String, String> filmRollDetails;
  final int itemCount;
  final EdgeInsets Function(int, int) itemEdgeInsets;
  final Widget? shareIcon;
  final int? draftPage;

  @override
  State<FilmRollView> createState() => _FilmRollViewState();
}

class _FilmRollViewState extends State<FilmRollView> with AutomaticKeepAliveClientMixin {
  static const double _kCardRadius = Rvalues.roll; // 카드와 동일

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double diff = (widget.rollIndex - widget.currentPage);
    final double scale = (1 - diff.abs() * 0.4).clamp(0.8, 1.0);
    final double opacity = (1 - diff.abs() * 8).clamp(0.8, 1.0);

    // 진행률
    final int total = widget.itemCount <= 0 ? 1 : widget.itemCount;
    final int dp = (widget.draftPage ?? 0).clamp(0, total);
    final double progress = widget.isDeveloped ? 1.0 : (dp / total);

    // ✅ 게이지 색 결정
    final bool filledAndUndeveloped = !widget.isDeveloped && (dp >= total);
    final Color gaugeColor = filledAndUndeveloped
        ? const Color.fromARGB(255, 97, 255, 102)
        : isDarkMode
        ? Colors.white
        : Colors.black;

    // 상태 뱃지
    final Widget statusRow = widget.isDeveloped
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BadgeChip(
                radius: _kCardRadius,
                child: TextChip(text: 'DEVELOPED'),
              ),
            ],
          )
        : _ExpGaugeChip(
            progress: progress,
            radius: _kCardRadius,
            gaugeColor: gaugeColor, // ✅ 조건부 색상 전달
          );

    return GestureDetector(
      onTap: () {
        widget.horizontalPageController.animateToPage(
          widget.rollIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 16.0;
              const verticalPadding = 16.0;
              final cardWidth = constraints.maxWidth - (horizontalPadding * 2);
              final cardHeight = cardWidth * 3 / 2;
              final pageHeight = cardHeight + verticalPadding;
              final cardTopOffset = (constraints.maxHeight - pageHeight) / 2;

              final detailsRevealProgress = (widget.verticalPage - (widget.itemCount - 2))
                  .clamp(0.0, 1.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 상단 타이틀/설명/배지
                  Positioned(
                    top: cardTopOffset - 100,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: diff.abs() < 0.5 ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          TextRollTitle(text: 'Film Roll ${widget.rollIndex + 1}'),
                          SizedBox(height: Sizes.size8),
                          TextRollDescription(text: 'This is a description.'),
                          const SizedBox(height: 16),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [statusRow],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 하단 메타정보
                  Positioned(
                    bottom: cardTopOffset - 80,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    child: Transform.translate(
                      offset: Offset(0, 100 * (1 - detailsRevealProgress)),
                      child: Opacity(
                        opacity: detailsRevealProgress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Started: ${widget.filmRollDetails["started"]}',
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                color: isDarkMode
                                    ? Fonts.colorSubTextDark
                                    : Fonts.colorSubTextLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ended: ${widget.filmRollDetails["ended"]}',
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                color: isDarkMode
                                    ? Fonts.colorSubTextDark
                                    : Fonts.colorSubTextLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Developed: ${widget.filmRollDetails["developed"]}',
                                  style: TextStyle(
                                    fontSize: Sizes.size14,
                                    color: isDarkMode
                                        ? Fonts.colorSubTextDark
                                        : Fonts.colorSubTextLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 세로 카드 리스트
                  PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: widget.verticalPageController,
                    clipBehavior: Clip.none,
                    itemCount: widget.itemCount,
                    itemBuilder: (context, itemIndex) {
                      BorderRadius? borderRadius;
                      if (itemIndex == 0) {
                        borderRadius = const BorderRadius.only(
                          topLeft: Radius.circular(_kCardRadius),
                          topRight: Radius.circular(_kCardRadius),
                        );
                      } else if (itemIndex == widget.itemCount - 1) {
                        borderRadius = const BorderRadius.only(
                          bottomLeft: Radius.circular(_kCardRadius),
                          bottomRight: Radius.circular(_kCardRadius),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Rolls.backgroundColorDark
                              : Rolls.backgroundColorLight,
                          borderRadius: borderRadius,
                        ),
                        padding: widget.itemEdgeInsets(itemIndex, widget.itemCount),
                        child: Roll(rollIndex: widget.rollIndex, itemIndex: itemIndex),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// 공통 칩
class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.child, required this.radius, this.onTap});

  final Widget child;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final core = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Rolls.backgroundColorDark
            : Rolls.backgroundColorLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode ? Borders.lineColorDark : Borders.lineColorLight,
        ),
      ),
      child: Center(child: child),
    );

    if (onTap == null) return core;
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: core,
    );
  }
}

// EXP 게이지 칩
class _ExpGaugeChip extends StatelessWidget {
  const _ExpGaugeChip({
    required this.progress, // 0.0~1.0
    required this.radius,
    required this.gaugeColor, // ✅ 조건부 색상
  });

  final double progress;
  final double radius;
  final Color gaugeColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const double barW = 64;
    const double barH = 6;
    final double clamped = progress.clamp(0.0, 1.0);

    return _BadgeChip(
      radius: radius,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextChip(text: 'EXP.'),
          const SizedBox(width: 8),
          SizedBox(
            width: barW,
            height: barH,
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(barH / 2),
              borderRadius: BorderRadius.circular(Rvalues.roll),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.24)
                        : Colors.black.withOpacity(0.24),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: barW * clamped,
                      decoration: BoxDecoration(
                        color: gaugeColor, // ✅ 동적 색상
                        // borderRadius: BorderRadius.circular(barH / 2),
                        borderRadius: BorderRadius.circular(Rvalues.roll),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
