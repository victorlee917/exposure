import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/constants/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isUsernameValid = false;

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(() {
      setState(() {
        _isUsernameValid = _usernameController.text.isNotEmpty;
      });
    });

    // Focus on the text field to bring up keyboard after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Nickname")),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Paddings.screentHorizontal,
          ),
          child: Column(
            children: [
              Gaps.v24,
              TextField(
                controller: _usernameController,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  LengthLimitingTextInputFormatter(14),
                ],
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: Fonts.weightBold,
                ),
                decoration: InputDecoration(
                  hintText: "Enter your nickname",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Paddings.buttonHorizontal,
                    vertical: Paddings.buttonVertical,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0
              ? MediaQuery.of(context).viewInsets.bottom + 24
              : Paddings.screentVertical,
          left: Paddings.screentHorizontal,
          right: Paddings.screentHorizontal,
          top: Paddings.screentVertical,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isUsernameValid
                ? () {
                    // Handle username submission
                    if (_usernameController.text.isNotEmpty) {
                      // Navigate to next screen or save username
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUsernameValid
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: Paddings.buttonVertical,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: Sizes.size16,
                fontWeight: Fonts.weightBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
