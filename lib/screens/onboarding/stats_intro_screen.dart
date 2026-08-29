import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../widgets/floating_blobs.dart';
import 'get_started_screen.dart';

// ─── PALETTE FOR THIS SCREEN ────────────────────────────────────────────
const _bg = Color(0xFF0B2B24);
const _ink = Color(0xFFEAF7F3);
const _muted = Color(0xFF8FBFB2);
const _accent = Color(0xFF1A8C7A);
const _amber = Color(0xFFD9A441);
const _blue = Color(0xFF2D7DD2);
const _rose = Color(0xFFB5446E);

// ─── REVEAL-ON-VISIBLE WRAPPER ──────────────────────────────────────────
// Plays a fade + slide-up once, the moment the section scrolls into
// view, and exposes the same 0-1 progress to the child via a builder
// so charts can draw themselves in sync with that same reveal.
class _RevealOnVisible extends StatefulWidget {
  final String id;
  final Widget Function(BuildContext context, Animation<double> progress)
      builder;

  const _RevealOnVisible({required this.id, required this.builder});

  @override
  State<_RevealOnVisible> createState() => _RevealOnVisibleState();
}

class _RevealOnVisibleState extends State<_RevealOnVisible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_hasPlayed) return;
    if (info.visibleFraction > 0.3) {
      _hasPlayed = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.id),
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut))),
          child: widget.builder(context, _controller),
        ),
      ),
    );
  }
}

