import 'package:flutter/material.dart';

class Roll extends StatelessWidget {
  const Roll({super.key, required this.rollIndex, required this.itemIndex});

  final int rollIndex, itemIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000), // Colors.black.withOpacity(0.1)
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
