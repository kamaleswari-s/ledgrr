import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/rupee_fall.dart';
import '../onboarding/stats_intro_screen.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _seenOnboardingKey = 'hasSeenOnboarding';

  @override
  void initState() {
    super.initState();
    _runSequence();
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

  Future<void> _runSequence() async {
    final destinationFuture = _determineDestination();
    await Future.delayed(const Duration(milliseconds: 2800));
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
    const splashMuted = Color(0xFF8FBFB2);
    const splashAccent = Color(0xFF1A8C7A);

    return Scaffold(
      backgroundColor: splashBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: RupeeFall(color: splashAccent, count: 4),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LEDGRR',
                    style: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: splashInk,
                        letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text('Finance clarity for students',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: splashMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}