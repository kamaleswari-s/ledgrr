import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/stats_intro_screen.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _seenOnboardingKey = 'hasSeenOnboarding';

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _runSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Widget> _determineDestination() async {
    // If a session already exists (including one restored after just
    // tapping a notification), this returns HomeScreen immediately —
    // logged-in users never see onboarding or auth again here.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return const HomeScreen();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;

    return hasSeenOnboarding
        ? const AuthScreen(isSignUp: false)
        : const StatsIntroScreen();
  }

  Future<void> _runSequence() async {
    final destinationFuture = _determineDestination();
    await Future.delayed(const Duration(milliseconds: 1400));
    final destination = await destinationFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    const splashBg = Color(0xFF0B2B24);
    const splashInk = Color(0xFFEAF7F3);

    return Scaffold(
      backgroundColor: splashBg,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
              parent: _controller, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ledgrr_logo_transparent.png',
                  width: 84,
                  height: 84,
                ),
                const SizedBox(height: 18),
                Text('LEDGRR',
                    style: GoogleFonts.syne(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: splashInk,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}