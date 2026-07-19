import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

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
      home: const OnboardingScreen(),
    );
  }
}