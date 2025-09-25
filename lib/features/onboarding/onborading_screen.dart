import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/gaps.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/authentication/login_screen.dart';
import 'package:daily_exposures/features/onboarding/widgets/pagination_button.dart';
import 'package:daily_exposures/features/onboarding/widgets/pagination_title_block.dart';
import 'package:daily_exposures/features/onboarding/widgets/pagination_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboradingScreen extends StatefulWidget {
  const OnboradingScreen({super.key});

  @override
  State<OnboradingScreen> createState() => _OnboradingScreenState();
}

class _OnboradingScreenState extends State<OnboradingScreen> {
  final _pageController = PageController();

  int _current = 0;

  final _pages = [
    _PageData(title: "Title 1", subtitle: "SubTitle 1", color: Colors.red),
    _PageData(title: "Title 2", subtitle: "SubTitle 2", color: Colors.blue),
    _PageData(title: "Title 3", subtitle: "SubTitle 3", color: Colors.yellow),
    _PageData(title: "Title 4", subtitle: "SubTitle 4", color: Colors.green),
    _PageData(title: "Title 5", subtitle: "SubTitle 5", color: Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final index = _pageController.page?.round() ?? 0;
      if (index != _current) setState(() => _current = index);
    });
  }

  Future<void> _goTo(int index) async {
    HapticFeedback.selectionClick();
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _prev() async {
    if (_current > 0) await _goTo(_current - 1);
  }

  Future<void> _nextOrStart() async {
    final last = _current == _pages.length - 1;
    if (last) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      await _goTo(_current + 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (_, index) => Container(
              decoration: BoxDecoration(color: _pages[index].color),
            ),
          ),
          Positioned(
            left: Sizes.size48,
            bottom: Sizes.size48,
            child: PaginationTitleBlock(
              title: _pages[_current].title,
              subtitle: _pages[_current].subtitle,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Borders.lineColorDefault,
              width: Borders.lineWidth,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(
            Paddings.screentHorizontal,
            Sizes.size8,
            Paddings.screentHorizontal,
            Paddings.screentVertical,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: Sizes.size4,
                children: [
                  for (int index = 0; index < _pages.length; index++)
                    PaginationSlot(isFilled: _current >= index),
                ],
              ),
              Gaps.v16,
              Row(
                children: [
                  if (_current != 0) ...[
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: _prev,
                        child: PaginationButton(
                          text: "Previous",
                          isRight: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: Sizes.size12),
                  ],
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: _nextOrStart,
                      child: PaginationButton(
                        text: _current == _pages.length - 1 ? "Start" : "Next",
                        isRight: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final String title, subtitle;
  final Color color;

  _PageData({required this.title, required this.subtitle, required this.color});
}
