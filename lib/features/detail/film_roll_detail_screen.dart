import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/features/detail/widgets/item_navigator.dart';
import 'package:daily_exposures/features/home/widgets/roll.dart';
import 'package:flutter/material.dart';

class FilmRollDetailScreen extends StatefulWidget {
  final String rollTitle;
  final int rollIndex;
  final int itemIndex;
  final int itemCount;

  const FilmRollDetailScreen({
    super.key,
    required this.rollTitle,
    required this.rollIndex,
    required this.itemIndex,
    required this.itemCount,
  });

  @override
  State<FilmRollDetailScreen> createState() => _FilmRollDetailScreenState();
}

class _FilmRollDetailScreenState extends State<FilmRollDetailScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.itemIndex);
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
    final double cardHeightForCalc = rollWidth * 1.5;
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
            itemBuilder: (context, index) {
              final heroTag = 'roll-${widget.rollIndex}-item-$index';
              return Align(
                alignment: Alignment.topCenter,
                child: Hero(
                  tag: heroTag,
                  child: SizedBox(
                    width: rollWidth,
                    height: rollHeight,
                    child: Roll(
                      rollIndex: widget.rollIndex,
                      itemIndex: index,
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
