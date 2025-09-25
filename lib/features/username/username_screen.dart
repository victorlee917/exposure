import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/constants/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _formController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _formAnimation;
  bool _showSecondText = false;
  bool _showFirstText = true;
  bool _showForm = false;
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isUsernameValid = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeIn));

    _usernameController.addListener(() {
      setState(() {
        _isUsernameValid = _usernameController.text.isNotEmpty;
      });
    });

    // Start the animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Show "Hello Stranger."
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    // Hide "Hello Stranger."
    await _fadeController.reverse();

    // Show "What's your Name?" and keep it visible
    setState(() {
      _showFirstText = false;
      _showSecondText = true;
    });
    await _fadeController.forward();

    // Show the form after a brief delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showForm = true;
    });
    await _formController.forward();

    // Focus on the text field to bring up keyboard after form animation completes
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _formController.dispose();
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Paddings.screentHorizontal,
                    vertical: Paddings.screentVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Text(
                              _showFirstText
                                  ? "Hello Stranger."
                                  : _showSecondText
                                  ? "What's your Name?"
                                  : "",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: Fonts.weightHeavy),
                            ),
                          );
                        },
                      ),
                      if (_showForm)
                        AnimatedBuilder(
                          animation: _formAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _formAnimation.value,
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
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9_]'),
                                      ),
                                      LengthLimitingTextInputFormatter(14),
                                    ],
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: Fonts.weightBold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter your nickname",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                Paddings.buttonHorizontal,
                                            vertical: Paddings.buttonVertical,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (_showForm)
                AnimatedBuilder(
                  animation: _formAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _formAnimation.value,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          left: Paddings.screentHorizontal,
                          right: Paddings.screentHorizontal,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          top: 20,
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "You can change your nickname at any time.",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Gaps.v10,
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isUsernameValid
                                      ? () {
                                          // Handle username submission
                                          if (_usernameController
                                              .text
                                              .isNotEmpty) {
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
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: Fonts.weightBold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
