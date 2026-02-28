import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Colors (unchanged) ─────────────────────────────────────────────
  static const Color primary = Color(0xFFFF4D8D);
  static const Color primaryDark = Color(0xFFD93A74);
  static const Color secondary = Color(0xFF7B61FF);
  static const Color accent = Color(0xFF7B61FF);

  // ─── Light Theme Surfaces ─────────────────────────────────────────────────
  static const Color background = Color(0xFFFDF6F0);   // warm cream
  static const Color surface = Color(0xFFFFFFFF);       // white
  static const Color card = Color(0xFFFFF5EE);          // soft peach

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D2B3D);   // deep purple-gray
  static const Color textSecondary = Color(0xFF9B95A5);  // muted lavender
  static const Color border = Color(0xFFE8DDD5);         // warm border

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // ─── Accent Colors ────────────────────────────────────────────────────────
  static const Color pumpingHeart = Color(0xFFFF4D8D);
  static const Color orange = Color(0xFFF59E0B);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient romanticBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFDF6F0), Color(0xFFFFF0E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glass ────────────────────────────────────────────────────────────────
  static const Color glassSurface = Color(0xFFFFFFFF);
  static const Color glassStroke = Color(0xFFE8DDD5);
}
