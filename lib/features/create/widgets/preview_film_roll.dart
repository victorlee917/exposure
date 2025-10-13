
import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/rolls.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:flutter/material.dart';

class PreviewFilmRoll extends StatelessWidget {
  const PreviewFilmRoll({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const itemCount = 12;
    const kCardRadius = Rvalues.roll;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Rolls.backgroundColorDark : Rolls.backgroundColorLight,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          BorderRadius? borderRadius;
          if (index == 0) {
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(kCardRadius),
              topRight: Radius.circular(kCardRadius),
            );
          } else if (index == itemCount - 1) {
            borderRadius = const BorderRadius.only(
              bottomLeft: Radius.circular(kCardRadius),
              bottomRight: Radius.circular(kCardRadius),
            );
          }
          return Container(
            height: 200, // Placeholder height
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Rolls.backgroundColorDark
                  : Rolls.backgroundColorLight,
              borderRadius: borderRadius,
            ),
            padding: EdgeInsets.fromLTRB(16.0, index == 0 ? 16.0 : 0, 16.0, 16.0),
            child: Roll(rollIndex: 0, itemIndex: index),
          );
        },
      ),
    );
  }
}
