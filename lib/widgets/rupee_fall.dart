import 'dart:math';
import 'package:flutter/material.dart';

class RupeeFall extends StatefulWidget {
  final Color color;
  final int count;

  const RupeeFall({super.key, required this.color, this.count = 4});

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
    _controllers = List.generate(widget.count, (i) {
      final controller = AnimationController(
        duration: const Duration(seconds: 9),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * 2200), () {
        if (mounted) controller.repeat();
      });
      return controller;
    });
    _lefts = List.generate(widget.count, (_) => 0.08 + rand.nextDouble() * 0.8);
    _sizes = List.generate(widget.count, (_) => 16.0 + rand.nextDouble() * 12);
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
                      ? (t / 0.1) * 0.32
                      : t > 0.9
                          ? ((1 - t) / 0.1) * 0.32
                          : 0.28;
                  final top = -30 + t * (constraints.maxHeight + 60);
                  final rotation = -12 * t * (pi / 180);
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