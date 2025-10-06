import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class TextRollTitle extends StatelessWidget {
  const TextRollTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: Fonts.weightHeavy,
        fontSize: Sizes.size20,
      ),
    );
  }
}
