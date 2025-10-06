import 'package:daily_exposures/constants/fonts.dart';
import 'package:flutter/material.dart';

class TextChip extends StatelessWidget {
  const TextChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: Fonts.weightBold, color: Colors.white, fontSize: 11, letterSpacing: 0.5),
    );
  }
}