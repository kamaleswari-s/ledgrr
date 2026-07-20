import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── LEDGRR COLOR TOKENS ───────────────────────────────────────────────────

class LedgrrColors {
  // LIGHT THEMES
  static const mint = LedgrrPalette(
    name: 'Deep Mint',
    bg: Color(0xFFEAF5F3),
    bg2: Color(0xFFD2EDE9),
    card: Color(0xFFF4FAF9),
    accent: Color(0xFF1A8C7A),
    accentFg: Colors.white,
    ink: Color(0xFF071C18),
    inkMuted: Color(0xFF2E5C52),
    border: Color(0xFF8ABFB8),
    isDark: false,
  );

  static const rose = LedgrrPalette(
    name: 'Dusty Rose',
    bg: Color(0xFFF5EEF2),
    bg2: Color(0xFFEDD8E4),
    card: Color(0xFFFAF5F8),
    accent: Color(0xFFB5446E),
    accentFg: Colors.white,
    ink: Color(0xFF2A0F1C),
    inkMuted: Color(0xFF6B2848),
    border: Color(0xFFCCA0B8),
    isDark: false,
  );

  static const slate = LedgrrPalette(
    name: 'Slate Blue',
    bg: Color(0xFFEEF3F8),
    bg2: Color(0xFFDDE8F2),
    card: Color(0xFFF6F9FC),
    accent: Color(0xFF1A5EC4),
    accentFg: Colors.white,
    ink: Color(0xFF0C1F35),
    inkMuted: Color(0xFF2E4E6E),
    border: Color(0xFF90B8D8),
    isDark: false,
  );

  static const violet = LedgrrPalette(
    name: 'Clay Violet',
    bg: Color(0xFFF0EDF8),
    bg2: Color(0xFFE2DBF4),
    card: Color(0xFFF8F6FC),
    accent: Color(0xFF6040A0),
    accentFg: Colors.white,
    ink: Color(0xFF1A1030),
    inkMuted: Color(0xFF4A3478),
    border: Color(0xFFAA98D8),
    isDark: false,
  );

  static const peach = LedgrrPalette(
    name: 'Sunset Peach',
    bg: Color(0xFFFFF0EB),
    bg2: Color(0xFFFFD9C8),
    card: Color(0xFFFFF8F5),
    accent: Color(0xFFCC4A18),
    accentFg: Colors.white,
    ink: Color(0xFF1A0A00),
    inkMuted: Color(0xFF6A2E10),
    border: Color(0xFFE8A888),
    isDark: false,
  );

  // DARK THEMES
  static const aurora = LedgrrPalette(
    name: 'Aurora',
    bg: Color(0xFF0A0A14),
    bg2: Color(0xFF14142A),
    card: Color(0xFF1E1E38),
    accent: Color(0xFF9B7CFF),
    accentFg: Color(0xFF0A0A14),
    ink: Color(0xFFF0EEFF),
    inkMuted: Color(0xFFB8AAEE),
    border: Color(0xFF3A3A5A),
    isDark: true,
  );

  static const obsidian = LedgrrPalette(
    name: 'Obsidian',
    bg: Color(0xFF0E0E0E),
    bg2: Color(0xFF1A1A1A),
    card: Color(0xFF242424),
    accent: Color(0xFFC8FF00),
    accentFg: Color(0xFF0E0E0E),
    ink: Color(0xFFF5F5F0),
    inkMuted: Color(0xFFAAAAAA),
    border: Color(0xFF383838),
    isDark: true,
  );

  static const cosmos = LedgrrPalette(
    name: 'Cosmos',
    bg: Color(0xFF080B1A),
    bg2: Color(0xFF10142E),
    card: Color(0xFF181C3C),
    accent: Color(0xFF4D9FFF),
    accentFg: Color(0xFF080B1A),
    ink: Color(0xFFEEF0FF),
    inkMuted: Color(0xFFAAB4E8),
    border: Color(0xFF282C4A),
    isDark: true,
  );

  static const ember = LedgrrPalette(
    name: 'Ember',
    bg: Color(0xFF120800),
    bg2: Color(0xFF1E0E00),
    card: Color(0xFF2C1600),
    accent: Color(0xFFFF7A3C),
    accentFg: Color(0xFF120800),
    ink: Color(0xFFFFF4EE),
    inkMuted: Color(0xFFDDAA88),
    border: Color(0xFF3C2010),
    isDark: true,
  );

