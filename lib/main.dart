import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A8C7A),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFEAF5F3),
          primary: const Color(0xFF1A8C7A),
          onPrimary: Colors.white,
          secondary: const Color(0xFFD2EDE9),
          onSecondary: const Color(0xFF071C18),
          tertiary: const Color(0xFFA8D8D2),
        ),
        scaffoldBackgroundColor: const Color(0xFFEAF5F3),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.dmSerifDisplay(
            fontSize: 48,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF071C18),
          ),
          displayMedium: GoogleFonts.dmSerifDisplay(
            fontSize: 32,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF071C18),
          ),
          displaySmall: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF071C18),
          ),
          headlineLarge: GoogleFonts.syne(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF071C18),
          ),
          headlineMedium: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF071C18),
          ),
          titleLarge: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF071C18),
          ),
          titleMedium: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF071C18),
          ),
          bodyLarge: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF071C18),
          ),
          bodyMedium: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF3A6860),
          ),
          bodySmall: GoogleFonts.syne(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF3A6860),
          ),
          labelLarge: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF071C18),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3ECFB8),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF071C18),
          primary: const Color(0xFF3ECFB8),
          onPrimary: const Color(0xFF071C18),
          secondary: const Color(0xFF0E2E28),
          onSecondary: const Color(0xFFE8FAF8),
          tertiary: const Color(0xFF1A4840),
        ),
        scaffoldBackgroundColor: const Color(0xFF071C18),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.dmSerifDisplay(
            fontSize: 48,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFE8FAF8),
          ),
          displayMedium: GoogleFonts.dmSerifDisplay(
            fontSize: 32,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFE8FAF8),
          ),
          displaySmall: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFE8FAF8),
          ),
          headlineLarge: GoogleFonts.syne(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8FAF8),
          ),
          headlineMedium: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8FAF8),
          ),
          titleLarge: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8FAF8),
          ),
          titleMedium: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE8FAF8),
          ),
          bodyLarge: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFE8FAF8),
          ),
          bodyMedium: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF70B8AE),
          ),
          bodySmall: GoogleFonts.syne(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF70B8AE),
          ),
          labelLarge: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE8FAF8),
          ),
        ),
      ),
      themeMode: ThemeMode.light,
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
    return Scaffold(
      backgroundColor: const Color(0xFF071C18),
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
                    // RR Logo Mark
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E2E28),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1A4840),
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: RRLogoPainter(
                          leftColor: const Color(0xFFD2EDE9),
                          rightColor: const Color(0xFF3ECFB8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // LEDGRR wordmark
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'LEDG',
                            style: GoogleFonts.syne(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE8FAF8),
                              letterSpacing: -1.5,
                            ),
                          ),
                          TextSpan(
                            text: 'RR',
                            style: GoogleFonts.syne(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3ECFB8),
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Old word. New brain.',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF70B8AE),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Enter button
                    GestureDetector(
                      onTap: () {
                        // Navigate to home — next step
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A8C7A),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Enter LEDGRR',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
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
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rightPaint = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Left R
    final leftPath = Path();
    leftPath.moveTo(cx - 22, cy + 22);
    leftPath.lineTo(cx - 22, cy - 10);
    leftPath.quadraticBezierTo(cx - 22, cy - 22, cx - 12, cy - 22);
    leftPath.quadraticBezierTo(cx - 2, cy - 22, cx - 2, cy - 10);
    leftPath.quadraticBezierTo(cx - 2, cy + 2, cx - 12, cy + 2);
    leftPath.lineTo(cx - 4, cy + 22);
    canvas.drawPath(leftPath, leftPaint);

    // Right R (mirrored)
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