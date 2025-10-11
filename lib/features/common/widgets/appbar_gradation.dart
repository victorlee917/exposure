import 'package:flutter/material.dart';

/// AppBar 바로 아래에서 아래 방향으로 매우 부드럽게 사라지는 그라데이션.
/// - withOpacity 금지 → ARGB 직접 구성
/// - 많은 스톱(기본 20개) + easeOut 커브로 실크 같은 페이드
class AppbarGradation extends StatelessWidget {
  const AppbarGradation({
    super.key,
    this.height = 120, // 꼬리를 길게 → 경계 감춤
    this.useThemeBg = true,
    this.intensity = 1.0, // 0~1, 전체 진하기 스케일
    this.stopsCount = 20, // 스톱 수(많을수록 더 부드러움)
  });

  final double height;
  final bool useThemeBg;
  final double intensity;
  final int stopsCount;

  @override
  Widget build(BuildContext context) {
    final Color base = useThemeBg
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.black;

    // 알파를 직접 만들어 주는 헬퍼
    Color fade(double a01) => Color.fromARGB(
      (255 * (a01.clamp(0.0, 1.0)) * intensity).toInt(),
      base.red,
      base.green,
      base.blue,
    );

    // 많은 스톱을 비선형(easeOut) 분포로 생성해 긴 꼬리(soft tail)를 만듦
    final int n = stopsCount.clamp(8, 64); // 최소 8, 최대 64
    final List<double> stops = List<double>.generate(n, (i) => i / (n - 1));
    final List<Color> colors = stops.map((t) {
      // 위쪽은 진하고 아래로 갈수록 아주 천천히 0으로 수렴
      // easeOut으로 급격히 줄였다가, 제곱해 꼬리를 더 길게 만듦
      final eased = Curves.easeOut.transform(t); // 0->1
      final alpha = (1.0 - eased); // 1->0
      final soft = alpha * alpha; // 더 긴 tail
      return fade(soft);
    }).toList();

    // 맨 끝이 확실히 0이 되도록 마지막 2개의 알파를 0으로 보정
    colors[colors.length - 1] = fade(0.0);
    if (colors.length >= 2) colors[colors.length - 2] = fade(0.0);

    return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: stops,
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
    );
  }
}
