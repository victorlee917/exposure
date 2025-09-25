import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.loginMethod,
    required this.icon,
  });

  final String loginMethod;
  final FaIcon icon;

  // final void _onSocialLoginTap = () {
  //   print("helo");
  // };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: _onSocialLoginTap,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Paddings.buttonHorizontal,
            vertical: Paddings.buttonVertical,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
              width: Borders.buttonWidth,
            ),
            borderRadius: BorderRadius.circular(Rvalues.button),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: icon),
              Text(
                "Sign in with $loginMethod",
                style: TextStyle(fontWeight: Fonts.weightBold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
