import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class TextRollDescription extends StatelessWidget {
  const TextRollDescription({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
        fontWeight: Fonts.weightRegular,
        fontSize: Sizes.size14,
      ),
    );
  }
}