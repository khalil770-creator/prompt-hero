import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// The Prompt Hero brand mark — a four-point asymmetric spark.
///
/// Drawn on a 32×32 grid. The right facet is filled with
/// [AppColors.mint] (the brand accent); all other facets use
/// [AppColors.ink]. The inner diamond is 85% opacity ink for
/// depth. Minimum recommended size: 16×16 px.
///
/// ```dart
/// const PHMark(size: 84)                    // splash / hero
/// const PHMark(size: 22, inverted: true)    // on dark surfaces
/// const PHMark(size: 32, monochrome: true)  // on mint surfaces
/// ```
class PHMark extends StatelessWidget {
  final double size;

  /// Use on dark / ink surfaces — white ink + mint accent.
  final bool inverted;

  /// Collapse the mint facet into the ink color — use when the
  /// mark sits on a mint background and the accent would clash.
  final bool monochrome;

  const PHMark({
    super.key,
    this.size = 32,
    this.inverted = false,
    this.monochrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = inverted ? Colors.white : AppColors.ink;
    final accent = monochrome ? ink : AppColors.mint;
    return CustomPaint(
      size: Size.square(size),
      painter: _PHMarkPainter(ink: ink, accent: accent),
    );
  }
}

class _PHMarkPainter extends CustomPainter {
  final Color ink;
  final Color accent;
  _PHMarkPainter({required this.ink, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32.0;

    Path tri(List<List<double>> pts) {
      final path = Path()..moveTo(pts[0][0] * s, pts[0][1] * s);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i][0] * s, pts[i][1] * s);
      }
      path.close();
      return path;
    }

    final inkPaint    = Paint()..color = ink;
    final accentPaint = Paint()..color = accent;
    final innerPaint  = Paint()..color = ink.withValues(alpha: 0.85);

    // Top facet
    canvas.drawPath(
      tri([[16, 1], [18.2, 13.8], [16, 14.5], [13.8, 13.8]]),
      inkPaint,
    );
    // Bottom facet
    canvas.drawPath(
      tri([[16, 31], [18.2, 18.2], [16, 17.5], [13.8, 18.2]]),
      inkPaint,
    );
    // Left facet
    canvas.drawPath(
      tri([[1, 16], [13.8, 13.8], [14.5, 16], [13.8, 18.2]]),
      inkPaint,
    );
    // Right facet — mint accent
    canvas.drawPath(
      tri([[31, 16], [18.2, 18.2], [17.5, 16], [18.2, 13.8]]),
      accentPaint,
    );
    // Inner diamond
    canvas.drawPath(
      tri([[16, 14.5], [17.5, 16], [16, 17.5], [14.5, 16]]),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PHMarkPainter old) =>
      old.ink != ink || old.accent != accent;
}

/// Full wordmark lockup: mark + "Prompt" (Geist sans) +
/// "Hero" (Geist sans bold, mint).
///
/// ```dart
/// const PHWordmark(size: 22)                          // on white app bar
/// const PHWordmark(size: 18, inverted: true)          // on dark/colored bg
/// const PHWordmark(size: 22, showMark: false)         // wordmark only
/// ```
class PHWordmark extends StatelessWidget {
  /// Base font size for the wordmark. Both "Prompt" and "Hero"
  /// share the same Geist 700 setting; "Hero" uses [AppColors.mint].
  final double size;
  final bool inverted;
  final bool showMark;

  /// Set to true when the wordmark sits on a mint background —
  /// collapses the mint accent to white so nothing disappears.
  final bool monochrome;

  const PHWordmark({
    super.key,
    this.size = 22,
    this.inverted = false,
    this.showMark = true,
    this.monochrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = inverted ? Colors.white : AppColors.ink;
    final heroColor = monochrome ? ink : AppColors.mint;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showMark) ...[
          PHMark(size: size * 1.05, inverted: inverted, monochrome: monochrome),
          SizedBox(width: size * 0.36),
        ],
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Prompt',
                style: GoogleFonts.geist(
                  fontSize: size,
                  color: ink,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -size * 0.02,
                  height: 1,
                ),
              ),
              TextSpan(
                text: ' ',
                style: TextStyle(fontSize: size * 0.22),
              ),
              TextSpan(
                text: 'Hero',
                style: GoogleFonts.geist(
                  fontSize: size,
                  color: heroColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -size * 0.02,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