  static const steel = LedgrrPalette(
    name: 'Steel and Jade',
    bg: Color(0xFF0C0F14),
    bg2: Color(0xFF141A26),
    card: Color(0xFF1C2230),
    accent: Color(0xFF00C8A0),
    accentFg: Color(0xFF0C0F14),
    ink: Color(0xFFE8EDF5),
    inkMuted: Color(0xFF88AACC),
    border: Color(0xFF243040),
    isDark: true,
  );

  static const List<LedgrrPalette> lightThemes = [
    mint, rose, slate, violet, peach,
  ];

  static const List<LedgrrPalette> darkThemes = [
    aurora, obsidian, cosmos, ember, steel,
  ];

  static const List<LedgrrPalette> allThemes = [
    mint, rose, slate, violet, peach,
    aurora, obsidian, cosmos, ember, steel,
  ];
}

// ─── PALETTE MODEL ─────────────────────────────────────────────────────────

class LedgrrPalette {
  final String name;
  final Color bg;
  final Color bg2;
  final Color card;
  final Color accent;
  final Color accentFg;
  final Color ink;
  final Color inkMuted;
  final Color border;
  final bool isDark;

  const LedgrrPalette({
    required this.name,
    required this.bg,
    required this.bg2,
    required this.card,
    required this.accent,
    required this.accentFg,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.isDark,
  });
}

// ─── THEME BUILDER ─────────────────────────────────────────────────────────

class LedgrrTheme {
  static ThemeData build(LedgrrPalette p) {
    return ThemeData(
      useMaterial3: true,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme(
        brightness: p.isDark ? Brightness.dark : Brightness.light,
        primary: p.accent,
        onPrimary: p.accentFg,
        secondary: p.bg2,
        onSecondary: p.ink,
        surface: p.card,
        onSurface: p.ink,
        error: const Color(0xFFE53935),
        onError: Colors.white,
        outline: p.border,
        surfaceContainerHighest: p.bg2,
      ),
      cardColor: p.card,
      dividerColor: p.border,
      textTheme: _buildTextTheme(p),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: p.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.accentFg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.dmSerifDisplay(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
        labelStyle: GoogleFonts.syne(fontSize: 14, color: p.inkMuted),
        hintStyle: GoogleFonts.syne(fontSize: 14, color: p.inkMuted),
      ),
    );
  }

  static TextTheme _buildTextTheme(LedgrrPalette p) {
    return TextTheme(
      displayLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 48, fontStyle: FontStyle.italic,
        color: p.ink, height: 1.2,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 36, fontStyle: FontStyle.italic,
        color: p.ink, height: 1.2,
      ),
      displaySmall: GoogleFonts.dmSerifDisplay(
        fontSize: 28, fontStyle: FontStyle.italic,
        color: p.ink, height: 1.3,
      ),
      headlineLarge: GoogleFonts.syne(
        fontSize: 24, fontWeight: FontWeight.w800,
        color: p.ink, letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.syne(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: p.ink, letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.syne(
        fontSize: 17, fontWeight: FontWeight.w700, color: p.ink,
      ),
      titleLarge: GoogleFonts.syne(
        fontSize: 16, fontWeight: FontWeight.w700, color: p.ink,
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 14, fontWeight: FontWeight.w600, color: p.ink,
      ),
      titleSmall: GoogleFonts.syne(
        fontSize: 13, fontWeight: FontWeight.w600, color: p.ink,
      ),
      bodyLarge: GoogleFonts.syne(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: p.ink, height: 1.6,
      ),
      bodyMedium: GoogleFonts.syne(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: p.ink, height: 1.6,
      ),
      bodySmall: GoogleFonts.syne(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: p.inkMuted, height: 1.5,
      ),
      labelLarge: GoogleFonts.syne(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: p.ink, letterSpacing: 0.02,
      ),
      labelMedium: GoogleFonts.syne(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: p.inkMuted, letterSpacing: 0.05,
      ),
      labelSmall: GoogleFonts.syne(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: p.inkMuted, letterSpacing: 0.08,
      ),
    );
  }
}