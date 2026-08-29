import 'dart:math';
import 'package:flutter/material.dart';

class RupeeFall extends StatefulWidget {
  final Color color;
  final int count;
  final Duration duration;

  const RupeeFall({
    super.key,
    required this.color,
    this.count = 6,
    this.duration = const Duration(seconds: 15),
  });

  @override
  State<RupeeFall> createState() => _RupeeFallState();
}

class _RupeeFallState extends State<RupeeFall>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<double> _lefts;
  late final List<double> _sizes;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    final staggerMs = widget.duration.inMilliseconds ~/ widget.count;
    _controllers = List.generate(widget.count, (i) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * staggerMs), () {
        if (mounted) controller.repeat();
      });
      return controller;
    });
    // Keeps every rupee in the left or right quarter of the screen,
    // skipping the middle band entirely so nothing ever drifts
    // behind or through the logo sitting in the center.
    _lefts = List.generate(widget.count, (i) {
      final onLeft = i % 2 == 0;
      return onLeft
          ? 0.04 + rand.nextDouble() * 0.16
          : 0.80 + rand.nextDouble() * 0.16;
    });
    _sizes = List.generate(widget.count, (_) => 18.0 + rand.nextDouble() * 14);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: List.generate(widget.count, (i) {
              return AnimatedBuilder(
                animation: _controllers[i],
                builder: (context, _) {
                  final t = _controllers[i].value;
                  final opacity = t < 0.1
                      ? (t / 0.1) * 0.45
                      : t > 0.9
                          ? ((1 - t) / 0.1) * 0.25
                          : 0.35;
                  final top = -30 + t * (constraints.maxHeight + 60);
                  final rotation = -10 * t * (pi / 180);
                  return Positioned(
                    left: constraints.maxWidth * _lefts[i],
                    top: top,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            color: widget.color,
                            fontSize: _sizes[i],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}