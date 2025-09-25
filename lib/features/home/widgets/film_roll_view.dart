import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilmRollView extends StatelessWidget {
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

  static const double _kCardRadius = 8.0; // 카드와 동일

  @override
  Widget build(BuildContext context) {
    final double diff = (rollIndex - currentPage);
    final double scale = (1 - diff.abs() * 0.4).clamp(0.8, 1.0);
    final double opacity = (1 - diff.abs() * 8).clamp(0.3, 1.0);

    // 진행률
    final int total = itemCount <= 0 ? 1 : itemCount;
    final int dp = (draftPage ?? 0).clamp(0, total);
    final double progress = isDeveloped ? 1.0 : (dp / total);

    // ✅ 게이지 색 결정
    final bool filledAndUndeveloped = !isDeveloped && (dp >= total);
    final Color gaugeColor = filledAndUndeveloped ? Colors.green : Colors.white;

    // 상태 뱃지
    final Widget statusRow = isDeveloped
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BadgeChip(
                radius: _kCardRadius,
                child: Text(
                  'DEVELOPED',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              _BadgeChip(
                radius: _kCardRadius,
                onTap: () {
                  // 공유 동작 (필요 시 교체)
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    FontAwesomeIcons.shareNodes,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
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
        horizontalPageController.animateToPage(
          rollIndex,
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

              final detailsRevealProgress = (verticalPage - (itemCount - 2))
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
                          Text(
                            'Film Roll ${rollIndex + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'This is a description.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
                              'Started: ${filmRollDetails["started"]}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ended: ${filmRollDetails["ended"]}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Developed: ${filmRollDetails["developed"]}',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                    controller: verticalPageController,
                    clipBehavior: Clip.none,
                    itemCount: itemCount,
                    itemBuilder: (context, itemIndex) {
                      BorderRadius? borderRadius;
                      if (itemIndex == 0) {
                        borderRadius = const BorderRadius.only(
                          topLeft: Radius.circular(_kCardRadius),
                          topRight: Radius.circular(_kCardRadius),
                        );
                      } else if (itemIndex == itemCount - 1) {
                        borderRadius = const BorderRadius.only(
                          bottomLeft: Radius.circular(_kCardRadius),
                          bottomRight: Radius.circular(_kCardRadius),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(36, 36, 36, 1.0),
                          borderRadius: borderRadius,
                        ),
                        padding: itemEdgeInsets(itemIndex, itemCount),
                        child: Roll(rollIndex: rollIndex, itemIndex: itemIndex),
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
    final core = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xE6000000),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white24),
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
    const double barW = 64;
    const double barH = 6;
    final double clamped = progress.clamp(0.0, 1.0);

    return _BadgeChip(
      radius: radius,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EXP.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: barW,
            height: barH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(barH / 2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.white.withOpacity(0.24)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: barW * clamped,
                      decoration: BoxDecoration(
                        color: gaugeColor, // ✅ 동적 색상
                        borderRadius: BorderRadius.circular(barH / 2),
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
