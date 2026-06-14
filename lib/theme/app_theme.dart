import 'package:flutter/material.dart';

/// Central design tokens for the AI Smart Notes app.
///
/// The aesthetic is a deep, near-black space with a single shifting
/// iridescent accent (blue -> violet -> rose) plus a warm gold used only
/// for "generation in progress" moments. Surfaces are glass: translucent
/// fills over a heavy blur.
class AppColors {
  AppColors._();

  // Base canvas.
  static const Color bg = Color(0xFF05060A);
  static const Color bgElevated = Color(0xFF0B0D14);

  // Glass surfaces (used with BackdropFilter blur behind them).
  static const Color glass = Color(0x14FFFFFF); // ~8% white
  static const Color glassStrong = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF); // ~15% white
  static const Color glassBorderSoft = Color(0x14FFFFFF);

  // Text.
  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textSecondary = Color(0xFFA7AEC2);
  static const Color textFaint = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF6E768C);

  // The iridescent accent stops.
  static const Color accentBlue = Color(0xFF6AA7FF);
  static const Color accentViolet = Color(0xFF9A7BFF);
  static const Color accentRose = Color(0xFFE56AA8);
  static const Color accentCyan = Color(0xFF63E6E2);

  // Warm "processing" gold.
  static const Color gold = Color(0xFFE9C46A);
  static const Color goldBright = Color(0xFFFFE7A8);

  static const Color danger = Color(0xFFFF6B6B);
}

class AppGradients {
  AppGradients._();

  /// The signature button / pill gradient: cool blue washing into warm rose.
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7FB0FF), Color(0xFF9D8BFF), Color(0xFFE58FB6)],
  );

  static const LinearGradient accentSoft = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x807FB0FF), Color(0x809D8BFF), Color(0x80E58FB6)],
  );

  /// Full-bleed background wash anchored bottom-left (rose) to top-right (deep).
  static const LinearGradient ambient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF2A0E1C),
      Color(0xFF0B0815),
      Color(0xFF06131A),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const SweepGradient iridescent = SweepGradient(
    colors: [
      Color(0xFF6AA7FF),
      Color(0xFF9A7BFF),
      Color(0xFFE56AA8),
      Color(0xFF63E6E2),
      Color(0xFF6AA7FF),
    ],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const fontFamily = 'PlusJakartaSans';
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.bg,
        primary: AppColors.accentViolet,
        secondary: AppColors.accentRose,
      ),
      textTheme: base.textTheme
          .apply(
            fontFamily: fontFamily,
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          )
          .copyWith(
            displayLarge: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 40,
              height: 1.08,
              letterSpacing: -0.5,
            ),
            headlineMedium: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.2,
            ),
            titleMedium: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            bodyMedium: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
    );
  }
}

/// Convenience spacing scale.
class Gap {
  static const xs = SizedBox(height: 6, width: 6);
  static const sm = SizedBox(height: 12, width: 12);
  static const md = SizedBox(height: 20, width: 20);
  static const lg = SizedBox(height: 32, width: 32);
  static const xl = SizedBox(height: 48, width: 48);
}
