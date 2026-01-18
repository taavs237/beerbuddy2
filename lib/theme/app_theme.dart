import 'package:flutter/material.dart';

class BeerBuddyTheme {
  // Core palette (smokey + amber)
  static const _bg = Color(0xFF0E0D0C);
  static const _surface = Color(0xFF141210);
  static const _card = Color(0xFF1D1916);
  static const _card2 = Color(0xFF221E1B);

  static const _amber = Color(0xFFD39A2C);
  static const _amber2 = Color(0xFFC7821E);

  static const _textPrimary = Color(0xFFF2EDE6);
  static const _textSecondary = Color(0xFFB9B0A6);
  static const _outline = Color(0xFF2A2521);

  static ThemeData build() {
    // Using ColorScheme.fromSeed gives a complete, valid ColorScheme for M3.
    final scheme = ColorScheme.fromSeed(
      seedColor: _amber,
      brightness: Brightness.dark,
      surface: _surface,
    ).copyWith(
      primary: _amber,
      secondary: _amber2,
      error: const Color(0xFFCC4B4B),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,

      appBarTheme: const AppBarTheme(
        backgroundColor: _bg,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      iconTheme: const IconThemeData(color: _textPrimary),

      dividerTheme: const DividerThemeData(
        color: _outline,
        thickness: 1,
        space: 1,
      ),

      // ✅ FIX: Flutteri uuemates versioonides ootab ThemeData.cardTheme tüüpi CardThemeData?
      cardTheme: const CardThemeData(
        color: _card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: _outline),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _amber, width: 1.2),
        ),
        hintStyle: const TextStyle(color: _textSecondary),
        labelStyle: const TextStyle(color: _textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _amber,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          side: const BorderSide(color: _outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _card2,
        contentTextStyle: const TextStyle(color: _textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: _textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: _textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
      ),
    );
  }
}
