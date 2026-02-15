import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive Design Tokens for HeartBit App
/// Ensures consistency across all UI components
class DesignTokens {
  DesignTokens._();

  // ==================== BORDER RADIUS ====================
  /// Ultra small radius: 8px - Tags, badges, small buttons
  static const double radiusXs = 8;

  /// Small radius: 12px - Input fields, small cards
  static const double radiusSm = 12;

  /// Medium radius: 16px - Cards, buttons, modals
  static const double radiusMd = 16;

  /// Large radius: 24px - Large cards, containers, sheets
  static const double radiusLg = 24;

  /// Extra large radius: 32px - Hero sections, featured cards
  static const double radiusXl = 32;

  /// Full radius: 999px - Pills, avatars, circular elements
  static const double radiusFull = 999;

  // BorderRadius helpers
  static BorderRadius get borderRadiusXs =>
      BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm =>
      BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd =>
      BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg =>
      BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl =>
      BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull =>
      BorderRadius.circular(radiusFull);

  // ==================== SPACING (8px Grid) ====================
  /// 4px - Micro spacing
  static const double space1 = 4;

  /// 8px - Extra small spacing
  static const double space2 = 8;

  /// 12px - Small spacing
  static const double space3 = 12;

  /// 16px - Medium spacing (base)
  static const double space4 = 16;

  /// 24px - Large spacing
  static const double space5 = 24;

  /// 32px - Extra large spacing
  static const double space6 = 32;

  /// 48px - 2x Extra large spacing
  static const double space7 = 48;

  /// 64px - 3x Extra large spacing
  static const double space8 = 64;

  // EdgeInsets helpers
  static EdgeInsets get padding1 => const EdgeInsets.all(space1);
  static EdgeInsets get padding2 => const EdgeInsets.all(space2);
  static EdgeInsets get padding3 => const EdgeInsets.all(space3);
  static EdgeInsets get padding4 => const EdgeInsets.all(space4);
  static EdgeInsets get padding5 => const EdgeInsets.all(space5);
  static EdgeInsets get padding6 => const EdgeInsets.all(space6);

  // Symmetric padding helpers
  static EdgeInsets get paddingHorizontal4 =>
      const EdgeInsets.symmetric(horizontal: space4);
  static EdgeInsets get paddingHorizontal5 =>
      const EdgeInsets.symmetric(horizontal: space5);
  static EdgeInsets get paddingVertical3 =>
      const EdgeInsets.symmetric(vertical: space3);
  static EdgeInsets get paddingVertical4 =>
      const EdgeInsets.symmetric(vertical: space4);

  // ==================== TYPOGRAPHY ====================
  /// Primary font for headings - Outfit
  static String get fontHeading => 'Outfit';

  /// Secondary font for body text - Inter
  static String get fontBody => 'Inter';

  // TextStyle generators
  static TextStyle heading1({Color? color, FontWeight? weight}) {
    return GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: weight ?? FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle heading2({Color? color, FontWeight? weight}) {
    return GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: weight ?? FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle heading3({Color? color, FontWeight? weight}) {
    return GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: weight ?? FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle heading4({Color? color, FontWeight? weight}) {
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: weight ?? FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  static TextStyle heading5({Color? color, FontWeight? weight}) {
    return GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: weight ?? FontWeight.w600,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle bodyLarge({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: weight ?? FontWeight.normal,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: weight ?? FontWeight.normal,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodySmall({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: weight ?? FontWeight.normal,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle labelLarge({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: weight ?? FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle labelMedium({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: weight ?? FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle labelSmall({Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: weight ?? FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.3,
      color: color,
    );
  }

  // Legacy support for Outfit font family string
  static const String outfit = 'Outfit';

  // ==================== ELEVATION / SHADOWS ====================
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== ANIMATION DURATIONS ====================
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // ==================== SKELETON ====================
  static Color get skeletonBaseColor => const Color(0xFF27272A);
  static Color get skeletonHighlightColor => const Color(0xFF3F3F46);
}
