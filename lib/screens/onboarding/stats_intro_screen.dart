import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/floating_blobs.dart';
import 'get_started_screen.dart';

class StatsIntroScreen extends StatelessWidget {
  const StatsIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B2B24);
    const ink = Color(0xFFEAF7F3);
    const muted = Color(0xFF8FBFB2);
    const accent = Color(0xFF1A8C7A);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBlobs(color: accent)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEDGRR',
                      style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: muted)),
                  const SizedBox(height: 14),
                  Text('Hi. Really glad you\'re here.',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: ink,
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
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.syne(
                          fontSize: 13, color: ink, height: 1.7),
                      children: [
                        const TextSpan(
                            text:
                                'A lot of people feel unsure about money, more than you\'d think. Only about '),
                        TextSpan(
                          text: '27%',
                          style: GoogleFonts.syne(
                              color: accent, fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                            text:
                                ' of Indian adults say they feel truly confident managing their finances.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('If that includes you, you\'re in very good company.',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: muted,
                          height: 1.5)),
                  const SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.syne(
                          fontSize: 13, color: ink, height: 1.7),
                      children: [
                        const TextSpan(
                            text:
                                'There\'s also a quiet reason it\'s gotten harder. When payments go digital, spending stops feeling like spending. Around '),
                        TextSpan(
                          text: '74%',
                          style: GoogleFonts.syne(
                              color: accent, fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                            text:
                                ' of UPI users say they notice themselves spending more once it stopped feeling like real money leaving their hands.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.74,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'It\'s not really about willpower. It\'s just that a tap feels invisible in a way cash never did.',
                    style: GoogleFonts.syne(
                        fontSize: 13, color: ink, height: 1.7),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(left: 14),
                    decoration: const BoxDecoration(
                      border:
                          Border(left: BorderSide(color: accent, width: 2)),
                    ),
                    child: Text(
                      '"73% of people say frictionless digital payments make them less aware of money actually leaving their account."',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          color: muted,
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'This is exactly where LEDGRR comes in, gently, honestly, one day at a time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: ink,
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Material(
                    color: accent,
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('Go to LEDGRR',
                              style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: bg)),
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