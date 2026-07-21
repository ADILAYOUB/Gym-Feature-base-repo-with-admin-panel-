import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:domain/domain.dart';

class DynamicThemeBuilder {
  static ThemeData buildTheme(ThemeConfig config, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Parse Hex colors safely
    final primaryColor = _parseColor(config.primaryColor, Colors.deepOrange);
    final secondaryColor = _parseColor(config.secondaryColor, Colors.blueGrey);
    final backgroundColor = _parseColor(config.backgroundColor, isDark ? const Color(0xff121212) : const Color(0xfff5f5f5));
    final surfaceColor = _parseColor(config.surfaceColor, isDark ? const Color(0xff1e1e1e) : Colors.white);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: isDark ? Colors.white : Colors.black87,
      surface: surfaceColor,
      onSurface: isDark ? Colors.white : Colors.black87,
    );

    // Get Text Theme matching the Dynamic Font Family
    TextTheme baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    TextTheme textTheme = _getTextTheme(config.fontFamily, baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  static Color _parseColor(String hexString, Color fallback) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static TextTheme _getTextTheme(String fontFamily, TextTheme baseTheme) {
    final font = fontFamily.toLowerCase();
    switch (font) {
      case 'inter':
        return GoogleFonts.interTextTheme(baseTheme);
      case 'outfit':
        return GoogleFonts.outfitTextTheme(baseTheme);
      case 'playfair':
      case 'playfair display':
        return GoogleFonts.playfairDisplayTextTheme(baseTheme);
      case 'teko':
        return GoogleFonts.tekoTextTheme(baseTheme);
      case 'roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      default:
        return GoogleFonts.outfitTextTheme(baseTheme); // Default fallback
    }
  }
}
