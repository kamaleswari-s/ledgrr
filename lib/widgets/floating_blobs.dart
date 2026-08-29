import 'dart:math';
import 'package:flutter/material.dart';

class FloatingBlobs extends StatefulWidget {
  final Color color;

  const FloatingBlobs({super.key, required this.color});

  @override
  State<FloatingBlobs> createState() => _FloatingBlobsState();
}

class _FloatingBlobsState extends State<FloatingBlobs>
    with TickerProviderStateMixin {
  late final AnimationController _blobController;
  late final List<AnimationController> _particleControllers;
  late final List<double> _particleLefts;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    final rand = Random();
    _particleControllers = List.generate(5, (i) {
      final controller = AnimationController(
        duration: Duration(seconds: 5 + rand.nextInt(3)),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * 900), () {
        if (mounted) controller.repeat();
      });
      return controller;
    });
    _particleLefts = List.generate(5, (_) => 0.1 + rand.nextDouble() * 0.8);
  }

  @override
  void dispose() {
    _blobController.dispose();
    for (final c in _particleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              final t = _blobController.value * 2 * pi;
              return Stack(
                children: [
                  Positioned(
                    top: -60 + 14 * sin(t),
                    left: -70 + 10 * cos(t),
                    child: _blob(130, 0.16),
                  ),
                  Positioned(
                    bottom: -50 + 10 * cos(t * 1.3),
                    right: -40 + 12 * sin(t * 1.3),
                    child: _blob(100, 0.12),
                  ),
                  ...List.generate(5, (i) {
                    return AnimatedBuilder(
                      animation: _particleControllers[i],
                      builder: (context, _) {
                        final pt = _particleControllers[i].value;
                        final opacity = pt < 0.1
                            ? (pt / 0.1) * 0.5
                            : pt > 0.9
                                ? ((1 - pt) / 0.1) * 0.25
                                : 0.3;
                        final bottom = -10 + pt * (constraints.maxHeight + 20);
                        return Positioned(
                          left: constraints.maxWidth * _particleLefts[i],
                          bottom: bottom,
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.color,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _blob(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withOpacity(opacity),
      ),
    );
  }
}