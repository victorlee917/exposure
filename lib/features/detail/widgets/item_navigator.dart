import 'package:flutter/material.dart';
import 'dart:math' as math;

class ItemNavigator extends StatefulWidget {
  final int currentIndex;
  final int itemCount;
  final ValueChanged<int> onPageChanged;

  const ItemNavigator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.onPageChanged,
  });

  @override
  State<ItemNavigator> createState() => _ItemNavigatorState();
}

class _ItemNavigatorState extends State<ItemNavigator> {
  static const double _dragThreshold = 10.0;
  double _dragDistance = 0.0;
  late int _tempIndex;

  static const double _dotSize = 8.0;
  static const double _dotMargin = 4.0;
  static const int _visibleDots = 5;

  @override
  void initState() {
    super.initState();
    _tempIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant ItemNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _tempIndex) {
      setState(() {
        _tempIndex = widget.currentIndex;
      });
    }
  }

  Widget _buildBaseDot(int index) {
    final double distance = (index - _tempIndex).abs().toDouble();
    final double maxDistance = (_visibleDots ~/ 2).toDouble();

    double scale = 1.0;
    if (maxDistance > 0) {
      scale = 1.0 - (distance / maxDistance) * 0.3;
      scale = scale.clamp(0.7, 1.0);
    }

    return Transform.scale(
      scale: scale,
      child: Container(
        width: _dotSize,
        height: _dotSize,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: _dotMargin),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.4), // Base color for all dots
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 1) {
      return const SizedBox.shrink();
    }

    final double dotFullWidth = _dotSize + (_dotMargin * 2);
    final double viewportWidth = _visibleDots * dotFullWidth;

    // Calculate the range of dots to display in the 5-dot window
    int startDot;
    int endDot;

    if (widget.itemCount <= _visibleDots) {
      startDot = 0;
      endDot = widget.itemCount;
    } else {
      startDot = _tempIndex - (_visibleDots ~/ 2);
      if (startDot < 0) {
        startDot = 0;
      }
      endDot = startDot + _visibleDots;
      if (endDot > widget.itemCount) {
        endDot = widget.itemCount;
        startDot = endDot - _visibleDots;
      }
    }

    List<Widget> baseDots = [];
    for (int i = startDot; i < endDot; i++) {
      baseDots.add(_buildBaseDot(i));
    }

    // Calculate the left position for the AnimatedPositioned indicator
    // This is the position of the _tempIndex dot relative to the start of the *currently displayed* baseDots.
    final double indicatorLeft = (_tempIndex - startDot) * dotFullWidth + _dotMargin;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragDistance = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDistance += details.delta.dx;

          while (_dragDistance > _dragThreshold) {
            if (_tempIndex > 0) {
              _tempIndex--;
              widget.onPageChanged(_tempIndex);
            }
            _dragDistance -= _dragThreshold;
          }
          while (_dragDistance < -_dragThreshold) {
            if (_tempIndex < widget.itemCount - 1) {
              _tempIndex++;
              widget.onPageChanged(_tempIndex);
            }
            _dragDistance += _dragThreshold;
          }
        });
      },
      child: Container(
        color: Colors.transparent,
        width: viewportWidth,
        height: 30,
        child: Center(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: baseDots,
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: indicatorLeft,
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}