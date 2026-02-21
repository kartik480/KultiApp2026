import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  static const Color _primary = Color(0xFF1B5E4A);
  static const Color _primaryLight = Color(0xFF2D7A63);
  static const Color _accent = Color(0xFFE8A838);
  static const Color _surface = Color(0xFFF7F5F0);
  static const Color _surfaceDark = Color(0xFF1A1D1B);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF242826);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primary,
        onPrimary: Colors.white,
        secondary: _primaryLight,
        onSecondary: Colors.white,
        tertiary: _accent,
        onTertiary: Color(0xFF1A1D1B),
        surface: _surface,
        onSurface: Color(0xFF1A1D1B),
        surfaceContainerHighest: _cardLight,
      ),
      scaffoldBackgroundColor: _surface,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _surface,
        foregroundColor: const Color(0xFF1A1D1B),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1D1B),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _cardLight,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _cardLight,
        selectedItemColor: _primary,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _surface,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3BAF8A),
        onPrimary: Color(0xFF1A1D1B),
        secondary: Color(0xFF4FC9A4),
        onSecondary: Color(0xFF1A1D1B),
        tertiary: _accent,
        onTertiary: Color(0xFF1A1D1B),
        surface: _surfaceDark,
        onSurface: Color(0xFFE5E7EB),
        surfaceContainerHighest: _cardDark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _surfaceDark,
        foregroundColor: const Color(0xFFE5E7EB),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE5E7EB),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _cardDark,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3BAF8A),
        foregroundColor: Color(0xFF1A1D1B),
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _cardDark,
        selectedItemColor: Color(0xFF3BAF8A),
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3BAF8A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _surfaceDark,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = GoogleFonts.outfitTextTheme();
    final onSurface = brightness == Brightness.light ? const Color(0xFF1A1D1B) : const Color(0xFFE5E7EB);
    return base.apply(bodyColor: onSurface, displayColor: onSurface);
  }
}
