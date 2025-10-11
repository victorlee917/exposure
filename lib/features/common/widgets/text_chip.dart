import 'package:daily_exposures/constants/fonts.dart';
import 'package:flutter/material.dart';

class TextChip extends StatelessWidget {
  const TextChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontWeight: Fonts.weightBold,
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
