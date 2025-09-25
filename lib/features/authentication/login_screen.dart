import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/authentication/widgets/social_login_button.dart';
import 'package:daily_exposures/features/authentication/widgets/terms_agreement_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  void _onSocialLoginTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.size16)),
      ),
      builder: (context) => const TermsAgreementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Paddings.screentHorizontal,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.cameraRetro),
                SizedBox(height: Sizes.size6),
                Text("Daily Exposures"),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Paddings.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isIOS || kIsWeb) ...[
              GestureDetector(
                onTap: () => _onSocialLoginTap(context),
                child: SocialLoginButton(
                  loginMethod: "Apple",
                  icon: FaIcon(FontAwesomeIcons.apple, size: Sizes.size20),
                ),
              ),
              SizedBox(height: Sizes.size12),
            ],
            GestureDetector(
              onTap: () => _onSocialLoginTap(context),
              child: SocialLoginButton(
                loginMethod: "Google",
                icon: FaIcon(FontAwesomeIcons.google, size: Sizes.size20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
