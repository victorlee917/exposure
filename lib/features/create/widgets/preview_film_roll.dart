
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

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Rolls.backgroundColorDark : Rolls.backgroundColorLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            height: 200, // Placeholder height
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Rolls.backgroundColorDark
                  : Rolls.backgroundColorLight,
            ),
            padding: EdgeInsets.fromLTRB(16.0, index == 0 ? 16.0 : 0, 16.0, 16.0),
            child: Roll(rollIndex: 0, itemIndex: index),
          );
        },
      ),
    );
  }
}
