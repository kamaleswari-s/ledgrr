import 'dart:math';
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

  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _glowController;

  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
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
              count: 6,
              duration: const Duration(seconds: 15),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A real radiant glow — thin light rays spinning
                  // slowly behind the logo, plus a soft breathing
                  // core light. No box, no flat circle, no border.
                                    SizedBox(
                    width: 180, height: 180,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        final glowStrength = 0.5 + _glowController.value * 0.5;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 170, height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: splashAccent
                                        .withOpacity(0.18 * glowStrength),
                                    blurRadius: 70,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 110, height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: splashAccent
                                        .withOpacity(0.4 * glowStrength),
                                    blurRadius: 45,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _logoController, curve: Curves.elasticOut),
                        child: Image.asset(
                          'assets/images/ledgrr_logo_transparent.png',
                          width: 104,
                          height: 104,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _textController,
                    child: Text(
                      'One app for spending, saving, dues, goals, and everything in between, built specifically around how students actually manage money.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syne(
                          fontSize: 13,
                          color: splashMuted,
                          height: 1.6),
                    ),
                  ),
                ],
              ),
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

// Draws thin radiating light rays around a center point, like a
// soft star glint — genuinely reads as "glow", not a flat circle.
class _StarGlowPainter extends CustomPainter {
  final Color color;
  final double strength;

  const _StarGlowPainter({required this.color, required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rayCount = 8;
    final maxLength = size.width / 2;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * pi / rayCount) * i;
      final isLong = i % 2 == 0;
      final length = isLong ? maxLength * strength : maxLength * 0.6 * strength;
      final rayWidth = isLong ? 3.0 : 1.5;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.center,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(0.5 * strength),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: length))
        ..strokeWidth = rayWidth
        ..strokeCap = StrokeCap.round;

      final end = Offset(
        center.dx + length * cos(angle),
        center.dy + length * sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarGlowPainter old) =>
      old.strength != strength;
}