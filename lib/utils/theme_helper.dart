import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// CARA PAKAI DI HALAMAN MANAPUN:
///
/// // Import dulu
/// import '../utils/theme_helper.dart';
///
/// // Di dalam build():
/// final c = context.colors;          // ← semua warna adaptive
///
/// Container(color: c.surface)        // putih di light, gelap di dark
/// Text('..', style: TextStyle(color: c.onSurface))
/// Container(color: c.background)     // background halaman
/// ─────────────────────────────────────────────────────────────────────────

const kTeal      = Color(0xFF00A086);
const kTealDark  = Color(0xFF007A68);
const kTealLight = Color(0xFF00C4A7);
const kGold      = Color(0xFFE8A020);

extension ThemeContextExt on BuildContext {
  ThemeData   get theme      => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool        get isDark     => Theme.of(this).brightness == Brightness.dark;
  AppColors   get colors     => AppColors(this);
}

class AppColors {
  final BuildContext _ctx;
  AppColors(this._ctx);

  bool get isDark => _ctx.isDark;

  // ── Backgrounds ────────────────────────────────────────────────────────
  /// Warna latar halaman (F2F4F7 / 121212)
  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7);

  /// Warna card / container putih (white / 1E1E1E)
  Color get surface =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;

  /// Surface sedikit lebih gelap dari surface utama
  Color get surfaceVariant =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  // ── Text ───────────────────────────────────────────────────────────────
  /// Teks utama (1A1A2E / white87)
  Color get onSurface =>
      isDark ? Colors.white.withOpacity(0.87) : const Color(0xFF1A1A2E);

  /// Teks sekunder (grey700 / white60)
  Color get textSecondary =>
      isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade700;

  /// Teks tersier / hint (grey500 / white40)
  Color get textHint =>
      isDark ? Colors.white.withOpacity(0.4) : Colors.grey.shade500;

  // ── Divider / Border ───────────────────────────────────────────────────
  Color get divider =>
      isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;

  Color get border =>
      isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300;

  // ── Brand ──────────────────────────────────────────────────────────────
  Color get teal      => kTeal;
  Color get tealDark  => kTealDark;
  Color get tealLight => kTealLight;
  Color get gold      => kGold;

  // ── Shadow ─────────────────────────────────────────────────────────────
  Color get shadow =>
      isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06);

  // ── Status ─────────────────────────────────────────────────────────────
  Color get success => const Color(0xFF388E3C);
  Color get error   => const Color(0xFFD32F2F);
  Color get warning => kGold;
  Color get info    => const Color(0xFF1565C0);
}

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE WIDGETS — tinggal pakai tanpa mikir dark mode
// ─────────────────────────────────────────────────────────────────────────────

/// Container yang otomatis pakai warna surface (putih / gelap)
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? color;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  c.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Divider yang adaptive
class AdaptiveDivider extends StatelessWidget {
  final double? indent;
  const AdaptiveDivider({super.key, this.indent});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color:  context.colors.divider,
      indent: indent,
    );
  }
}