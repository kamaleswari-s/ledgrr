import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Ready to know\nyour truth?',
                    style: GoogleFonts.syne(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                        letterSpacing: -0.8,
                        height: 1.2),
                    textAlign: TextAlign.center),
                const SizedBox(height: 14),
                Text(
                  'LEDGRR never stores your card details. It reads your transactions to give you clarity, nothing else.',
                  style: GoogleFonts.syne(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: palette.inkMuted,
                      height: 1.65),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Material(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await _markOnboardingSeen();
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const AuthScreen(isSignUp: true)),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text('Create your account',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: palette.accentFg)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await _markOnboardingSeen();
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const AuthScreen(isSignUp: false)),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Center(
                        child: Text('I already have an account',
                            style: GoogleFonts.syne(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: palette.ink)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: palette.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No card numbers, no bank login, no transfer permissions. You control every entry. Your money stays yours.',
                          style: GoogleFonts.syne(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: palette.ink,
                              height: 1.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}