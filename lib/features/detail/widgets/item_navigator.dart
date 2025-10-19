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
  static const double _dragThreshold = 15.0;
  double _dragDistance = 0.0;
  late int _tempIndex;
  int _startDot = 0;

  static const double _dotSize = 8.0;
  static const double _dotMargin = 4.0;
  static const int _visibleDots = 5;

  @override
  void initState() {
    super.initState();
    _tempIndex = widget.currentIndex;
    _updateStartDot();
  }

  @override
  void didUpdateWidget(covariant ItemNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _tempIndex = widget.currentIndex;
        _updateStartDot();
      });
    }
  }

  void _updateStartDot() {
    if (widget.itemCount <= _visibleDots) {
      _startDot = 0;
      return;
    }

    // Keep the active dot in the center of the visible dots.
    const int centerPosition = _visibleDots ~/ 2;
    _startDot = (_tempIndex - centerPosition).clamp(0, widget.itemCount - _visibleDots);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 1) {
      return const SizedBox.shrink();
    }

    final double dotFullWidth = _dotSize + (_dotMargin * 2);
    final double viewportWidth = _visibleDots * dotFullWidth;

    List<Widget> dots = [];
    for (int i = 0; i < widget.itemCount; i++) {
      final bool isVisible = i >= _startDot && i < _startDot + _visibleDots;
      final bool isActive = i == _tempIndex;

      final double distance = (i - _tempIndex).abs().toDouble();
      final double maxDistance = (_visibleDots ~/ 2).toDouble();

      double scale = 1.0;
      if (maxDistance > 0) {
        scale = 1.0 - (distance / maxDistance) * 0.3;
        scale = scale.clamp(0.7, 1.0);
      }
      if (isActive) {
        scale = 1.1;
      }

      dots.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isVisible ? dotFullWidth : 0,
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              scale: scale,
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      );
    }

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
              _updateStartDot();
            }
            _dragDistance -= _dragThreshold;
          }
          while (_dragDistance < -_dragThreshold) {
            if (_tempIndex < widget.itemCount - 1) {
              _tempIndex++;
              widget.onPageChanged(_tempIndex);
              _updateStartDot();
            }
            _dragDistance += _dragThreshold;
          }
        });
      },
      child: Container(
        color: Colors.transparent,
        width: viewportWidth,
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dots,
        ),
      ),
    );
  }
}
