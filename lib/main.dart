import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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