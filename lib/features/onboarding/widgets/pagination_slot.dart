import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class PaginationSlot extends StatelessWidget {
  final bool isFilled;

  const PaginationSlot({super.key, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 배경 (회색)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(Sizes.size12),
                ),
              ),
              // 채워지는 부분 (검정색)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 4,
                width: isFilled ? constraints.maxWidth : 0, // 애니메이션 포인트
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(Sizes.size12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