class StatsIntroScreen extends StatelessWidget {
  const StatsIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBlobs(color: _accent)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Wordmark ──
                  Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _ink,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: CustomPaint(
                          painter: _RRLogoPainter(
                              leftColor: _bg, rightColor: _accent),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('LEDGRR',
                          style: GoogleFonts.syne(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: _muted)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Hi. Really glad you\'re here.',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                          height: 1.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Before we get started, here\'s a little of why we built this in the first place.',
                    style: GoogleFonts.syne(
                        fontSize: 13,
                        color: const Color(0xFFB8D9CF),
                        height: 1.6),
                  ),
                  const SizedBox(height: 40),

                  // ── STAT 1: 27% donut ──
                  _RevealOnVisible(
                    id: 'stat1',
                    builder: (context, progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'A lot of people feel unsure about money. Only about 27% of Indian adults say they feel truly confident managing their finances.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(
                              fontSize: 13, color: _ink, height: 1.65),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) => CustomPaint(
                            size: const Size(84, 84),
                            painter: _DonutPainter(
                              percent: 0.27 * progress.value,
                              color: _accent,
                              displayPercent: (27 * progress.value).round(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If that includes you, you\'re in very good company.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSerifDisplay(
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── STAT 2: 56/100 benchmark scale ──
                  _RevealOnVisible(
                    id: 'stat2',
                    builder: (context, progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Students specifically aren\'t spared. A study on Indian college students found their financial literacy score was just over half.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(
                              fontSize: 13, color: _ink, height: 1.65),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) => SizedBox(
                            width: 220, height: 56,
                            child: CustomPaint(
                              painter: _BenchmarkScalePainter(
                                value: 56 * progress.value,
                                maxValue: 100,
                                color: _amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('56 out of 100',
                            style: GoogleFonts.syne(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _amber)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── STAT 3: bar chart ──
                  _RevealOnVisible(
                    id: 'stat3',
                    builder: (context, progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.syne(
                                fontSize: 13, color: _ink, height: 1.65),
                            children: [
                              const TextSpan(
                                  text:
                                      'A 2025 NPCI survey found students under 25 make over '),
                              TextSpan(
                                text: '300 UPI payments',
                                style: GoogleFonts.syne(
                                    color: _blue, fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(text: ' a month.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) => SizedBox(
                            width: 220, height: 100,
                            child: CustomPaint(
                              painter: _WeeklyBarPainter(
                                values: const [68, 82, 57],
                                labels: const ['Wk 1', 'Wk 2', 'Wk 3'],
                                color: _blue,
                                progress: progress.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Roughly 75 a week. Try remembering all of them.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSerifDisplay(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── STAT 4: split donut ──
                  _RevealOnVisible(
                    id: 'stat4',
                    builder: (context, progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.syne(
                                fontSize: 13, color: _ink, height: 1.6),
                            children: [
                              const TextSpan(
                                  text:
                                      'A 2023 student finance survey found over '),
                              TextSpan(
                                text: '60%',
                                style: GoogleFonts.syne(
                                    color: _rose, fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(
                                  text:
                                      ' of students overspend from a lack of proper tracking.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) => CustomPaint(
                            size: const Size(90, 90),
                            painter: _SplitDonutPainter(
                              splitFraction: 0.60 * progress.value,
                              colorA: _rose,
                              colorB: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LegendDot(color: _rose, label: 'Overspend'),
                            const SizedBox(width: 16),
                            _LegendDot(color: _accent, label: 'On track'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── STAT 5: area chart ──
                  _RevealOnVisible(
                    id: 'stat5',
                    builder: (context, progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.syne(
                                fontSize: 13, color: _ink, height: 1.65),
                            children: [
                              const TextSpan(
                                  text:
                                      'And when payments go digital, spending stops feeling like spending. Around '),
                              TextSpan(
                                text: '74%',
                                style: GoogleFonts.syne(
                                    color: _amber,
                                    fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(
                                  text:
                                      ' of UPI users say they notice themselves spending more.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) => SizedBox(
                            width: 220, height: 80,
                            child: CustomPaint(
                              painter: _AreaChartPainter(
                                points: const [
                                  0.75, 0.65, 0.69, 0.4, 0.475, 0.19, 0.1
                                ],
                                color: _amber,
                                progress: progress.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('spending trend, month over month',
                            style: GoogleFonts.syne(
                                fontSize: 11, color: _muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _RevealOnVisible(
                    id: 'quote',
                    builder: (context, progress) => Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: const BoxDecoration(
                        border:
                            Border(left: BorderSide(color: _accent, width: 2)),
                      ),
                      child: Text(
                        '"73% say frictionless digital payments make them less aware of money actually leaving their account."',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            color: _muted,
                            height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _RevealOnVisible(
                    id: 'closing1',
                    builder: (context, progress) => Text(
                      'Most finance apps are still built around a salary, EMIs, and tax planning. Almost none are built around a monthly allowance, dues between friends, and a UPI habit that started at 18.',
                      style: GoogleFonts.syne(
                          fontSize: 13, color: _ink, height: 1.75),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _RevealOnVisible(
                    id: 'closing2',
                    builder: (context, progress) => Center(
                      child: Text(
                        'This is exactly where LEDGRR comes in, gently, honestly, one day at a time.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: _ink,
                            height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _RevealOnVisible(
                    id: 'button',
                    builder: (context, progress) => Material(
                      color: _accent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const GetStartedScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Go to LEDGRR',
                                style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: _bg)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SMALL WIDGETS ───────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.syne(fontSize: 11, color: _muted)),
      ],
    );
  }
}

// ─── LOGO PAINTER (matches the app-wide "RR" mark) ──────────────────────

class _RRLogoPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  const _RRLogoPainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 11, cy + 11);
    lp.lineTo(cx - 11, cy - 5);
    lp.quadraticBezierTo(cx - 11, cy - 11, cx - 6, cy - 11);
    lp.quadraticBezierTo(cx - 1, cy - 11, cx - 1, cy - 5);
    lp.quadraticBezierTo(cx - 1, cy + 1, cx - 6, cy + 1);
    lp.lineTo(cx - 2, cy + 11);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 11, cy + 11);
    rp.lineTo(cx + 11, cy - 5);
    rp.quadraticBezierTo(cx + 11, cy - 11, cx + 6, cy - 11);
    rp.quadraticBezierTo(cx + 1, cy - 11, cx + 1, cy - 5);
    rp.quadraticBezierTo(cx + 1, cy + 1, cx + 6, cy + 1);
    rp.lineTo(cx + 2, cy + 11);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── DONUT CHART ─────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final double percent; // 0.0-1.0, already progress-scaled
  final Color color;
  final int displayPercent;

  const _DonutPainter({
    required this.percent,
    required this.color,
    required this.displayPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    final track = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      percent * 2 * 3.14159,
      false,
      arc,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$displayPercent%',
        style: GoogleFonts.syne(
            fontSize: 18, fontWeight: FontWeight.w700, color: _ink),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.percent != percent;
}

// ─── BENCHMARK SCALE ─────────────────────────────────────────────────────

class _BenchmarkScalePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  const _BenchmarkScalePainter({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height * 0.5;
    final left = 10.0;
    final right = size.width - 10;
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, trackY), Offset(right, trackY), trackPaint);

    final fillFraction = (value / maxValue).clamp(0.0, 1.0);
    final fillX = left + (right - left) * fillFraction;
    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, trackY), Offset(fillX, trackY), fillPaint);

    final tickPaint = Paint()
      ..color = _muted
      ..strokeWidth = 1.2;
    for (int i = 0; i <= 4; i++) {
      final x = left + (right - left) * (i / 4);
      canvas.drawLine(
          Offset(x, trackY - 6), Offset(x, trackY + 6), tickPaint);
      final label = TextPainter(
        text: TextSpan(
          text: '${i * 25}',
          style: GoogleFonts.syne(fontSize: 9, color: _muted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
          canvas, Offset(x - label.width / 2, trackY + 10));
    }

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(fillX, trackY), 7, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BenchmarkScalePainter old) =>
      old.value != value;
}

// ─── WEEKLY BAR CHART ────────────────────────────────────────────────────

class _WeeklyBarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double progress;

  const _WeeklyBarPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final baseY = size.height - 20;
    final chartTop = 12.0;
    final chartHeight = baseY - chartTop;
    final barWidth = 40.0;
    final gap = (size.width - barWidth * values.length) / (values.length + 1);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), gridPaint);

    for (int i = 0; i < values.length; i++) {
      final x = gap + i * (barWidth + gap);
      final fullHeight = (values[i] / maxVal) * chartHeight;
      final animatedHeight = fullHeight * progress.clamp(0.0, 1.0);
      final barTop = baseY - animatedHeight;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTRB(x, barTop, x + barWidth, baseY),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      final barPaint = Paint()..color = color;
      canvas.drawRRect(rrect, barPaint);

      if (progress > 0.7) {
        final valueOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
        final valueLabel = TextPainter(
          text: TextSpan(
            text: values[i].round().toString(),
            style: GoogleFonts.syne(
                fontSize: 10,
                color: _ink.withOpacity(valueOpacity)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valueLabel.paint(
            canvas,
            Offset(x + barWidth / 2 - valueLabel.width / 2,
                barTop - 14));
      }

      final dayLabel = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: GoogleFonts.syne(fontSize: 9, color: _muted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayLabel.paint(
          canvas, Offset(x + barWidth / 2 - dayLabel.width / 2, baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarPainter old) =>
      old.progress != progress;
}

// ─── SPLIT DONUT ─────────────────────────────────────────────────────────

class _SplitDonutPainter extends CustomPainter {
  final double splitFraction;
  final Color colorA;
  final Color colorB;

  const _SplitDonutPainter({
    required this.splitFraction,
    required this.colorA,
    required this.colorB,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 9;

    final basePaint = Paint()
      ..color = colorB
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawCircle(center, radius, basePaint);

    final splitPaint = Paint()
      ..color = colorA
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      splitFraction * 2 * 3.14159,
      false,
      splitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitDonutPainter old) =>
      old.splitFraction != splitFraction;
}

// ─── AREA CHART ──────────────────────────────────────────────────────────

class _AreaChartPainter extends CustomPainter {
  final List<double> points; // 0.0-1.0, fraction from bottom (1=top)
  final Color color;
  final double progress;

  const _AreaChartPainter({
    required this.points,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dx = size.width / (points.length - 1);
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    final metric = linePath.computeMetrics().first;
    final drawLength = metric.length * progress.clamp(0.0, 1.0);
    final partialLine = metric.extractPath(0, drawLength);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(partialLine, linePaint);

    if (progress > 0.85) {
      final fillOpacity = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
      final areaPath = Path.from(linePath)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final areaPaint = Paint()..color = color.withOpacity(0.12 * fillOpacity);
      canvas.drawPath(areaPath, areaPaint);
    }

    if (drawLength >= metric.length - 1) {
      final tangent = metric.getTangentForOffset(metric.length);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, 3.5, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter old) =>
      old.progress != progress;
}