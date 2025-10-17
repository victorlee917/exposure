import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/features/detail/widgets/item_navigator.dart';
import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:flutter/material.dart';

class FilmRollDetailScreen extends StatefulWidget {
  final String rollTitle;
  final int rollIndex;
  final int itemIndex;
  final int itemCount;
  final String type;

  const FilmRollDetailScreen({
    super.key,
    required this.rollTitle,
    required this.rollIndex,
    required this.itemIndex,
    required this.itemCount,
    required this.type,
  });

  @override
  State<FilmRollDetailScreen> createState() => _FilmRollDetailScreenState();
}

class _FilmRollDetailScreenState extends State<FilmRollDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  static const double _sidePageScale = 0.8; // 선택되지 않은 페이지의 스케일
  static const double _sidePageOpacity = 0.2; // 선택되지 않은 페이지의 투명도
  static const double _pageSpacing = 10.0; // 페이지 간 간격

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.itemIndex;
    _pageController = PageController(initialPage: widget.itemIndex, viewportFraction: 0.7);
    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentIndex) {
        setState(() {
          _currentIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the source Roll widget's actual size to match for Hero animation
    final double rollWidth = (screenWidth * 0.65) - 32;
    final double cardHeightForCalc = widget.type == 'music' ? rollWidth : rollWidth * 1.5;
    final double rollHeight = cardHeightForCalc - 16; // Account for vertical padding in source

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.rollTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.itemCount,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final heroTag = 'roll-${widget.rollIndex}-item-$index';
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double currentPageValue = _pageController.hasClients && _pageController.position.hasContentDimensions
                      ? _pageController.page!
                      : widget.itemIndex.toDouble();
                  double delta = index - currentPageValue;
                  double scale = 1.0 - (delta.abs() * (1.0 - _sidePageScale));
                  double opacity = 1.0 - (delta.abs() * (1.0 - _sidePageOpacity));

                  final pageWidth = MediaQuery.of(context).size.width * _pageController.viewportFraction;
                  final rollWidth = pageWidth - _pageSpacing;
                  final rollHeight = widget.type == 'music' ? rollWidth : rollWidth * 3 / 2;

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale.clamp(_sidePageScale, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _pageSpacing / 2),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: rollWidth,
                            height: rollHeight,
                            child: Roll(
                              rollIndex: widget.rollIndex,
                              itemIndex: index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ItemNavigator(
                currentIndex: _currentIndex,
                itemCount: widget.itemCount,
                onPageChanged: (index) {
                  _pageController.jumpToPage(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}