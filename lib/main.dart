import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LedgrrApp());
}

class LedgrrApp extends StatelessWidget {
  const LedgrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEDGRR',
      debugShowCheckedModeBanner: false,
      theme: LedgrrTheme.build(LedgrrColors.mint),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;
    return Scaffold(
      backgroundColor: palette.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: palette.bg2,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: palette.border,
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: RRLogoPainter(
                          leftColor: palette.inkMuted,
                          rightColor: palette.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'LEDG',
                            style: GoogleFonts.syne(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -2,
                            ),
                          ),
                          TextSpan(
                            text: 'RR',
                            style: GoogleFonts.syne(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Old word. New brain.',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        color: palette.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 64),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 44,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Enter LEDGRR',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            color: palette.accentFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class RRLogoPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  RRLogoPainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final leftPaint = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rightPaint = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final leftPath = Path();
    leftPath.moveTo(cx - 22, cy + 22);
    leftPath.lineTo(cx - 22, cy - 10);
    leftPath.quadraticBezierTo(cx - 22, cy - 22, cx - 12, cy - 22);
    leftPath.quadraticBezierTo(cx - 2, cy - 22, cx - 2, cy - 10);
    leftPath.quadraticBezierTo(cx - 2, cy + 2, cx - 12, cy + 2);
    leftPath.lineTo(cx - 4, cy + 22);
    canvas.drawPath(leftPath, leftPaint);

    final rightPath = Path();
    rightPath.moveTo(cx + 22, cy + 22);
    rightPath.lineTo(cx + 22, cy - 10);
    rightPath.quadraticBezierTo(cx + 22, cy - 22, cx + 12, cy - 22);
    rightPath.quadraticBezierTo(cx + 2, cy - 22, cx + 2, cy - 10);
    rightPath.quadraticBezierTo(cx + 2, cy + 2, cx + 12, cy + 2);
    rightPath.lineTo(cx + 4, cy + 22);
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}