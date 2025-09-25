import 'package:daily_exposures/constants/gaps.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/username/set_username_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAgreementSheet extends StatelessWidget {
  const TermsAgreementSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TermsAgreementSheet();
  }
}

class _TermsAgreementSheet extends StatefulWidget {
  const _TermsAgreementSheet();

  @override
  State<_TermsAgreementSheet> createState() => _TermsAgreementSheetState();
}

class _TermsAgreementSheetState extends State<_TermsAgreementSheet> {
  bool _privacyPolicyAgreed = false;
  bool _termsOfServiceAgreed = false;

  bool get _isButtonEnabled => _privacyPolicyAgreed && _termsOfServiceAgreed;

  void _onStartPressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SetUsernameScreen()),
      (route) => false,
    );
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://www.naver.com');
    if (!await launchUrl(url)) {
      // Could not launch URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Paddings.screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.v10,
          const Text(
            "Agree to our terms",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Sizes.size16,
            ),
          ),
          Gaps.v20,
          Row(
            children: [
              Checkbox(
                value: _privacyPolicyAgreed,
                onChanged: (value) {
                  setState(() {
                    _privacyPolicyAgreed = value ?? false;
                  });
                },
              ),
              GestureDetector(
                onTap: _launchURL,
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _termsOfServiceAgreed,
                onChanged: (value) {
                  setState(() {
                    _termsOfServiceAgreed = value ?? false;
                  });
                },
              ),
              GestureDetector(
                onTap: _launchURL,
                child: const Text(
                  "Terms of Service",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          Gaps.v20,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isButtonEnabled ? _onStartPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled
                    ? Colors.black
                    : Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  vertical: Paddings.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Start",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
