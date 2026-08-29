import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class FeatureTip {
  final String icon;
  final String title;
  final String description;

  const FeatureTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Shows a sequence of bottom tip cards, one at a time, dimming the rest
// of the screen slightly. Never shows again once completed or skipped,
// tracked via a SharedPreferences flag unique to this tour.
class FeatureTipOverlay extends StatefulWidget {
  final List<FeatureTip> tips;
  final VoidCallback onFinished;

  const FeatureTipOverlay({
    super.key,
    required this.tips,
    required this.onFinished,
  });

  static const String _seenKey = 'hasSeenHomeFeatureTour';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_seenKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  @override
  State<FeatureTipOverlay> createState() => _FeatureTipOverlayState();
}

class _FeatureTipOverlayState extends State<FeatureTipOverlay> {
  int _index = 0;

  void _next() {
    if (_index < widget.tips.length - 1) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await FeatureTipOverlay.markSeen();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tips[_index];
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.45),
        child: Stack(
          children: [
            Positioned(
              left: 20, right: 20, bottom: 90,
              child: _TipCard(
                tip: tip,
                index: _index,
                total: widget.tips.length,
                onNext: _next,
                onSkip: _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final FeatureTip tip;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TipCard({
    required this.tip,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  // For 'ghost', 'dues', and 'ask', these are drawn with the exact
  // same custom painters used on the real Home screen icons, so the
  // tip card matches what the user will actually see, not a generic
  // stand-in icon.
  Widget _iconWidget(String key, Color color) {
    switch (key) {
      case 'add':
        return Icon(Icons.add_rounded, color: color, size: 22);
      case 'camera':
        return Icon(Icons.camera_alt_outlined, color: color, size: 20);
      case 'ghost':
        return CustomPaint(painter: _TipGhostPainter(color: color));
      case 'dues':
        return CustomPaint(painter: _TipDuesPainter(color: color));
      case 'ask':
        return CustomPaint(painter: _TipRRPainter(color: color));
      default:
        return Icon(Icons.info_outline_rounded, color: color, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: palette.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _iconWidget(tip.icon, palette.accent),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSkip,
                  child: Icon(Icons.close_rounded,
                      color: palette.inkMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(tip.title,
                style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.ink)),
            const SizedBox(height: 6),
            Text(tip.description,
                style: GoogleFonts.syne(
                    fontSize: 13, color: palette.inkMuted, height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: List.generate(total, (i) {
                    return Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: i == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == index
                            ? palette.accent
                            : palette.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Material(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Text(
                        index == total - 1 ? 'Got it' : 'Next',
                        style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.accentFg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GHOST ICON — matches Home screen's Ghost Money card exactly ──────────

class _TipGhostPainter extends CustomPainter {
  final Color color;
  const _TipGhostPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path();
    path.moveTo(cx - 10, cy + 10);
    path.lineTo(cx - 10, cy - 2);
    path.quadraticBezierTo(cx - 10, cy - 12, cx, cy - 12);
    path.quadraticBezierTo(cx + 10, cy - 12, cx + 10, cy - 2);
    path.lineTo(cx + 10, cy + 10);
    path.lineTo(cx + 5, cy + 6);
    path.lineTo(cx, cy + 10);
    path.lineTo(cx - 5, cy + 6);
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(cx - 3, cy - 2), 1.8, pf);
    canvas.drawCircle(Offset(cx + 3, cy - 2), 1.8, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── DUES ICON — matches Home screen's Dues Tracker card exactly ──────────

class _TipDuesPainter extends CustomPainter {
  final Color color;
  const _TipDuesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final top = Path();
    top.moveTo(cx - 8, cy - 3);
    top.quadraticBezierTo(cx, cy - 10, cx + 8, cy - 3);
    canvas.drawPath(top, p);
    final topHead = Path();
    topHead.moveTo(cx + 8, cy - 3);
    topHead.lineTo(cx + 4, cy - 5);
    topHead.moveTo(cx + 8, cy - 3);
    topHead.lineTo(cx + 5, cy + 0.5);
    canvas.drawPath(topHead, p);

    final bottom = Path();
    bottom.moveTo(cx + 8, cy + 3);
    bottom.quadraticBezierTo(cx, cy + 10, cx - 8, cy + 3);
    canvas.drawPath(bottom, p);
    final bottomHead = Path();
    bottomHead.moveTo(cx - 8, cy + 3);
    bottomHead.lineTo(cx - 4, cy + 5);
    bottomHead.moveTo(cx - 8, cy + 3);
    bottomHead.lineTo(cx - 5, cy - 0.5);
    canvas.drawPath(bottomHead, p);

    canvas.drawCircle(Offset(cx - 8, cy - 3), 1.6, pf);
    canvas.drawCircle(Offset(cx + 8, cy + 3), 1.6, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── ASK YOUR MONEY ICON — matches the FAB's "RR" logo mark exactly ───────

class _TipRRPainter extends CustomPainter {
  final Color color;
  const _TipRRPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 8, cy + 8);
    lp.lineTo(cx - 8, cy - 4);
    lp.quadraticBezierTo(cx - 8, cy - 8, cx - 4, cy - 8);
    lp.quadraticBezierTo(cx - 1, cy - 8, cx - 1, cy - 4);
    lp.quadraticBezierTo(cx - 1, cy, cx - 4, cy);
    lp.lineTo(cx - 2, cy + 8);
    canvas.drawPath(lp, p);

    final rp = Path();
    rp.moveTo(cx + 8, cy + 8);
    rp.lineTo(cx + 8, cy - 4);
    rp.quadraticBezierTo(cx + 8, cy - 8, cx + 4, cy - 8);
    rp.quadraticBezierTo(cx + 1, cy - 8, cx + 1, cy - 4);
    rp.quadraticBezierTo(cx + 1, cy, cx + 4, cy);
    rp.lineTo(cx + 2, cy + 8);
    canvas.drawPath(rp, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}