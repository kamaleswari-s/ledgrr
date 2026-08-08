import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _textController;

  static const String _appName = 'LEDGRR';
  static const String _tagline = 'Finance clarity for students';

  int _visibleLetters = 0;
  bool _showTagline = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: _appName.length * 90),
      vsync: this,
    );

    _textController.addListener(() {
      final progress = _textController.value;
      final letters = (progress * _appName.length).floor();
      if (letters != _visibleLetters && mounted) {
        setState(() => _visibleLetters = letters);
      }
    });

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _textController.forward();
    if (mounted) setState(() => _showTagline = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _showButton = true);
    // No auto-navigation — the user taps the button when ready.
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final visibleName = _appName.substring(0, _visibleLetters);

    // A soft, light mint tint evoking the Deep Mint brand color,
    // independent of whichever theme the user currently has active
    // — this is the very first screen, before they've chosen anything.
    const splashBg = Color(0xFFEAF7F3);
    const splashInk = Color(0xFF0B2B24);
    const splashMuted = Color(0xFF4E7A70);
    const splashAccent = Color(0xFF1A8C7A);

    return Scaffold(
      backgroundColor: splashBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      color: splashInk,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: CustomPaint(
                      painter: _RRPainter(
                        leftColor: splashBg,
                        rightColor: splashAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 34,
                child: Text(
                  visibleName,
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: splashInk,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity: _showTagline ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _tagline,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: splashMuted,
                  ),
                ),
              ),
              const Spacer(flex: 4),
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: IgnorePointer(
                  ignoring: !_showButton,
                  child: Material(
                    color: splashAccent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Go to LEDGRR',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 17,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _RRPainter(
      {required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 12, cy + 12);
    lp.lineTo(cx - 12, cy - 5);
    lp.quadraticBezierTo(cx - 12, cy - 12, cx - 6, cy - 12);
    lp.quadraticBezierTo(cx, cy - 12, cx, cy - 5);
    lp.quadraticBezierTo(cx, cy + 1, cx - 6, cy + 1);
    lp.lineTo(cx - 2, cy + 12);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 12, cy + 12);
    rp.lineTo(cx + 12, cy - 5);
    rp.quadraticBezierTo(cx + 12, cy - 12, cx + 6, cy - 12);
    rp.quadraticBezierTo(cx, cy - 12, cx, cy - 5);
    rp.quadraticBezierTo(cx, cy + 1, cx + 6, cy + 1);
    rp.lineTo(cx + 2, cy + 12);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}