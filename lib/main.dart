import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const LedgrrApp(),
    ),
  );
}

class LedgrrApp extends StatelessWidget {
  const LedgrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final palette = themeProvider.palette;

    return MaterialApp(
      title: 'LEDGRR',
      debugShowCheckedModeBanner: false,
      theme: LedgrrTheme.build(palette),
      home: const OnboardingScreen(),
    );
  }
}