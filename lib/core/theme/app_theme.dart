import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: DesignSystem.elevationNone,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.border,
            width: DesignSystem.borderWidthThin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMD,
          vertical: DesignSystem.spacingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.border,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.border,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: DesignSystem.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
            width: DesignSystem.borderWidthMedium,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: DesignSystem.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLG),
          side: BorderSide(
            color: AppColors.border,
            width: DesignSystem.borderWidthThin,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: DesignSystem.borderWidthThin,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceDark,
        background: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textOnPrimary,
        onBackground: AppColors.textOnPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: DesignSystem.elevationNone,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: BorderSide(
            color: AppColors.borderDark,
            width: DesignSystem.borderWidthThin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          ),
          textStyle: AppTypography.button,
          minimumSize: Size(0, DesignSystem.buttonHeightMD),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMD,
          vertical: DesignSystem.spacingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.borderDark,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.borderDark,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: DesignSystem.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
            width: DesignSystem.borderWidthMedium,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: DesignSystem.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLG),
          side: BorderSide(
            color: AppColors.borderDark,
            width: DesignSystem.borderWidthThin,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: DesignSystem.borderWidthThin,
        space: 1,
      ),
    );
  }
}

