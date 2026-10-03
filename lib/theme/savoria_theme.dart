import 'package:flutter/cupertino.dart';

class SavoriaTheme {
  // Brand Executive Palette
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoDark = Color(0xFF3730A3);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentRose = Color(0xFFEF4444);

  // Light theme colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightFrosted = Color(0xE6FFFFFF);
  static const Color lightBorder = Color(0x180F172A);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkFrosted = Color(0xD91E293B);
  static const Color darkBorder = Color(0x28FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static CupertinoThemeData getTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: primaryIndigo,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,
      barBackgroundColor: isDark ? darkFrosted : lightFrosted,
      textTheme: CupertinoTextThemeData(
        primaryColor: isDark ? darkTextPrimary : lightTextPrimary,
        textStyle: TextStyle(
          color: isDark ? darkTextPrimary : lightTextPrimary,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        navTitleTextStyle: TextStyle(
          color: isDark ? darkTextPrimary : lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: isDark ? darkTextPrimary : lightTextPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        actionTextStyle: const TextStyle(
          color: primaryIndigo,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? darkTextSecondary : lightTextSecondary,
        ),
      ),
    );
  }

  // Frosted Card Decoration
  static BoxDecoration frostedCardDecoration(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xB31E293B) : const Color(0xF2FFFFFF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark ? const Color(0x28FFFFFF) : const Color(0x140F172A),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? const Color(0x40000000) : const Color(0x0A0F172A),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Priority Color Helper
  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return accentRose;
      case 'high':
        return accentAmber;
      case 'medium':
        return primaryIndigo;
      case 'normal':
      default:
        return accentEmerald;
    }
  }
}
