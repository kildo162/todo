import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Wrap a page to enable back navigation via the system back stack
/// and a left-edge swipe gesture (useful on Android to mimic iOS back).
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final double edgeWidth;
  final double minDragDistance;
  final double minFlingVelocity;

  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.edgeWidth = 32,
    this.minDragDistance = 40,
    this.minFlingVelocity = 200,
  });

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  bool _eligible = false;
  double _dragDistance = 0;

  bool get _canPop =>
      Get.key.currentState?.canPop() ?? Navigator.of(context).canPop();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        _eligible = details.localPosition.dx <= widget.edgeWidth;
        _dragDistance = 0;
      },
      onHorizontalDragUpdate: (details) {
        if (_eligible) _dragDistance += details.delta.dx;
      },
      onHorizontalDragCancel: () {
        _eligible = false;
        _dragDistance = 0;
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        final shouldPop =
            _eligible &&
            _canPop &&
            _dragDistance > widget.minDragDistance &&
            velocity > widget.minFlingVelocity;
        if (shouldPop) {
          Get.back();
        }
        _eligible = false;
        _dragDistance = 0;
      },
      child: widget.child,
    );
  }
}
