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
  late final AnimationController _glowController;

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

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

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
          // Kept out of the center band entirely, so nothing ever
          // drifts behind or across the logo.
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
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_burstController, _glowController]),
                    builder: (context, child) {
                      final scale = 1.0 + _burstController.value * 1.6;
                      final burstOpacity = 1.0 - _burstController.value;
                      final glowScale = 0.9 + _glowController.value * 0.2;
                      final glowOpacity = 0.12 + _glowController.value * 0.08;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: glowScale,
                            child: Container(
                              width: 130, height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: splashAccent.withOpacity(glowOpacity),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: burstOpacity.clamp(0.0, 1.0),
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
                          parent: _logoController, curve: Curves.elasticOut),
                      child: Image.asset(
                        'assets/images/ledgrr_logo.png',
                        width: 84,
                        height: 84,
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
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _textController,
                    child: Text(
                      'LEDGRR shows you what you can actually spend right now, not just your bank balance, and quietly catches the subscriptions you forgot about.',
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