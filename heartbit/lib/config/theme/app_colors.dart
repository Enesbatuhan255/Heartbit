import 'package:flutter/material.dart';

class AppColors {
  // Premium Dark Theme Palette
  static const Color primary = Color(0xFFFF4B7D); // HeartBit Pink (kept for brand identity but pops on dark)
  static const Color primaryDark = Color(0xFFD63462);
  static const Color secondary = Color(0xFF7B61FF); // Deep Purple
  static const Color accent = Color(0xFFFFD166); // Gold/Yellow Accent

  static const Color background = Color(0xFF09090B); // Very Dark (Notion/Linear style)
  static const Color surface = Color(0xFF18181B); // Slightly lighter for cards
  
  static const Color textPrimary = Color(0xFFEDEDED); // Off-white for reading comfort
  static const Color textSecondary = Color(0xFFA1A1AA); // Grey for subtitles
  static const Color border = Color(0xFF27272A); // Subtle border color for dark mode cards
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  // New Colors
  static const Color pumpingHeart = Color(0xFFFF4B7D); // Match Primary
  static const Color orange = Color(0xFFFF8C42); // Orange for warmth

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [surface, Color(0xFF27272A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
