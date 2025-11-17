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
    required this.scrollController,
    required this.isDeveloped,
    required this.filmRollDetails,
    required this.itemCount,
    this.shareIcon,
    this.draftPage, // 0-based, undeveloped 롤의 "다음에 쓸 인덱스"
    this.onCardTap,
    required this.type,
    required this.title,
    this.description,
    required this.imageRatio,
  });

  final int rollIndex;
  final double currentPage;
  final PageController horizontalPageController;
  final ScrollController scrollController;
  final bool isDeveloped;
  final Map<String, String> filmRollDetails;
  final int itemCount;
  final Widget? shareIcon;
  final int? draftPage;
  final void Function(int itemIndex, Object heroTag)? onCardTap;
  final String type;
  final String title;
  final String? description;
  final double imageRatio;

  @override
  State<FilmRollView> createState() => _FilmRollViewState();
}

class _FilmRollViewState extends State<FilmRollView> with AutomaticKeepAliveClientMixin {
  static const double _kCardRadius = Rvalues.roll; // 카드와 동일

  @override
  bool get wantKeepAlive => true;

  EdgeInsets _itemEdgeInsets(index, length) {
    if (index == 0) {
      return const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0);
    } else if (index == length - 1) {
      return const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0);
    } else {
      return const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0);
    }
  }

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
      onTap: diff.abs() > 0.5
          ? () {
              widget.horizontalPageController.animateToPage(
                widget.rollIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = 16.0;
            final cardWidth = constraints.maxWidth - (horizontalPadding * 2);
            final cardHeight = cardWidth * widget.imageRatio;

            final verticalPadding = (constraints.maxHeight - cardHeight) / 2;
            final headerHeight = 100.0; // Approximate height of the header

            final headerTop = verticalPadding - headerHeight - 20;

            final footerHeight = 80.0;
            final footerBottom = verticalPadding - footerHeight - 20;

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Header
                Positioned(
                  top: headerTop,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: diff.abs() < 0.5 ? 1.0 : 0.0,
                    child: SizedBox(
                      height: headerHeight,
                      child: Column(
                        children: [
                          TextRollTitle(text: widget.title),
                          const SizedBox(height: Sizes.size8),
                          TextRollDescription(text: widget.description ?? ''),
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
                ),

                // Footer
                Positioned(
                  bottom: footerBottom,
                  child: SizedBox(
                    height: footerHeight,
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

                // Vertical card list
                ListView.builder(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.only(
                    top: verticalPadding,
                    bottom: verticalPadding,
                  ),
                  controller: widget.scrollController,
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
                    final heroTag = 'roll-${widget.rollIndex}-item-$itemIndex';
                    return Hero(
                      tag: heroTag,
                      createRectTween: (begin, end) {
                        return MaterialRectArcTween(begin: begin, end: end);
                      },
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        final Hero toHero = toHeroContext.widget as Hero;
                        return toHero.child;
                      },
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Rolls.backgroundColorDark
                              : Rolls.backgroundColorLight,
                          borderRadius: borderRadius,
                        ),
                        padding: _itemEdgeInsets(itemIndex, widget.itemCount),
                        child: GestureDetector(
                          onTap: () => widget.onCardTap?.call(itemIndex, heroTag),
                          child: Roll(
                            rollIndex: widget.rollIndex,
                            itemIndex: itemIndex,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    ));
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