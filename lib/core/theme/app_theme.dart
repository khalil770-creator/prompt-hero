import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Prompt Hero v2 theme — MINT direction.
///
/// White surfaces · ink text · mint primary CTA.
///
/// Font pairing:
///   • Display / headlines  → Instrument Serif (bold accents)
///   • Body / UI            → Geist
///   • Prompt body / mono   → Geist Mono
///
/// All three font families load via `google_fonts` — no manual
/// font assets required. Replaces Poppins.
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────────────
  // Text theme
  // ──────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color text, Color textMuted) {
    final serif = GoogleFonts.instrumentSerif(color: text);
    final sans  = GoogleFonts.geist(color: text);

    return TextTheme(
      // Editorial display — serif, often italic
      displayLarge: serif.copyWith(
        fontSize: 56, height: 1.05, letterSpacing: -1.2,
      ),
      displayMedium: serif.copyWith(
        fontSize: 44, height: 1.08, letterSpacing: -1.0,
      ),
      displaySmall: serif.copyWith(
        fontSize: 36, height: 1.1, letterSpacing: -0.8,
      ),
      // Headlines — serif
      headlineLarge: serif.copyWith(
        fontSize: 32, height: 1.1, letterSpacing: -0.6,
      ),
      headlineMedium: serif.copyWith(
        fontSize: 28, height: 1.15, letterSpacing: -0.5,
      ),
      headlineSmall: serif.copyWith(
        fontSize: 22, height: 1.2, letterSpacing: -0.3,
      ),
      // Titles — sans
      titleLarge: sans.copyWith(
        fontSize: 20, height: 1.25, letterSpacing: -0.3,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: sans.copyWith(
        fontSize: 16, height: 1.3, letterSpacing: -0.1,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: sans.copyWith(
        fontSize: 14, height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      // Body
      bodyLarge:  sans.copyWith(fontSize: 16, height: 1.55, color: text),
      bodyMedium: sans.copyWith(fontSize: 14, height: 1.55, color: textMuted),
      bodySmall:  sans.copyWith(fontSize: 12, height: 1.4,  color: textMuted),
      // Labels
      labelLarge: sans.copyWith(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
      labelMedium: sans.copyWith(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2,
      ),
      labelSmall: sans.copyWith(
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.6,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Light theme — VIBRANT
  // ──────────────────────────────────────────────────────────
  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,

    colorScheme: const ColorScheme.light(
      primary:        AppColors.mint,   // bright CTA color
      onPrimary:      Colors.white,
      secondary:      AppColors.indigo,
      onSecondary:    Colors.white,
      tertiary:       AppColors.magenta,
      onTertiary:     Colors.white,
      surface:        AppColors.white,
      onSurface:      AppColors.ink,
      surfaceTint:    AppColors.white,
      error:          AppColors.crimson,
      onError:        Colors.white,
      outline:        AppColors.border,
      outlineVariant: AppColors.borderSoft,
    ),

    textTheme: _buildTextTheme(AppColors.ink, AppColors.textSecondary),

    // App bar — WHITE with ink text. Vibrancy lives in the
    // page content, not the chrome.
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.geist(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
    ),

    // ── BUTTONS — generous min height + padding so labels like
    //    "Add new prompt" NEVER clip on any device width.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: GoogleFonts.geist(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1,
        ),
      ).copyWith(
        // Subtle mint glow under primary CTAs
        shadowColor: WidgetStateProperty.all(
          AppColors.mint.withValues(alpha: 0.4),
        ),
        elevation: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.pressed) ? 0 : 6),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: GoogleFonts.geist(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: GoogleFonts.geist(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.geist(
          fontSize: 14, fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Inputs — clean, with 1.5px border for visibility
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      hintStyle: GoogleFonts.geist(
        color: AppColors.textDisabled, fontSize: 14,
      ),
      labelStyle: GoogleFonts.geist(
        color: AppColors.textSecondary, fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimson),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimson, width: 1.5),
      ),
    ),

    // Cards — white on white, hairline border, no shadow
    cardTheme: CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSoft, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // Bottom navigation — pill indicator on ink
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.ink,
      indicatorShape: const StadiumBorder(),
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return GoogleFonts.geist(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.ink : AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return IconThemeData(
          color: active ? Colors.white : AppColors.textSecondary,
          size: 22,
        );
      }),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),

    // FAB — vibrant mint, the universal "Add" action
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.mint,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: GoogleFonts.geist(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceAlt,
      labelStyle: GoogleFonts.geist(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border, thickness: 1, space: 1,
    ),

    iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
  );

  // ──────────────────────────────────────────────────────────
  // Optional dark theme — inverts surfaces; accents stay vibrant
  // ──────────────────────────────────────────────────────────
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary:     AppColors.mint,
      onPrimary:   Colors.white,
      secondary:   AppColors.indigo,
      onSecondary: Colors.white,
      surface:     AppColors.surfaceDark,
      onSurface:   AppColors.textPrimaryDark,
      error:       AppColors.crimson,
      onError:     Colors.white,
      outline:     AppColors.dividerDark,
    ),
    textTheme: _buildTextTheme(
      AppColors.textPrimaryDark,
      AppColors.textSecondaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
