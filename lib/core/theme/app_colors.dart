import 'package:flutter/material.dart';

/// Prompt Hero v2 — MINT palette
///
/// White surfaces. Mint as the primary brand accent — fresh,
/// professional, clearly distinguishable from competitors.
/// Category cards use a curated multi-color set led by mint.
///
/// All legacy token names (`primary`, `secondary`, `ember`,
/// `parchment`, `heroGradient`, `categoryGradients`, etc.)
/// are preserved as aliases so existing widgets compile.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────────────────
  // Surfaces — pure light
  // ──────────────────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color canvas     = Color(0xFFFAFAF9);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F5F7);

  // Text — ink (near-black, slightly cool)
  static const Color ink           = Color(0xFF0A0A12);
  static const Color inkSoft       = Color(0xFF1A1A24);
  static const Color textPrimary   = ink;
  static const Color textSecondary = Color(0xFF5B6470);
  static const Color textDisabled  = Color(0xFF9CA3AF);

  // Lines
  static const Color border        = Color(0xFFE5E7EB);
  static const Color borderSoft    = Color(0xFFF1F2F4);

  // ──────────────────────────────────────────────────────────
  // VIBRANT brand accents — the heart of v2
  // ──────────────────────────────────────────────────────────
  static const Color mint      = Color(0xFF00B894); // primary CTA / brand
  static const Color mintSoft  = Color(0xFFD5F4EC);
  static const Color mintDeep  = Color(0xFF008A6F);

  static const Color indigo     = Color(0xFF5145FF); // featured / links
  static const Color indigoSoft = Color(0xFFE4E2FF);

  static const Color magenta    = Color(0xFFFF2D87);
  static const Color cyan       = Color(0xFF00B8D9);
  static const Color lime       = Color(0xFFB8E236);
  static const Color purple     = Color(0xFF9333EA);
  static const Color teal       = Color(0xFF00D4AA);
  static const Color sunshine   = Color(0xFFFFC93C);

  // Functional
  static const Color gold        = Color(0xFFFFB400); // star ratings
  static const Color sage        = Color(0xFF16A34A); // success
  static const Color sageSoft    = Color(0xFFDCFCE7);
  static const Color crimson     = Color(0xFFDC2626); // error / delete
  static const Color crimsonSoft = Color(0xFFFEE2E2);

  // ──────────────────────────────────────────────────────────
  // Backward-compat aliases — keep so existing widgets compile
  // ──────────────────────────────────────────────────────────
  static const Color primary        = mint;
  static const Color primaryLight   = Color(0xFF5FD9BD);
  static const Color primaryDark    = mintDeep;
  static const Color secondary      = indigo;
  static const Color secondaryLight = Color(0xFF7A70FF);
  static const Color secondaryDark  = Color(0xFF4034D6);
  static const Color background     = white;
  static const Color divider        = border;
  static const Color success        = sage;
  static const Color warning        = sunshine;
  static const Color error          = crimson;
  static const Color info           = indigo;
  static const Color shadow         = Color(0x140A0A12);
  static const Color shadowMedium   = Color(0x1F0A0A12);
  static const Color starActive     = gold;
  static const Color starInactive   = border;

  // Earlier "editorial vault" naming kept as alias
  static const Color ember         = mint;
  static const Color emberSoft     = mintSoft;
  static const Color emberDeep     = mintDeep;
  static const Color parchment     = white;
  static const Color parchmentDeep = surfaceAlt;

  // Dark-mode equivalents
  static const Color backgroundDark    = Color(0xFF0A0A12);
  static const Color surfaceDark       = Color(0xFF1A1A24);
  static const Color textPrimaryDark   = white;
  static const Color textSecondaryDark = Color(0xFFA8ACB3);
  static const Color dividerDark       = Color(0xFF2A2A38);

  // ──────────────────────────────────────────────────────────
  // Category card fills — SOLID vibrant tiles
  // ──────────────────────────────────────────────────────────
  /// Use [categoryFill] to get a (bg, fg) tuple for a category
  /// card with a saturated vibrant background.
  static const List<(Color bg, Color fg)> categoryFills = [
    (Color(0xFF00B894), Color(0xFFFFFFFF)), // 0 mint
    (Color(0xFF5145FF), Color(0xFFFFFFFF)), // 1 indigo
    (Color(0xFFFF2D87), Color(0xFFFFFFFF)), // 2 magenta
    (Color(0xFF00B8D9), Color(0xFFFFFFFF)), // 3 cyan
    (Color(0xFF9333EA), Color(0xFFFFFFFF)), // 4 purple
    (Color(0xFFB8E236), Color(0xFF0A0A12)), // 5 lime   (dark text)
    (Color(0xFF00D4AA), Color(0xFFFFFFFF)), // 6 teal
    (Color(0xFFFFC93C), Color(0xFF0A0A12)), // 7 sunshine (dark text)
  ];

  /// Soft tinted variant — use for icon containers on white
  /// cards if you want a quieter category accent than the fill.
  static const List<(Color bg, Color fg)> categoryTints = [
    (Color(0xFFD5F4EC), Color(0xFF008A6F)),
    (Color(0xFFE4E2FF), Color(0xFF4034D6)),
    (Color(0xFFFFE0EE), Color(0xFFD6206E)),
    (Color(0xFFD6F2F8), Color(0xFF0089A3)),
    (Color(0xFFF0E1FB), Color(0xFF7820D6)),
    (Color(0xFFEFF7D9), Color(0xFF5A7818)),
    (Color(0xFFD4F7EE), Color(0xFF00A584)),
    (Color(0xFFFFF3CC), Color(0xFFA88200)),
  ];

  static (Color bg, Color fg) categoryFill(int index) =>
      categoryFills[index.abs() % categoryFills.length];

  static (Color bg, Color fg) categoryTint(int index) =>
      categoryTints[index.abs() % categoryTints.length];

  // Legacy: each entry is a 2-color list of the SAME color so
  // existing LinearGradient(colors: ...) code renders the flat
  // vibrant fill from categoryFills.
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF00B894), Color(0xFF00B894)],
    [Color(0xFF5145FF), Color(0xFF5145FF)],
    [Color(0xFFFF2D87), Color(0xFFFF2D87)],
    [Color(0xFF00B8D9), Color(0xFF00B8D9)],
    [Color(0xFF9333EA), Color(0xFF9333EA)],
    [Color(0xFFB8E236), Color(0xFFB8E236)],
    [Color(0xFF00D4AA), Color(0xFF00D4AA)],
    [Color(0xFFFFC93C), Color(0xFFFFC93C)],
  ];

  // Hero / header gradients — vibrant mint → magenta blend.
  // Kept as LinearGradient so existing usages compile.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, mintDeep],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, magenta],
  );
}
