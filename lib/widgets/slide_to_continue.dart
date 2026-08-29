import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlideToContinue extends StatefulWidget {
  final VoidCallback onConfirmed;
  final Color trackColor;
  final Color thumbColor;
  final Color thumbIconColor;
  final Color labelColor;
  final String label;

  const SlideToContinue({
    super.key,
    required this.onConfirmed,
    required this.trackColor,
    required this.thumbColor,
    required this.thumbIconColor,
    required this.labelColor,
    this.label = 'Slide to continue',
  });

  @override
  State<SlideToContinue> createState() => _SlideToContinueState();
}

class _SlideToContinueState extends State<SlideToContinue>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _trackWidth = 0;
  bool _confirmed = false;
  late final AnimationController _hintController;

  static const double _thumbSize = 44;
  static const double _trackPadding = 4;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  double get _maxDrag =>
      _trackWidth - _thumbSize - (_trackPadding * 2);

  void _onDragUpdate(DragUpdateDetails details) {
    if (_confirmed) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_confirmed) return;
    if (_dragX >= _maxDrag * 0.82) {
      setState(() {
        _dragX = _maxDrag;
        _confirmed = true;
      });
      widget.onConfirmed();
    } else {
      setState(() => _dragX = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.trackColor,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.all(_trackPadding),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: EdgeInsets.only(left: _thumbSize + 12),
                child: Text(
                  widget.label,
                  style: GoogleFonts.syne(
                      fontSize: 13, color: widget.labelColor),
                ),
              ),
              AnimatedBuilder(
                animation: _hintController,
                builder: (context, child) {
                  final hintOffset = _dragX == 0 && !_confirmed
                      ? _hintController.value * 8
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(_dragX + hintOffset, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: BorderRadius.circular(_thumbSize / 2),
                    ),
                    child: Icon(Icons.arrow_forward_rounded,
                        color: widget.thumbIconColor, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}