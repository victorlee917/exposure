import 'package:daily_exposures/constants/rolls.dart';
import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:flutter/material.dart';

class PreviewFilmRoll extends StatelessWidget {
  const PreviewFilmRoll({
    super.key,
    required this.scrollController,
    this.aspectRatio = 2 / 3,
  });

  final ScrollController scrollController;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Rolls.backgroundColorDark : Rolls.backgroundColorLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Rolls.backgroundColorDark
                  : Rolls.backgroundColorLight,
            ),
            padding: EdgeInsets.fromLTRB(16.0, index == 0 ? 16.0 : 0, 16.0, 16.0),
            child: Roll(
              rollIndex: 0,
              itemIndex: index % 12,
              aspectRatio: aspectRatio,
            ),
          );
        },
      ),
    );
  }
}
