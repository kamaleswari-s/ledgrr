import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/rupee_fall.dart';
import '../../widgets/slide_to_continue.dart';
import '../onboarding/stats_intro_screen.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _seenOnboardingKey = 'hasSeenOnboarding';

  late final AnimationController _burstController;
  late final AnimationController _logoController;
  late final AnimationController _textController;

  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _burstController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _burstController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<Widget> _determineDestination() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return const HomeScreen();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;

    return hasSeenOnboarding
        ? const AuthScreen(isSignUp: false)
        : const StatsIntroScreen();
  }

  Future<void> _onSlideConfirmed() async {
    if (_navigating) return;
    _navigating = true;
    final destination = await _determineDestination();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    const splashBg = Color(0xFF0B2B24);
    const splashInk = Color(0xFFEAF7F3);
    const splashMuted = Color(0xFF8FBFB2);
    const splashAccent = Color(0xFF1A8C7A);

    return Scaffold(
      backgroundColor: splashBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: RupeeFall(
              color: splashAccent,
              count: 2,
              duration: const Duration(seconds: 16),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ripple burst, expands once then fades out
                AnimatedBuilder(
                  animation: _burstController,
                  builder: (context, child) {
                    final scale = 1.0 + _burstController.value * 1.6;
                    final opacity = 1.0 - _burstController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 84, height: 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: splashAccent, width: 2),
                              ),
                            ),
                          ),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _logoController,
                        curve: Curves.elasticOut),
                    child: Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        color: splashInk,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: CustomPaint(
                        painter: _SplashLogoPainter(
                          leftColor: splashBg,
                          rightColor: splashAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: _textController, curve: Curves.easeOut)),
                    child: Text('LEDGRR',
                        style: GoogleFonts.syne(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: splashInk,
                            letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _textController,
                  child: Text('Old world. New brain.',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: splashAccent)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24, right: 24, bottom: 40,
            child: FadeTransition(
              opacity: _textController,
              child: SlideToContinue(
                onConfirmed: _onSlideConfirmed,
                trackColor: Colors.white.withOpacity(0.08),
                thumbColor: splashAccent,
                thumbIconColor: splashBg,
                labelColor: splashMuted,
                label: 'Slide to continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _SplashLogoPainter(
      {required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 16, cy + 16);
    lp.lineTo(cx - 16, cy - 7);
    lp.quadraticBezierTo(cx - 16, cy - 16, cx - 8, cy - 16);
    lp.quadraticBezierTo(cx - 1, cy - 16, cx - 1, cy - 7);
    lp.quadraticBezierTo(cx - 1, cy + 1, cx - 8, cy + 1);
    lp.lineTo(cx - 3, cy + 16);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 16, cy + 16);
    rp.lineTo(cx + 16, cy - 7);
    rp.quadraticBezierTo(cx + 16, cy - 16, cx + 8, cy - 16);
    rp.quadraticBezierTo(cx + 1, cy - 16, cx + 1, cy - 7);
    rp.quadraticBezierTo(cx + 1, cy + 1, cx + 8, cy + 1);
    rp.lineTo(cx + 3, cy + 16);
    canvas.drawPath(rp, right);

    canvas.drawPath(lp, left);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}