import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors - Clean green for a minimalist feel
  static const Color primary = Color(0xFF4CAF50); // Green
  static const Color primaryDark = Color(0xFF388E3C); // Dark Green
  static const Color primaryLight = Color(0xFFC8E6C9); // Light Green

  // Secondary/Accent colors - Minimalist black
  static const Color secondary = Color(0xFF212121); // Near Black
  static const Color secondaryDark = Color(0xFF000000); // Pure Black
  static const Color secondaryLight = Color(0xFF484848); // Dark Gray

  // Accent colors - Minimal hint of color
  static const Color accent = Color(0xFF8BC34A); // Light Green accent
  static const Color accentDark = Color(0xFF689F38);
  static const Color accentLight = Color(0xFFDCEDC8);

  // Background colors - Clean whites for minimalism
  static const Color background = Color(0xFFFAFAFA); // Almost white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceDark = Color(
    0xFF121212,
  ); // Near black for dark theme

  // Card and surface gradients
  static const List<Color> lightGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF5F5F5), // Subtle gradient
  ];
  static const List<Color> darkGradient = [
    Color(0xFF212121),
    Color(0xFF1A1A1A), // Subtle dark gradient
  ];
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50), // Green
    Color(0xFF66BB6A), // Lighter green
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF212121), // Near black
    Color(0xFF424242), // Dark gray
  ];

  // Status colors - Clean and minimal
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // Text colors - High contrast for readability in minimalist design
  static const Color textDark = Color(0xFF212121); // Near black
  static const Color textMedium = Color(0xFF757575); // Medium gray
  static const Color textLight = Color(0xFFBDBDBD); // Light gray
  static const Color textWhite = Color(0xFFFAFAFA); // Almost white

  // Dark theme colors - Minimal dark theme with green accents
  static const Color darkBackground = Color(0xFF121212); // Near black
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark gray
  static const Color darkPrimary = Color(
    0xFF81C784,
  ); // Light green for dark theme
  static const Color darkSecondary = Color(0xFFE0E0E0); // Light gray
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Almost white
  static const Color darkTextSecondary = Color(0xFFBDBDBD); // Light gray
}

class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight.withOpacity(0.3),
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight.withOpacity(0.3),
      tertiary: AppColors.accent,
      surface: AppColors.surfaceLight,
      background: AppColors.background,
      error: AppColors.error,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        backgroundColor: AppColors.primary,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.textMedium,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
      floatingLabelStyle: GoogleFonts.poppins(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: AppColors.textMedium,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: AppColors.textLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEFEFF2),
      thickness: 1,
      space: 24,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
      disabledColor: AppColors.textLight.withOpacity(0.1),
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        color: AppColors.secondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: AppColors.textMedium,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: AppColors.textMedium,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.poppins(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.primary.withOpacity(0.2),
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.secondary.withOpacity(0.2),
      tertiary: AppColors.accent,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.darkBackground,
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.darkTextSecondary.withOpacity(0.7),
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.poppins(
        color: AppColors.darkPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: AppColors.darkTextSecondary,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return Colors.transparent;
      }),
      side: BorderSide(
        color: AppColors.darkTextSecondary.withOpacity(0.7),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkTextSecondary.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkTextSecondary.withOpacity(0.7),
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkPrimary.withOpacity(0.2),
      disabledColor: AppColors.darkTextSecondary.withOpacity(0.1),
      selectedColor: AppColors.darkPrimary,
      secondarySelectedColor: AppColors.darkSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.darkPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        color: AppColors.darkSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.dark,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.poppins(
        color: AppColors.darkTextSecondary.withOpacity(0.7),
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
