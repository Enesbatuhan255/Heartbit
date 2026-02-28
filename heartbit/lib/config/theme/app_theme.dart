import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      // Typography
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: DesignTokens.heading1(color: AppColors.textPrimary),
          displayMedium: DesignTokens.heading2(color: AppColors.textPrimary),
          displaySmall: DesignTokens.heading3(color: AppColors.textPrimary),
          headlineLarge: DesignTokens.heading2(color: AppColors.textPrimary),
          headlineMedium: DesignTokens.heading3(color: AppColors.textPrimary),
          headlineSmall: DesignTokens.heading4(color: AppColors.textPrimary),
          titleLarge: DesignTokens.heading4(color: AppColors.textPrimary),
          titleMedium: DesignTokens.heading5(color: AppColors.textPrimary),
          titleSmall: DesignTokens.labelLarge(color: AppColors.textPrimary),
          bodyLarge: DesignTokens.bodyLarge(color: AppColors.textPrimary),
          bodyMedium: DesignTokens.bodyMedium(color: AppColors.textSecondary),
          bodySmall: DesignTokens.bodySmall(color: AppColors.textSecondary),
          labelLarge: DesignTokens.labelLarge(color: AppColors.textSecondary),
          labelMedium: DesignTokens.labelMedium(color: AppColors.textSecondary),
          labelSmall: DesignTokens.labelSmall(color: AppColors.textSecondary),
        ),
      ),
      // Input decoration with consistent border radius
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space4,
          vertical: DesignTokens.space3,
        ),
      ),
      // Elevated button with consistent styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space5,
            vertical: DesignTokens.space4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusMd,
          ),
          textStyle: DesignTokens.labelLarge(
            color: Colors.white,
            weight: FontWeight.w600,
          ),
        ),
      ),
      // Text button styling
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space3,
            vertical: DesignTokens.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSm,
          ),
          textStyle: DesignTokens.labelLarge(color: AppColors.primary),
        ),
      ),
      // Card theme with consistent border radius
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        margin: EdgeInsets.zero,
      ),
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusLg),
            topRight: Radius.circular(DesignTokens.radiusLg),
          ),
        ),
      ),
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusLg,
        ),
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: DesignTokens.heading4(color: AppColors.textPrimary),
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: DesignTokens.labelMedium(color: AppColors.textSecondary),
        secondaryLabelStyle: DesignTokens.labelMedium(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space3,
          vertical: DesignTokens.space1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusSm,
        ),
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusMd,
        ),
      ),
    );
  }
}
