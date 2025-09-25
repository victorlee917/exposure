import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class PaginationButton extends StatelessWidget {
  const PaginationButton({
    super.key,
    required this.text,
    required this.isRight,
  });

  final String text;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.size52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isRight ? Colors.black : Colors.transparent,
        border: Border.all(
          color: isRight ? Borders.buttonColorDefault : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(Borders.buttonRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isRight ? Colors.white : const Color.fromARGB(128, 0, 0, 0),
          fontWeight: isRight ? Fonts.weightBold : Fonts.weightRegular,
        ),
      ),
    );
  }
}
