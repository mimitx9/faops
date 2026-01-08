import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0051D5);
  static const Color primaryLight = Color(0xFF5AC8FA);

  // Secondary Colors
  static const Color secondary = Color(0xFF5856D6);
  static const Color secondaryDark = Color(0xFF3634A3);
  static const Color secondaryLight = Color(0xFFAF52DE);

  // Accent Colors
  static const Color accent = Color(0xFFFF9500);
  static const Color accentDark = Color(0xFFFF6B00);
  static const Color accentLight = Color(0xFFFFB340);

  // Neutral Colors
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);
  static const Color textHint = Color(0xFF999999); // For hint text
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // Border Colors
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFF38383A);
  static const Color borderLight = Color(0xFFD9D9D9); // For input fields

  // Divider Colors
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Chat Colors
  static const Color chatBubbleSent = Color(0xFF007AFF);
  static const Color chatBubbleReceived = Color(0xFFE5E5EA);
  static const Color chatTextSent = Color(0xFFFFFFFF);
  static const Color chatTextReceived = Color(0xFF000000);

  // Pro/Upgrade Colors
  static const Color proGradientStart = Color(0xFFFF9500);
  static const Color proGradientEnd = Color(0xFFFF6B00);

  // Button Gradient Colors (for login button)
  static const Color buttonGradientStart = Color(0xFF555555);
  static const Color buttonGradientEnd = Color(0xFF000000);

  // Icon Colors
  static const Color iconSecondary = Color(0xFF555555); // For secondary icons

  // Task / Calendar Colors
  // Màu tím theo design task (C74EFF) và bản nhạt 10%
  static const Color taskPrimary = Color(0xFFC74EFF);
  static const Color taskPrimarySoft = Color(0x1AC74EFF); // 10% opacity
  // Màu xám nhạt 10% của đen để thể hiện trạng thái "chưa có nhiệm vụ"
  static const Color taskEmpty = Color(0x1A000000);
}

