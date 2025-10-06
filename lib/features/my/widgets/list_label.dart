import 'package:flutter/material.dart';

class ListLabel extends StatelessWidget {
  const ListLabel({super.key, required this.text, this.textColor});
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? Colors.white : Colors.black;

    return Text(
      text,
      style: TextStyle(fontSize: 16, color: textColor ?? defaultColor),
    );
  }
}
