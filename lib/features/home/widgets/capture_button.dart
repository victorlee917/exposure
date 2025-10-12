// lib/features/home/widgets/capture_button.dart
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CaptureButton extends StatelessWidget {
  const CaptureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child:
            Container
            // ✅ 그림자 제거: boxShadow 없음, elevation 없음
            (
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(30),
                // boxShadow: []  // ← 삭제(그림자 원인)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    icon,
                    color: isDarkMode ? Colors.black : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: Sizes.sizeButtonFont,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
