import 'package:flutter/material.dart';

/// Global color tokens for Fancy Shop Admin Panel.
/// Modify these values to rebrand for any client.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);        // Indigo-violet
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  static const Color accent = Color(0xFFFF6584);         // Coral-pink accent
  static const Color accentLight = Color(0xFFFF90A8);

  // ── Light Theme ───────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEFF8);
  static const Color lightSidebar = Color(0xFF1E1B4B);   // Deep indigo sidebar
  static const Color lightSidebarText = Color(0xFFCAC8F0);
  static const Color lightSidebarActive = Color(0xFF6C63FF);

  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFD1D5DB);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkSidebar = Color(0xFF0D0D1A);
  static const Color darkSidebarText = Color(0xFF8B8BAD);
  static const Color darkSidebarActive = Color(0xFF6C63FF);

  static const Color darkTextPrimary = Color(0xFFF1F0FF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);
  static const Color darkDivider = Color(0xFF2D2D4E);
  static const Color darkBorder = Color(0xFF3D3D5C);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFDBEAFE);

  // ── Status chips ──────────────────────────────────────────────────────────
  static const Color pending = Color(0xFFF59E0B);
  static const Color processing = Color(0xFF3B82F6);
  static const Color shipped = Color(0xFF8B5CF6);
  static const Color delivered = Color(0xFF10B981);
  static const Color cancelled = Color(0xFFEF4444);

  // ── Chart / Stats cards ───────────────────────────────────────────────────
  static const List<Color> chartGradient1 = [Color(0xFF6C63FF), Color(0xFF9D97FF)];
  static const List<Color> chartGradient2 = [Color(0xFFFF6584), Color(0xFFFF90A8)];
  static const List<Color> chartGradient3 = [Color(0xFF10B981), Color(0xFF34D399)];
  static const List<Color> chartGradient4 = [Color(0xFFF59E0B), Color(0xFFFBBF24)];
}
