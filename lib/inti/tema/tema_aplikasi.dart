import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TemaAplikasi {
  // Biru yang mirip tombol setujui (standard primary blue)
  static const Color biruSetujui = Color.fromARGB(255, 0, 98, 255);
  // Biru spesifik untuk dark mode (RGBO 30, 58, 138, 1)
  static const Color biruSpesifik = Color.fromRGBO(30, 58, 138, 1);

  static const Color navyGelap = Color(0xFF0F172A);
  static const Color navyTerang = Color(0xFF1E293B);
  static const Color offWhite = Color(0xFFF8FAFC);

  static FThemeData light() {
    final base = FThemes.blue.light.touch;
    return base.copyWith(
      colors: base.colors.copyWith(
        primary: biruSetujui,
        background: biruSetujui, // Latar belakang dashboard biru di light mode
        foreground: navyGelap,
        card: Colors.white,
        muted: Colors.grey.withValues(alpha: 0.1),
        mutedForeground: Colors.grey,
      ),
    );
  }

  static FThemeData dark() {
    final base = FThemes.blue.dark.touch;
    return base.copyWith(
      colors: base.colors.copyWith(
        primary: biruSpesifik,
        background: navyGelap, // Latar belakang dashboard navy di dark mode
        foreground: offWhite,
        card: navyGelap,
        border: offWhite,
        muted: navyGelap,
        mutedForeground: offWhite.withValues(alpha: 0.7),
      ),
    );
  }
}
