import 'package:flutter/material.dart';

/// Brand palette, matching the Numeria product design document.
class NumeriaColors {
  static const teal = Color(0xFF2E6F6E);
  static const tealDark = Color(0xFF1F4F4E);
  static const orange = Color(0xFFF2994A);
  static const yellow = Color(0xFFFFC94A);
  static const purple = Color(0xFF8E6FF2);
  static const pink = Color(0xFFF2739C);
  static const green = Color(0xFF6FCF97);
  static const blue = Color(0xFF56CCF2);
  static const background = Color(0xFFF6FBFA);
  static const cardShadow = Color(0x1A000000);
}

class NumeriaTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: NumeriaColors.teal,
      scaffoldBackgroundColor: NumeriaColors.background,
      brightness: Brightness.light,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: 1.02),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: NumeriaColors.tealDark,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NumeriaColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: NumeriaColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

/// Helper for a cheerful gradient background used across most screens.
BoxDecoration numeriaBackground({List<Color>? colors}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors ?? const [Color(0xFFEAF6F5), Color(0xFFFDF3E7)],
    ),
  );
}
