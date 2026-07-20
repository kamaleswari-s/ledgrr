import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  LedgrrPalette _palette = LedgrrColors.mint;

  LedgrrPalette get palette => _palette;

  void setTheme(String themeName) {
    final all = LedgrrColors.allThemes;
    final found = all.firstWhere(
      (p) => p.name == themeName,
      orElse: () => LedgrrColors.mint,
    );
    _palette = found;
    notifyListeners();
  }

  void setPalette(LedgrrPalette palette) {
    _palette = palette;
    notifyListeners();
  }
}