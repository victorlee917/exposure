import 'package:daily_exposures/constants/rvalues.dart';
import 'package:flutter/material.dart';

class Roll extends StatelessWidget {
  const Roll({super.key, required this.rollIndex, required this.itemIndex});

  final int rollIndex, itemIndex;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(Rvalues.roll),
        // boxShadow: [
        //   BoxShadow(
        //     color: isDarkMode
        //         ? Colors.white38
        //         : Colors.black38, // Colors.black.withOpacity(0.1)
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Center(
        child: Text(
          'Roll ${rollIndex + 1} - ${itemIndex + 1}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
